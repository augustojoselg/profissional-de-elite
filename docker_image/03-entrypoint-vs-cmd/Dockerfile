# Dockerfile para processamento de vídeos com FFmpeg
FROM ubuntu:22.04

# Evitar prompts interativos durante instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependências e FFmpeg
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Criar diretórios de trabalho
RUN mkdir -p /videos /output /app

# Copiar script de conversão
COPY convert.sh /app/convert.sh

# Tornar o script executável
RUN chmod +x /app/convert.sh

# Definir diretório de trabalho
WORKDIR /app

# ENTRYPOINT define o comando base que sempre será executado
# Permite que argumentos sejam passados dinamicamente
ENTRYPOINT ["./convert.sh"]

# CMD fornece argumentos padrão quando nenhum é fornecido
# Será sobrescrito se argumentos forem passados ao rodar o container
CMD ["--help"]
