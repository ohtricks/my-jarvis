"""
Text-to-Speech com Coqui XTTS-v2.
Implementado na Fase 2. Requer Python 3.12 + pip install TTS
"""


class CoquiTTS:
    def __init__(self):
        raise NotImplementedError(
            "CoquiTTS será implementado na Fase 2. "
            "Requer Python 3.12 e: pip install TTS"
        )

    def speak(self, text: str, output_path: str = "/tmp/jarvis_response.wav") -> str: ...

    def speak_and_play(self, text: str): ...
