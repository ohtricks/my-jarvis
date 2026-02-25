import requests


class WebSearchTool:
    """Busca na web via DuckDuckGo (sem API key, sem rastreamento)."""

    BASE_URL = "https://api.duckduckgo.com/"

    def search(self, query: str) -> str:
        try:
            params = {"q": query, "format": "json", "no_html": "1", "skip_disambig": "1"}
            response = requests.get(self.BASE_URL, params=params, timeout=10)
            data = response.json()

            # Resposta direta (Abstract)
            if data.get("AbstractText"):
                source = data.get("AbstractSource", "")
                return f"{data['AbstractText']} (Fonte: {source})"

            # Resultados relacionados
            related = data.get("RelatedTopics", [])
            if related:
                results = []
                for item in related[:3]:
                    if isinstance(item, dict) and item.get("Text"):
                        results.append(item["Text"])
                if results:
                    return " | ".join(results)

            return f"Não encontrei resultados diretos para '{query}'."
        except requests.RequestException:
            return "Erro ao realizar busca na web."
