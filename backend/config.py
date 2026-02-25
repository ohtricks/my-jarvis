from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # LLM
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "llama3.1:8b"

    # STT
    whisper_model: str = "large-v3"
    whisper_language: str = "pt"

    # TTS
    tts_model: str = "tts_models/multilingual/multi-dataset/xtts_v2"
    tts_language: str = "pt"
    voice_sample_path: str = "./voices/jarvis_voice_sample.wav"

    # Email (Gmail)
    gmail_user: str = ""
    gmail_app_password: str = ""  # Senha de app do Google

    # Clima
    openweather_api_key: str = ""  # API gratuita openweathermap.org

    class Config:
        env_file = ".env"


settings = Settings()
