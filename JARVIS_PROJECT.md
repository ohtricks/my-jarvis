# 🤖 JARVIS — Assistente Pessoal por Voz em PT-BR
> Projeto de assistente pessoal estilo J.A.R.V.I.S. do Homem de Ferro, rodando 100% local no Mac M4, com suporte a português brasileiro.

---

## 📋 Visão Geral do Projeto

**Objetivo:** Criar um assistente pessoal conversacional por voz que:
- Responde em português brasileiro
- Roda 100% local (zero custo de API)
- Executa tarefas reais: enviar email, consultar clima, gerar relatórios, etc.
- Tem personalidade definida (JARVIS)
- Suporta conversa natural com interrupções

**Stack principal:**
- **LLM:** LLaMA 3.3 8B via Ollama (cérebro)
- **STT:** Whisper large-v3 via faster-whisper (ouvidos)
- **TTS:** Piper TTS com modelo `pt_BR-faber-medium` (voz em PT-BR) ✅ leve, rápido, 100% local
- **Orquestração:** Python 3.12 + FastAPI
- **Interface:** App nativo macOS com SwiftUI (microfone + chat)

**Skills Claude Code por área:**

| Área | Skill | Instalar |
|---|---|---|
| FastAPI / Backend | `mindrally/skills@fastapi-python` | `npx skills add mindrally/skills@fastapi-python -g -y` |
| FastAPI Async / WebSocket | `thebushidocollective/han@fastapi-async-patterns` | `npx skills add thebushidocollective/han@fastapi-async-patterns -g -y` |
| Ollama / LLM Local | `yonatangross/orchestkit@ollama-local` | `npx skills add yonatangross/orchestkit@ollama-local -g -y` |
| LLM Ops (prompt, tools, memória) | `bobmatnyc/claude-mpm-skills@local-llm-ops` | `npx skills add bobmatnyc/claude-mpm-skills@local-llm-ops -g -y` |
| Voice AI (Whisper STT + TTS) | `scientiacapital/skills@voice-ai` | `npx skills add scientiacapital/skills@voice-ai -g -y` |
| SwiftUI / macOS | `charleswiltgen/axiom@axiom-swiftui-26-ref` | `npx skills add charleswiltgen/axiom@axiom-swiftui-26-ref -g -y` |
| Xcode Build / Run | `cameroncooke/xcodebuildmcp@xcodebuildmcp` | `npx skills add cameroncooke/xcodebuildmcp@xcodebuildmcp -g -y` |

> ⚠️ A skill `inference-sh/agent-skills@ai-voice-cloning` foi removida — não é mais necessária com Piper TTS.

---

## 🗂️ Estrutura de Pastas

```
jarvis/
├── backend/
│   ├── main.py                  # FastAPI app principal
│   ├── jarvis_core.py           # Lógica central do JARVIS
│   ├── config.py                # Configurações e variáveis de ambiente
│   │
│   ├── stt/
│   │   ├── __init__.py
│   │   └── whisper_stt.py       # Speech-to-Text com Whisper
│   │
│   ├── tts/
│   │   ├── __init__.py
│   │   └── piper_tts.py         # Text-to-Speech com Piper (PT-BR)
│   │
│   ├── llm/
│   │   ├── __init__.py
│   │   └── ollama_client.py     # Cliente para Ollama (LLaMA 3.3)
│   │
│   ├── tools/
│   │   ├── __init__.py
│   │   ├── weather.py           # Ferramenta: previsão do tempo
│   │   ├── email_tool.py        # Ferramenta: envio de email
│   │   ├── report.py            # Ferramenta: geração de relatórios PDF
│   │   ├── calendar_tool.py     # Ferramenta: agenda/lembretes
│   │   └── web_search.py        # Ferramenta: busca na web
│   │
│   └── memory/
│       ├── __init__.py
│       └── conversation.py      # Gerenciamento de histórico/contexto
│
├── JarvisApp/                   # App nativo macOS (SwiftUI + Xcode)
│   ├── JarvisApp.swift          # Entry point do app
│   ├── ContentView.swift        # View principal (chat + microfone)
│   ├── Views/
│   │   ├── ChatView.swift       # Histórico de mensagens
│   │   ├── VoiceButton.swift    # Botão de microfone animado
│   │   └── StatusBar.swift      # Indicador de status do JARVIS
│   ├── Models/
│   │   └── Message.swift        # Model de mensagem
│   ├── Services/
│   │   └── JarvisService.swift  # Comunicação com o backend (FastAPI)
│   └── Assets.xcassets          # Ícones e assets do app
│
├── scripts/
│   ├── setup.sh                 # Script de instalação
│   └── download_models.py       # Download dos modelos de IA
│
├── models/
│   └── piper/                   # Modelos Piper TTS baixados aqui
│       ├── pt_BR-faber-medium.onnx
│       └── pt_BR-faber-medium.onnx.json
│
├── .env.example
├── requirements.txt
└── README.md
```

