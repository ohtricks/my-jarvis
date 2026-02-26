import os
import tempfile

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel

from jarvis_core import JarvisCore

app = FastAPI(
    title="JARVIS API",
    description="Assistente pessoal JARVIS — backend FastAPI",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

jarvis = JarvisCore()


class ChatRequest(BaseModel):
    message: str


# ──────────────────────────────────────────
# Endpoints REST
# ──────────────────────────────────────────

@app.get("/")
async def root():
    return {"status": "online", "message": "JARVIS ativo. Acesse /docs para a API."}


@app.post("/chat/text")
async def chat_text(payload: ChatRequest):
    """Envia mensagem de texto e recebe resposta do JARVIS."""
    response = jarvis.process_text(payload.message)
    return {"response": response}


@app.post("/chat/voice")
async def chat_voice(audio: UploadFile = File(...)):
    """
    Recebe arquivo de áudio WAV, transcreve com Whisper e retorna resposta em áudio (Piper TTS).
    Headers de resposta: X-Transcription (o que o usuário disse), X-Response (resposta do JARVIS).
    """
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        f.write(await audio.read())
        audio_path = f.name

    response_audio_path = None
    try:
        user_text, response_text = jarvis.process_audio_file(audio_path)
        response_audio_path = jarvis.tts.speak(response_text)

        return FileResponse(
            response_audio_path,
            media_type="audio/wav",
            headers={
                "X-Transcription": user_text,
                "X-Response": response_text,
            },
        )
    except Exception as e:
        return {"error": str(e)}
    finally:
        os.unlink(audio_path)
        # response_audio_path é apagado pelo FileResponse após envio


@app.delete("/memory")
async def clear_memory():
    """Limpa o histórico de conversa do JARVIS."""
    jarvis.memory.clear()
    return {"message": "Memória limpa com sucesso."}


@app.get("/status")
async def status():
    """Retorna status do JARVIS e do modelo Ollama."""
    return {
        "model": jarvis.llm.model,
        "memory_messages": len(jarvis.memory),
        "tools": list(jarvis.tools.keys()),
    }


# ──────────────────────────────────────────
# WebSocket — streaming de resposta
# ──────────────────────────────────────────

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket para streaming de resposta em tempo real."""
    await websocket.accept()
    try:
        while True:
            data = await websocket.receive_json()
            user_input = data.get("message", "")

            if not user_input:
                continue

            for chunk in jarvis.process_text_stream(user_input):
                await websocket.send_json({"chunk": chunk})

            await websocket.send_json({"done": True})
    except WebSocketDisconnect:
        pass


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=False)
