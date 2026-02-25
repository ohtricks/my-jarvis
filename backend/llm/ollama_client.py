import ollama
from config import settings

JARVIS_SYSTEM_PROMPT = """Você é JARVIS (Just A Rather Very Intelligent System),
o assistente pessoal de inteligência artificial do usuário.

Personalidade:
- Responda SEMPRE em português brasileiro
- Seja direto, eficiente e levemente sofisticado
- Trate o usuário com respeito, como "senhor" ou pelo nome
- Seja proativo: antecipe necessidades quando possível
- Confirme ações antes de executá-las
- Mantenha respostas concisas para voz (máximo 3 frases diretas)

Capacidades disponíveis via ferramentas:
- Consultar previsão do tempo
- Enviar emails
- Gerar relatórios em PDF
- Pesquisar na web

Ao receber um pedido que requer uma ferramenta, identifique qual usar e
retorne SOMENTE um JSON válido no formato: {"tool": "nome_da_tool", "params": {...}}
Para respostas de conversa simples, responda normalmente em texto."""


class OllamaClient:
    def __init__(self):
        self.client = ollama.Client(host=settings.ollama_base_url)
        self.model = settings.ollama_model

    def chat(self, messages: list[dict]) -> str:
        response = self.client.chat(
            model=self.model,
            messages=[
                {"role": "system", "content": JARVIS_SYSTEM_PROMPT},
                *messages,
            ],
        )
        return response["message"]["content"]

    def chat_stream(self, messages: list[dict]):
        """Streaming de resposta em tempo real."""
        stream = self.client.chat(
            model=self.model,
            messages=[
                {"role": "system", "content": JARVIS_SYSTEM_PROMPT},
                *messages,
            ],
            stream=True,
        )
        for chunk in stream:
            yield chunk["message"]["content"]
