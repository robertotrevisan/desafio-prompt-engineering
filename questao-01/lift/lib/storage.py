import os


def get_database_url() -> str:
    """Retorna a DATABASE_URL do ambiente."""
    db_url = os.environ.get("DATABASE_URL")
    if not db_url:
        raise EnvironmentError("DATABASE_URL não definida")
    return db_url
