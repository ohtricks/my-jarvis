import requests
from config import settings


class WeatherTool:
    BASE_URL = "https://api.openweathermap.org/data/2.5/weather"

    def get_weather(self, city: str) -> str:
        if not settings.openweather_api_key:
            return "Chave da API OpenWeatherMap não configurada. Defina OPENWEATHER_API_KEY no .env"

        params = {
            "q": f"{city},BR",
            "appid": settings.openweather_api_key,
            "lang": "pt_br",
            "units": "metric",
        }
        try:
            response = requests.get(self.BASE_URL, params=params, timeout=10)
            data = response.json()

            if response.status_code == 200:
                temp = data["main"]["temp"]
                feels_like = data["main"]["feels_like"]
                desc = data["weather"][0]["description"]
                humidity = data["main"]["humidity"]
                city_name = data["name"]
                return (
                    f"Em {city_name}: {temp:.0f}°C (sensação {feels_like:.0f}°C), "
                    f"{desc}, umidade {humidity}%."
                )
            elif response.status_code == 404:
                return f"Cidade '{city}' não encontrada."
            else:
                return "Não consegui obter informações do clima no momento."
        except requests.RequestException:
            return "Erro ao conectar com o serviço de clima."
