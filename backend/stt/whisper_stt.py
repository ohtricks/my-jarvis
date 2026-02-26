import os
import tempfile

import numpy as np
import sounddevice as sd
import soundfile as sf
from faster_whisper import WhisperModel

from config import settings

SAMPLE_RATE = 16000


class WhisperSTT:
    def __init__(self):
        print("🎙️ Carregando Whisper large-v3 (primeira vez pode demorar)...")
        self.model = WhisperModel(
            settings.whisper_model,   # "large-v3"
            device="auto",            # Metal no Mac M4
            compute_type="int8",
        )
        print("✅ Whisper pronto!")

    def transcribe_file(self, audio_path: str) -> str:
        """Transcreve um arquivo de áudio em português."""
        segments, _ = self.model.transcribe(
            audio_path,
            language=settings.whisper_language,  # "pt"
            beam_size=5,
        )
        return " ".join(seg.text for seg in segments).strip()

    def record_and_transcribe(self, duration: int = 5) -> str:
        """Grava áudio pelo microfone e transcreve."""
        print(f"🔴 Gravando {duration}s... fale agora!")
        audio = sd.rec(
            int(duration * SAMPLE_RATE),
            samplerate=SAMPLE_RATE,
            channels=1,
            dtype="int16",
        )
        sd.wait()
        print("⏹️ Gravação finalizada. Transcrevendo...")

        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f:
            sf.write(f.name, audio, SAMPLE_RATE)
            try:
                text = self.transcribe_file(f.name)
            finally:
                os.unlink(f.name)

        return text
