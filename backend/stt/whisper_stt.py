"""
Speech-to-Text com Whisper (faster-whisper).
Implementado na Fase 2. Requer: pip install faster-whisper sounddevice
"""


class WhisperSTT:
    def __init__(self):
        raise NotImplementedError(
            "WhisperSTT será implementado na Fase 2. "
            "Execute: pip install faster-whisper sounddevice"
        )

    def transcribe_file(self, audio_path: str) -> str: ...

    def record_and_transcribe(self, duration: int = 5) -> str: ...
