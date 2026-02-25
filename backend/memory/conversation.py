from collections import deque


class ConversationMemory:
    def __init__(self, max_messages: int = 20):
        self.messages: deque[dict] = deque(maxlen=max_messages)

    def add_user_message(self, content: str):
        self.messages.append({"role": "user", "content": content})

    def add_assistant_message(self, content: str):
        self.messages.append({"role": "assistant", "content": content})

    def get_messages(self) -> list[dict]:
        return list(self.messages)

    def clear(self):
        self.messages.clear()

    def __len__(self) -> int:
        return len(self.messages)
