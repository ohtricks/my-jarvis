import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from config import settings


class EmailTool:
    def send_email(self, to: str, subject: str, body: str) -> str:
        if not settings.gmail_user or not settings.gmail_app_password:
            return "Credenciais de email não configuradas. Defina GMAIL_USER e GMAIL_APP_PASSWORD no .env"

        msg = MIMEMultipart()
        msg["From"] = settings.gmail_user
        msg["To"] = to
        msg["Subject"] = subject
        msg.attach(MIMEText(body, "plain", "utf-8"))

        try:
            with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
                server.login(settings.gmail_user, settings.gmail_app_password)
                server.send_message(msg)
            return f"Email enviado para {to} com sucesso."
        except smtplib.SMTPAuthenticationError:
            return "Erro de autenticação. Verifique a senha de app do Gmail."
        except smtplib.SMTPException as e:
            return f"Erro ao enviar email: {e}"
