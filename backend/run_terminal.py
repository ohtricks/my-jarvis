#!/usr/bin/env python3
"""
MVP terminal do JARVIS — Fase 1.
Uso: python run_terminal.py
"""
import sys
import os

# Garante que o backend está no path
sys.path.insert(0, os.path.dirname(__file__))

from jarvis_core import JarvisCore


def main():
    print("\n" + "=" * 50)
    print("  🤖 J.A.R.V.I.S. — Assistente Pessoal PT-BR")
    print("=" * 50)

    jarvis = JarvisCore()

    print("\nComandos especiais:")
    print("  'limpar'  — apaga o histórico da conversa")
    print("  'sair'    — encerra o JARVIS")
    print("-" * 50 + "\n")

    while True:
        try:
            user_input = input("Você: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nJARVIS: Até logo, senhor.")
            break

        if not user_input:
            continue

        if user_input.lower() in ("sair", "exit", "quit"):
            print("JARVIS: Até logo, senhor. Encerrando sistemas.")
            break

        if user_input.lower() == "limpar":
            jarvis.memory.clear()
            print("JARVIS: Memória limpa. Como posso ajudar?\n")
            continue

        response = jarvis.process_text(user_input)
        print(f"JARVIS: {response}\n")


if __name__ == "__main__":
    main()
