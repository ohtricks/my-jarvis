import json

from llm.ollama_client import OllamaClient
from memory.conversation import ConversationMemory
from tools.email_tool import EmailTool
from tools.report import ReportTool
from tools.weather import WeatherTool
from tools.web_search import WebSearchTool


class JarvisCore:
    def __init__(self):
        print("🤖 Inicializando JARVIS...")
        self.llm = OllamaClient()
        self.memory = ConversationMemory(max_messages=20)

        # Ferramentas disponíveis (Fase 1)
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
        """Versão streaming de process_text (para WebSocket)."""
        self.memory.add_user_message(user_input)
        full_response = ""

        for chunk in self.llm.chat_stream(self.memory.get_messages()):
            full_response += chunk
            yield chunk

        self.memory.add_assistant_message(full_response)
