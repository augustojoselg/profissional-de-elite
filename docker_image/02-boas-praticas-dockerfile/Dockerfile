# Use uma imagem específica e slim para reduzir tamanho
FROM python:3.11-slim

# Define variáveis de ambiente para otimizar Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Cria usuário não-root para segurança
RUN useradd --create-home --shell /bin/bash app

# Define diretório de trabalho
WORKDIR /app

# Instala dependências do sistema se necessário
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copia apenas requirements primeiro para aproveitar cache de layers
COPY requirements.txt .

# Instala dependências Python
RUN pip install --no-cache-dir -r requirements.txt

# Copia código da aplicação
COPY --chown=app:app . .

# Muda para usuário não-root
USER app

# Expõe a porta
EXPOSE 8000

# Comando padrão
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
