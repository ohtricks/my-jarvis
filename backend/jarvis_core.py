import json

from llm.ollama_client import OllamaClient
from memory.conversation import ConversationMemory
from stt.whisper_stt import WhisperSTT
from tools.email_tool import EmailTool
from tools.report import ReportTool
from tools.weather import WeatherTool
from tools.web_search import WebSearchTool
from tts.piper_tts import PiperTTS


class JarvisCore:
    def __init__(self):
        print("🤖 Inicializando JARVIS...")
        self.llm = OllamaClient()
        self.memory = ConversationMemory(max_messages=20)
        self.stt = WhisperSTT()
        self.tts = PiperTTS()

        # Ferramentas disponíveis
        weather = WeatherTool()
        email = EmailTool()
        report = ReportTool()
        search = WebSearchTool()

        self.tools: dict = {
            "get_weather": weather.get_weather,
            "send_email": email.send_email,
            "generate_report": report.generate_report,
            "web_search": search.search,
        }
        print("✅ JARVIS pronto!")

    def process_text(self, user_input: str) -> str:
        """Processa mensagem de texto e retorna resposta."""
        self.memory.add_user_message(user_input)

        response = self.llm.chat(self.memory.get_messages())

        # Verifica se o LLM quer chamar uma ferramenta (resposta JSON)
        stripped = response.strip()
        if stripped.startswith("{"):
            try:
                tool_call = json.loads(stripped)
                tool_name = tool_call.get("tool")
                params = tool_call.get("params", {})

                if tool_name in self.tools:
                    result = self.tools[tool_name](**params)
                    # Pede ao LLM para formatar o resultado em linguagem natural
                    self.memory.add_assistant_message(
                        f"[Ferramenta '{tool_name}' executada. Resultado: {result}]"
                    )
                    final_response = self.llm.chat(
                        self.memory.get_messages()
                        + [
                            {
                                "role": "user",
                                "content": "Informe o resultado de forma natural e breve em português.",
                            }
                        ]
                    )
                    self.memory.add_assistant_message(final_response)
                    return final_response
                else:
                    response = f"Ferramenta '{tool_name}' não disponível nesta versão."
            except json.JSONDecodeError:
                pass  # Não era JSON — continua como resposta normal

        self.memory.add_assistant_message(response)
        return response

    def process_text_stream(self, user_input: str):
        """Streaming de resposta para WebSocket."""
        self.memory.add_user_message(user_input)
        full_response = ""

        for chunk in self.llm.chat_stream(self.memory.get_messages()):
            full_response += chunk
            yield chunk

        self.memory.add_assistant_message(full_response)

    def process_voice(self, duration: int = 5) -> tuple[str, str]:
        """Grava voz, processa e responde em áudio. Retorna (texto_usuário, resposta)."""
        user_text = self.stt.record_and_transcribe(duration=duration)
        if not user_text:
            return ("", "Não entendi. Pode repetir?")

        print(f"Você (voz): {user_text}")
        response = self.process_text(user_text)
        print(f"JARVIS: {response}")
        self.tts.speak_and_play(response)
        return (user_text, response)

    def process_audio_file(self, audio_path: str) -> tuple[str, str]:
        """Transcreve arquivo de áudio e responde. Para uso via API REST."""
        user_text = self.stt.transcribe_file(audio_path)
        if not user_text:
            return ("", "Não entendi o áudio enviado.")
        response = self.process_text(user_text)
        return (user_text, response)
