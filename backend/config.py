from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # LLM
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "llama3.1:8b"

    # STT
    whisper_model: str = "large-v3"
    whisper_language: str = "pt"

    # TTS (Piper)
    piper_model_path: str = "./models/piper/pt_BR-faber-medium.onnx"

    # Email (Gmail)
    gmail_user: str = ""
    gmail_app_password: str = ""  # Senha de app do Google

    # Clima
    openweather_api_key: str = ""  # API gratuita openweathermap.org

    class Config:
        env_file = ".env"


settings = Settings()