---

## 🛠️ Setup do Ambiente

### 1. Pré-requisitos

```bash
# Homebrew (se não tiver)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Python 3.12 (versão estável recomendada em 2026)
brew install python@3.12

# Node.js 20+ (para scripts de tooling)
brew install node

# Ollama (para rodar LLaMA localmente)
brew install ollama

# ffmpeg (necessário para processamento de áudio)
brew install ffmpeg

# Piper TTS — instalação via pip (não precisa de brew extra)
# Apenas o binário é instalado junto com o pacote Python
```

> **Nota:** `opus` e `portaudio` não são mais necessários — migramos para `sounddevice` que funciona nativamente no Apple Silicon sem dependências manuais.

### 2. Baixar os modelos

```bash
# LLaMA 3.3 8B via Ollama (melhor tool calling e PT-BR que o 3.1)
ollama pull llama3.3:8b

# Confirmar que está rodando
ollama run llama3.3:8b "Olá, responda em português!"

# Alternativa mais leve (3B params, muito mais rápido no M4):
# ollama pull llama3.2:3b
```

### 3. Baixar modelo Piper PT-BR

```bash
# Criar pasta para os modelos
mkdir -p backend/models/piper && cd backend/models/piper

# Baixar modelo pt_BR-faber-medium (~60MB — leve e bom para PT-BR)
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/faber/medium/pt_BR-faber-medium.onnx
wget https://huggingface.co/rhasspy/piper-voices/resolve/main/pt/pt_BR/faber/medium/pt_BR-faber-medium.onnx.json

cd ../..
```

### 4. Instalar dependências Python

```bash
cd backend
python3.12 -m venv venv
source venv/bin/activate

pip install -r requirements.txt
```

**requirements.txt:**
```txt
# API e servidor
fastapi==0.115.6
uvicorn[standard]==0.34.0
websockets==14.1
python-multipart==0.0.20
httpx==0.28.1

# LLM
ollama==0.4.7

# STT - Speech to Text
faster-whisper==1.1.0
sounddevice==0.5.1       # substitui pyaudio — funciona nativamente no M4
soundfile==0.12.1        # leitura/escrita de WAV

# TTS - Text to Speech (Piper)
piper-tts==1.2.0         # Mozilla/Rhasspy — leve, rápido, PT-BR nativo

# Ferramentas
requests==2.32.3
python-dotenv==1.0.1
reportlab==4.4.0         # Geração de PDF

# Google APIs
google-api-python-client==2.160.0
google-auth==2.40.0
google-auth-oauthlib==1.2.1
google-auth-httplib2==0.2.0

# Utilidades
pydantic==2.10.4
pydantic-settings==2.7.0  # OBRIGATÓRIO — usado em config.py
numpy==2.2.2
```

---

## 🧠 Implementação — Backend

### `config.py`

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # LLM
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "llama3.3:8b"

    # STT
    whisper_model: str = "large-v3"
    whisper_language: str = "pt"

    # TTS — Piper
    piper_model_path: str = "./models/piper/pt_BR-faber-medium.onnx"

    # Email (Gmail)
    gmail_user: str = ""
    gmail_app_password: str = ""  # Senha de app do Google

    # Clima
    openweather_api_key: str = ""  # API gratuita

    # Pydantic v2 — sintaxe moderna
    model_config = SettingsConfigDict(env_file=".env")

settings = Settings()
```

### `llm/ollama_client.py`

```python
import ollama
from config import settings

