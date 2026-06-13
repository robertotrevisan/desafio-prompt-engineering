import os


def get_api_key() -> str:
    """Retorna a API_KEY do ambiente."""
    api_key = os.environ.get("API_KEY")
    if not api_key:
        raise EnvironmentError("API_KEY não definida")
    return api_key


def validate_token(token: str) -> bool:
    """Valida um token comparando com a API_KEY configurada."""
    return token == get_api_key()
