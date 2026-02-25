from datetime import datetime

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas


class ReportTool:
    def generate_report(
        self, title: str, content: dict, output_path: str = None
    ) -> str:
        if not output_path:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = f"/tmp/relatorio_{timestamp}.pdf"

        c = canvas.Canvas(output_path, pagesize=A4)
        width, height = A4

        # Cabeçalho
        c.setFillColor(colors.HexColor("#1a1a2e"))
        c.rect(0, height - 80, width, 80, fill=True)
        c.setFillColor(colors.white)
        c.setFont("Helvetica-Bold", 22)
        c.drawString(40, height - 50, f"JARVIS — {title}")
        c.setFont("Helvetica", 10)
        c.drawString(40, height - 68, datetime.now().strftime("%d/%m/%Y %H:%M"))

        # Conteúdo
        c.setFillColor(colors.black)
        y = height - 120
        for key, value in content.items():
            if y < 60:
                c.showPage()
                y = height - 60
            c.setFont("Helvetica-Bold", 12)
            c.drawString(40, y, f"{key}:")
            y -= 18
            c.setFont("Helvetica", 11)
            # Quebra texto longo
            text = str(value)
            if len(text) > 80:
                for line in [text[i : i + 80] for i in range(0, len(text), 80)]:
                    c.drawString(60, y, line)
                    y -= 16
            else:
                c.drawString(60, y, text)
                y -= 25

        c.save()
        return output_path