# Personalidade do JARVIS em português
JARVIS_SYSTEM_PROMPT = """Você é JARVIS (Just A Rather Very Intelligent System),
o assistente pessoal de inteligência artificial do usuário.

Personalidade:
- Responda SEMPRE em português brasileiro
- Seja direto, eficiente e levemente sofisticado
- Trate o usuário com respeito, como "senhor" ou pelo nome
- Seja proativo: antecipe necessidades quando possível
- Confirme ações antes de executá-las
- Mantenha respostas concisas para voz (máximo 3 frases diretas)"""

# Definição das ferramentas disponíveis para tool calling nativo do Ollama
JARVIS_TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Consulta a previsão do tempo de uma cidade",
            "parameters": {
                "type": "object",
                "properties": {
                    "city": {"type": "string", "description": "Nome da cidade"}
                },
                "required": ["city"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "send_email",
            "description": "Envia um email",
            "parameters": {
                "type": "object",
                "properties": {
                    "to":      {"type": "string", "description": "Endereço de destino"},
                    "subject": {"type": "string", "description": "Assunto do email"},
                    "body":    {"type": "string", "description": "Corpo do email"}
                },
                "required": ["to", "subject", "body"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "generate_report",
            "description": "Gera um relatório em PDF",
            "parameters": {
                "type": "object",
                "properties": {
                    "title":   {"type": "string", "description": "Título do relatório"},
                    "content": {"type": "object", "description": "Dados do relatório como chave-valor"}
                },
                "required": ["title", "content"]
            }
        }
    }
]

class OllamaClient:
    def __init__(self):
        self.client = ollama.Client(host=settings.ollama_base_url)
        self.model = settings.ollama_model

    def chat(self, messages: list[dict], tools: list | None = None) -> dict:
        """
        Retorna dict com 'content' (str) e 'tool_calls' (list | None).
        Usa tool calling nativo do Ollama — mais robusto que parsear JSON manual.
        """
        response = self.client.chat(
            model=self.model,
            messages=[
                {"role": "system", "content": JARVIS_SYSTEM_PROMPT},
                *messages
            ],
            tools=tools or JARVIS_TOOLS
        )
        msg = response['message']
        return {
            "content": msg.get('content', ''),
            "tool_calls": msg.get('tool_calls')  # None se não houver chamada de tool
        }

    def chat_stream(self, messages: list[dict]):
        """Para streaming de resposta em tempo real (sem tools)"""
        stream = self.client.chat(
            model=self.model,
            messages=[
                {"role": "system", "content": JARVIS_SYSTEM_PROMPT},
                *messages
            ],
            stream=True
        )
        for chunk in stream:
            content = chunk['message'].get('content', '')
            if content:
                yield content
```

### `stt/whisper_stt.py`

```python
from faster_whisper import WhisperModel
from config import settings
import sounddevice as sd
import soundfile as sf
import numpy as np
import tempfile
import os

class WhisperSTT:
    def __init__(self):
        # "auto" usa Metal no Mac M4 (Apple Silicon)
        self.model = WhisperModel(
            settings.whisper_model,
            device="auto",
            compute_type="int8"
        )
        print("✅ Whisper carregado (PT-BR)")

    def transcribe_file(self, audio_path: str) -> str:
        segments, info = self.model.transcribe(
            audio_path,
            language=settings.whisper_language,
            beam_size=5
        )
        return " ".join([seg.text for seg in segments]).strip()

    def record_and_transcribe(self, duration: int = 5) -> str:
        """Grava do microfone e transcreve"""
        audio_data = self._record_audio(duration)

        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            sf.write(f.name, audio_data, 16000)
            text = self.transcribe_file(f.name)
            os.unlink(f.name)

        return text

    def _record_audio(self, duration: int) -> np.ndarray:
        """Grava usando sounddevice — funciona nativamente no Apple Silicon"""
        RATE = 16000
        print(f"🎤 Gravando por {duration} segundos...")
        audio = sd.rec(
            int(duration * RATE),
            samplerate=RATE,
            channels=1,
            dtype='int16'
        )
        sd.wait()  # aguarda gravação terminar
        return audio
```

### `tts/piper_tts.py`

```python
import subprocess
import os
import tempfile
from config import settings

class PiperTTS:
    def __init__(self):
        self.model_path = settings.piper_model_path
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(
                f"Modelo Piper não encontrado em: {self.model_path}\n"
                "Execute: scripts/download_models.py para baixar."
            )
        print("✅ Piper TTS carregado (PT-BR)")

    def speak(self, text: str, output_path: str = "/tmp/jarvis_response.wav") -> str:
        """
        Converte texto em fala usando Piper via subprocess.
        Piper é extremamente rápido — latência ~100-300ms no M4.
        """
        # Piper recebe texto via stdin e gera WAV
        result = subprocess.run(
            [
                "piper",
                "--model", self.model_path,
                "--output_file", output_path
            ],
            input=text.encode("utf-8"),
            capture_output=True
        )
        if result.returncode != 0:
            raise RuntimeError(f"Piper falhou: {result.stderr.decode()}")
        return output_path

    def speak_and_play(self, text: str):
        """Sintetiza e reproduz diretamente usando afplay do Mac"""
        path = self.speak(text)
        os.system(f"afplay {path}")
```

### `tools/weather.py`

```python
import requests
from config import settings

class WeatherTool:
    BASE_URL = "https://api.openweathermap.org/data/2.5/weather"

    def get_weather(self, city: str) -> str:
        params = {
            "q": f"{city},BR",
            "appid": settings.openweather_api_key,
            "lang": "pt_br",
            "units": "metric"
        }
        response = requests.get(self.BASE_URL, params=params)
        data = response.json()

        if response.status_code == 200:
            temp = data["main"]["temp"]
            desc = data["weather"][0]["description"]
            city_name = data["name"]
            return f"Em {city_name}: {temp:.0f}°C, {desc}."
        return "Não consegui obter informações do clima."
```

### `tools/email_tool.py`

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from config import settings

class EmailTool:
    def send_email(self, to: str, subject: str, body: str) -> str:
        msg = MIMEMultipart()
        msg["From"] = settings.gmail_user
        msg["To"] = to
        msg["Subject"] = subject
        msg.attach(MIMEText(body, "plain", "utf-8"))

        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(settings.gmail_user, settings.gmail_app_password)
            server.send_message(msg)

        return f"Email enviado para {to} com sucesso."
```

### `tools/report.py`

```python
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from datetime import datetime

class ReportTool:
    def generate_report(self, title: str, content: dict, output_path: str = None) -> str:
        if not output_path:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = f"/tmp/relatorio_{timestamp}.pdf"

        c = canvas.Canvas(output_path, pagesize=A4)
        width, height = A4

        # Cabeçalho
        c.setFillColor(colors.HexColor("#1a1a2e"))
        c.rect(0, height - 80, width, 80, fill=True)
        c.setFillColor(colors.white)
        c.setFont("Helvetica-Bold", 22)
        c.drawString(40, height - 50, f"JARVIS — {title}")
        c.setFont("Helvetica", 10)
        c.drawString(40, height - 68, datetime.now().strftime("%d/%m/%Y %H:%M"))

        # Conteúdo
        c.setFillColor(colors.black)
        y = height - 120
        for key, value in content.items():
            c.setFont("Helvetica-Bold", 12)
            c.drawString(40, y, f"{key}:")
            y -= 18
            c.setFont("Helvetica", 11)
            c.drawString(60, y, str(value))
            y -= 25

        c.save()
        return output_path
```

### `jarvis_core.py`

```python
from llm.ollama_client import OllamaClient
from stt.whisper_stt import WhisperSTT
from tts.piper_tts import PiperTTS
from tools.weather import WeatherTool
from tools.email_tool import EmailTool
from tools.report import ReportTool
from memory.conversation import ConversationMemory

class JarvisCore:
    def __init__(self):
        print("🤖 Inicializando JARVIS...")
        self.llm = OllamaClient()
        self.stt = WhisperSTT()
        self.tts = PiperTTS()
        self.memory = ConversationMemory(max_messages=20)

        # Ferramentas disponíveis — mapeadas pelo nome usado no tool calling
        self._weather = WeatherTool()
        self._email   = EmailTool()
        self._report  = ReportTool()

        self.tools = {
            "get_weather":     self._weather.get_weather,
            "send_email":      self._email.send_email,
            "generate_report": self._report.generate_report,
        }
        print("✅ JARVIS pronto!")

    def process_text(self, user_input: str) -> str:
        """Processa texto e retorna resposta"""
        self.memory.add_user_message(user_input)

        result = self.llm.chat(self.memory.get_messages())

        # Tool calling nativo do Ollama — mais robusto que parsear JSON manual
        if result["tool_calls"]:
            tool_results = []
            for tool_call in result["tool_calls"]:
                tool_name = tool_call["function"]["name"]
                params    = tool_call["function"]["arguments"]

                if tool_name in self.tools:
                    tool_result = self.tools[tool_name](**params)
                    tool_results.append(f"[{tool_name}]: {tool_result}")
                    print(f"🔧 Tool executada: {tool_name} → {tool_result}")

            # Passa o resultado das tools de volta ao LLM para resposta natural
            tools_summary = "\n".join(tool_results)
            self.memory.add_assistant_message(f"[Ferramentas executadas:\n{tools_summary}]")
            final_result = self.llm.chat(
                self.memory.get_messages() + [
                    {"role": "user", "content": "Informe o resultado de forma natural e breve em português."}
                ]
            )
            final_response = final_result["content"]
            self.memory.add_assistant_message(final_response)
            return final_response

        # Resposta conversacional simples
        response = result["content"]
        self.memory.add_assistant_message(response)
        return response

    def process_voice(self) -> tuple[str, str]:
        """Grava voz, processa e responde por áudio"""
        user_text = self.stt.record_and_transcribe(duration=5)
        print(f"👤 Você: {user_text}")

        response = self.process_text(user_text)
        print(f"🤖 JARVIS: {response}")

        self.tts.speak_and_play(response)
        return user_text, response
```

### `memory/conversation.py`

```python
from collections import deque

class ConversationMemory:
    def __init__(self, max_messages: int = 20):
        self.messages = deque(maxlen=max_messages)

    def add_user_message(self, content: str):
        self.messages.append({"role": "user", "content": content})

    def add_assistant_message(self, content: str):
        self.messages.append({"role": "assistant", "content": content})

    def get_messages(self) -> list[dict]:
        return list(self.messages)

    def clear(self):
        self.messages.clear()
```

### `main.py` — FastAPI Server

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from jarvis_core import JarvisCore
import tempfile, os

# --- Lifespan: carrega modelos no startup, evita instância global ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.jarvis = JarvisCore()  # carrega Whisper + Piper + Ollama client
    yield
    # cleanup se necessário

app = FastAPI(title="JARVIS API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Request model com tipagem ---
class ChatRequest(BaseModel):
    message: str

@app.post("/chat/text")
async def chat_text(payload: ChatRequest, request: Request):
    """Endpoint de chat por texto"""
    jarvis: JarvisCore = request.app.state.jarvis
    response = jarvis.process_text(payload.message)
    return {"response": response}

@app.post("/chat/voice")
async def chat_voice(audio: UploadFile = File(...), request: Request = None):
    """Recebe áudio, transcreve e retorna resposta em áudio"""
    jarvis: JarvisCore = request.app.state.jarvis

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
        f.write(await audio.read())
        audio_path = f.name

    user_text = jarvis.stt.transcribe_file(audio_path)
    os.unlink(audio_path)

    response_text  = jarvis.process_text(user_text)
    response_audio = jarvis.tts.speak(response_text)

    return FileResponse(
        response_audio,
        media_type="audio/wav",
        headers={
            "X-Transcription": user_text,
            "X-Response": response_text
        }
    )

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket para streaming de resposta"""
    jarvis: JarvisCore = websocket.app.state.jarvis
    await websocket.accept()
    while True:
        data = await websocket.receive_json()
        user_input = data.get("message", "")

        for chunk in jarvis.llm.chat_stream(
            jarvis.memory.get_messages() + [{"role": "user", "content": user_input}]
        ):
            await websocket.send_json({"chunk": chunk})

        await websocket.send_json({"done": True})

@app.delete("/memory")
async def clear_memory(request: Request):
    request.app.state.jarvis.memory.clear()
    return {"message": "Memória limpa com sucesso."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

---

## 🖥️ MVP — Interface Terminal

Para testar rapidamente sem o frontend:

```python
# run_terminal.py
from jarvis_core import JarvisCore

def main():
    jarvis = JarvisCore()
    print("\n🤖 JARVIS ativo. Digite sua mensagem ou 'voz' para falar.")
    print("Digite 'sair' para encerrar.\n")

    while True:
        user_input = input("Você: ").strip()

        if user_input.lower() == "sair":
            print("JARVIS: Até logo, senhor.")
            break
        elif user_input.lower() == "voz":
            jarvis.process_voice()
        else:
            response = jarvis.process_text(user_input)
            print(f"JARVIS: {response}\n")

if __name__ == "__main__":
    main()
```

---

## 🖥️ App nativo macOS (SwiftUI)

A interface é um app macOS nativo construído com **SwiftUI + Xcode**. O app se comunica com o backend Python via HTTP (FastAPI) e expõe dois modos de interação: **chat por texto** e **microfone**.

> **Pré-requisito:** Xcode instalado (gratuito na Mac App Store)

---

### Design da interface

```
┌─────────────────────────────────────┐
│  ⚡ J.A.R.V.I.S.          🟢 Ativo │
├─────────────────────────────────────┤
│                                     │
│  [JARVIS] Olá! Como posso ajudar?  │
│                                     │
│         [Você] Qual é o clima?     │
│                                     │
│  [JARVIS] Em São Paulo: 24°C,      │
│           parcialmente nublado.     │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  [Digite uma mensagem...] [Enviar] │
│            🎤 Microfone            │
└─────────────────────────────────────┘
```

---

### `JarvisService.swift` — Comunicação com o backend

```swift
import Foundation
import Observation

// @Observable é o padrão moderno em Swift 5.9+ / macOS 14+
// Substitui ObservableObject + @Published
@Observable
class JarvisService {
    private let baseURL = "http://localhost:8000"
    var isLoading = false

    func sendMessage(_ text: String) async throws -> String {
        let url = URL(string: "\(baseURL)/chat/text")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["message": text])

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        return json["response"] as? String ?? ""
    }

    func sendAudio(_ audioURL: URL) async throws -> (transcription: String, response: String) {
        let url = URL(string: "\(baseURL)/chat/voice")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"audio\"; filename=\"voice.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        body.append(try Data(contentsOf: audioURL))
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (_, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as! HTTPURLResponse
        let transcription = httpResponse.value(forHTTPHeaderField: "X-Transcription") ?? ""
        let jarvisResponse = httpResponse.value(forHTTPHeaderField: "X-Response") ?? ""
        return (transcription, jarvisResponse)
    }
}
```

---

### `ContentView.swift` — View principal

```swift
import SwiftUI
import AVFoundation

struct ContentView: View {
    // @State com @Observable — padrão moderno Swift 5.9+
    @State private var service = JarvisService()
    @State private var messages: [Message] = [
        Message(role: .assistant, text: "Olá! Sou JARVIS. Como posso ajudar, senhor?")
    ]
    @State private var inputText = ""
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("⚡ J.A.R.V.I.S.")
                    .font(.headline)
                    .bold()
                Spacer()
                Circle()
                    .fill(service.isLoading ? Color.yellow : Color.green)
                    .frame(width: 10, height: 10)
                Text(service.isLoading ? "Pensando..." : "Ativo")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Chat
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { msg in
                            ChatBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                // Sintaxe correta para macOS 14+ / Swift 5.9+
                .onChange(of: messages.count) { oldValue, newValue in
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }

            Divider()

            // Input bar
            HStack(spacing: 12) {
                TextField("Digite uma mensagem...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { sendText() }

                Button("Enviar") { sendText() }
                    .disabled(inputText.isEmpty || service.isLoading)

                Button {
                    isRecording ? stopRecording() : startRecording()
                } label: {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .foregroundColor(isRecording ? .red : .blue)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 550)
    }

    func sendText() {
        guard !inputText.isEmpty else { return }
        let text = inputText
        inputText = ""
        messages.append(Message(role: .user, text: text))
        service.isLoading = true

        Task {
            do {
                let response = try await service.sendMessage(text)
                await MainActor.run {
                    messages.append(Message(role: .assistant, text: response))
                    service.isLoading = false
                }
            } catch {
                await MainActor.run { service.isLoading = false }
            }
        }
    }

    func startRecording() {
        isRecording = true
        // TODO: implementar AVAudioRecorder
        // Requer permissão de microfone no Info.plist:
        // NSMicrophoneUsageDescription → "JARVIS precisa do microfone para ouvir comandos de voz"
    }

    func stopRecording() {
        isRecording = false
        // TODO: parar AVAudioRecorder e enviar WAV para /chat/voice via service.sendAudio()
    }
}
```

---

### `Models/Message.swift`

```swift
import Foundation

enum MessageRole { case user, assistant }

struct Message: Identifiable {
    let id = UUID()
    let role: MessageRole
    let text: String
}
```

---

### `Views/ChatBubble.swift`

```swift
import SwiftUI

struct ChatBubble: View {
    let message: Message

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer() }
            Text(message.text)
                .padding(10)
                .background(isUser ? Color.blue : Color(NSColor.controlBackgroundColor))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(12)
                .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
            if !isUser { Spacer() }
        }
    }
}
```

---

### Como rodar o app

```bash
# 1. Garantir que o backend está rodando primeiro
cd backend && python main.py

# 2. Abrir o projeto no Xcode
open ../JarvisApp/JarvisApp.xcodeproj

# 3. Selecionar target "My Mac" e rodar (Cmd+R)

# ⚠️ Info.plist — adicionar permissão de microfone:
# NSMicrophoneUsageDescription → "JARVIS precisa do microfone para ouvir comandos de voz"
```

---

## 🗺️ Roadmap de Desenvolvimento

### Fase 1 — MVP Texto (Semana 1)

> 🧩 **Skills para instalar antes de começar:**
> ```bash
> npx skills add bobmatnyc/claude-mpm-skills@local-llm-ops -g -y
> npx skills add yonatangross/orchestkit@ollama-local -g -y
> npx skills add mindrally/skills@fastapi-python -g -y
> ```

- [ ] Setup do ambiente (Ollama + Python 3.12)
- [ ] `ollama_client.py` com personalidade JARVIS e tool calling nativo — *`local-llm-ops` · `ollama-local`*
- [ ] `conversation.py` para memória — *`local-llm-ops`*
- [ ] `run_terminal.py` para testes
- [ ] Tool: clima (OpenWeatherMap) — *`fastapi-python`*
- [ ] Tool: envio de email — *`fastapi-python`*

### Fase 2 — Voz Local (Semana 2)

> 🧩 **Skills para instalar antes de começar:**
> ```bash
> npx skills add scientiacapital/skills@voice-ai -g -y
> ```

- [ ] `whisper_stt.py` — transcrição PT-BR com sounddevice — *`voice-ai` (pipeline STT, VAD)*
- [ ] `piper_tts.py` — síntese de voz PT-BR com Piper — *`voice-ai` (pipeline TTS, output de áudio)*
- [ ] Download do modelo `pt_BR-faber-medium` (~60MB)
- [ ] Integrar voz no `jarvis_core.py` — *`voice-ai`*

### Fase 3 — App macOS (Semana 3)

> 🧩 **Skills para instalar antes de começar:**
> ```bash
> npx skills add mindrally/skills@fastapi-python -g -y
> npx skills add thebushidocollective/han@fastapi-async-patterns -g -y
> npx skills add charleswiltgen/axiom@axiom-swiftui-26-ref -g -y
> npx skills add cameroncooke/xcodebuildmcp@xcodebuildmcp -g -y
> ```

- [ ] `main.py` FastAPI com lifespan, endpoints REST e WebSocket — *`fastapi-python` · `fastapi-async-patterns`*
- [ ] Projeto Xcode com SwiftUI usando `@Observable` — *`axiom-swiftui-26-ref` · `xcodebuildmcp`*
- [ ] Botão de microfone com `AVAudioRecorder` + permissão `NSMicrophoneUsageDescription` — *`axiom-swiftui-26-ref`*
- [ ] Input de texto com histórico de chat — *`axiom-swiftui-26-ref`*
- [ ] Integração completa app ↔ backend — *`fastapi-python` · `axiom-swiftui-26-ref`*

### Fase 4 — Ferramentas Avançadas (Semana 4+)

> 🧩 **Skills para instalar antes de começar:**
> ```bash
> npx skills add mindrally/skills@fastapi-python -g -y
> npx skills add scientiacapital/skills@voice-ai -g -y
> npx skills add cameroncooke/xcodebuildmcp@xcodebuildmcp -g -y
> ```

- [ ] Google Calendar API — *`fastapi-python` (OAuth flow, endpoints)*
- [ ] Geração de relatórios PDF — *`fastapi-python` (FileResponse, multipart)*
- [ ] Busca na web (DuckDuckGo, sem API key) — *`fastapi-python` (tool structure)*
- [ ] Notificações Mac (usando `osascript`) — *`xcodebuildmcp`*
- [ ] Wake word "Ei JARVIS" (usando Porcupine ou Picovoice) — *`voice-ai` (VAD, wake word detection)*

---

## 🔧 Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
# LLM
OLLAMA_MODEL=llama3.3:8b
OLLAMA_BASE_URL=http://localhost:11434

# STT
WHISPER_MODEL=large-v3

# TTS — Piper
PIPER_MODEL_PATH=./models/piper/pt_BR-faber-medium.onnx

# Email (Gmail — use Senha de App, não a senha normal)
GMAIL_USER=seu@gmail.com
GMAIL_APP_PASSWORD=xxxx-xxxx-xxxx-xxxx

# Clima
OPENWEATHER_API_KEY=sua_chave_aqui
```

> **Como obter Gmail App Password:**
> Conta Google → Segurança → Verificação em duas etapas → Senhas de app

---

## ⚡ Como Iniciar o Projeto

```bash
# 1. Clone / crie a estrutura
mkdir jarvis && cd jarvis

# 2. Inicie o Ollama em background
ollama serve &

# 3. Ative o ambiente Python
cd backend
source venv/bin/activate

# 4. MVP rápido (só texto, sem voz)
python run_terminal.py

# 5. Inicie o servidor completo
python main.py
# API disponível em: http://localhost:8000
# Docs automáticas em: http://localhost:8000/docs

# 6. Abra o app macOS no Xcode
open ../JarvisApp/JarvisApp.xcodeproj
# Selecione "My Mac" e pressione Cmd+R
```

---

## 📊 Recursos de Hardware (Mac M4)

| Componente | RAM usada | Notas |
|---|---|---|
| LLaMA 3.3 8B (Ollama) | ~5-6 GB | Roda via Metal (Apple Silicon) |
| Whisper large-v3 | ~1.5 GB | Roda via MPS no M4 |
| Piper TTS | ~60 MB | CPU — extremamente leve ✅ |
| **Total estimado** | **~7-8 GB** | Mac M4 com 16GB RAM: OK ✅ |

> 💡 Migrar de Coqui (~2GB) para Piper (~60MB) liberou ~1.5GB de RAM — mais fôlego para o LLM.

---

## 🔮 Upgrade Futuro: Kokoro TTS

Quando quiser qualidade de voz superior mantendo custo zero, a migração de Piper para Kokoro é simples:

```python
# Trocar apenas a camada de TTS
# De: PiperTTS (~60MB, voz boa)
# Para: Kokoro (~300MB, voz muito mais natural)

# A lógica de ferramentas, memória e LLM permanece igual
# piper_tts.py → kokoro_tts.py (trocar subprocess por kokoro API Python)
```

Kokoro ainda tem suporte limitado a PT-BR em 2026 — aguardar novos modelos da comunidade.

---

## 📚 Referências

- [Ollama Docs](https://ollama.com/docs)
- [faster-whisper GitHub](https://github.com/SYSTRAN/faster-whisper)
- [Piper TTS GitHub](https://github.com/rhasspy/piper)
- [Piper Voices — PT-BR](https://huggingface.co/rhasspy/piper-voices/tree/main/pt/pt_BR)
- [OpenWeatherMap API](https://openweathermap.org/api)
- [FastAPI Docs](https://fastapi.tiangolo.com)
- [sounddevice Docs](https://python-sounddevice.readthedocs.io)