import os
import subprocess
import tempfile

from config import settings


class PiperTTS:
    def __init__(self):
        model = os.path.abspath(settings.piper_model_path)
        if not os.path.exists(model):
            raise FileNotFoundError(
                f"Modelo Piper não encontrado em: {model}\n"
                "Execute o download: veja scripts/download_models.py"
            )
        self.model_path = model
        print("✅ Piper TTS pronto!")

    def speak(self, text: str, output_path: str = None) -> str:
        """Sintetiza texto para arquivo WAV. Retorna o caminho do arquivo."""
        if not output_path:
            tmp = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
            output_path = tmp.name
            tmp.close()

        result = subprocess.run(
            ["piper", "--model", self.model_path, "--output_file", output_path],
            input=text.encode("utf-8"),
            capture_output=True,
        )
        if result.returncode != 0:
            raise RuntimeError(f"Piper falhou: {result.stderr.decode()}")

        return output_path

    def speak_and_play(self, text: str):
        """Sintetiza e reproduz o áudio diretamente no Mac."""
        path = self.speak(text)
        try:
            os.system(f"afplay '{path}'")
        finally:
            os.unlink(path)
