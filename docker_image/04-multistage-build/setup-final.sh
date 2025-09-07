#!/bin/bash

echo "🚀 Rota42 Video Converter - Setup Multistage Build"
echo "=================================================="

# Criar estrutura de diretórios
echo "📁 Criando estrutura de diretórios..."
mkdir -p cmd input output temp logs

# Verificar se os arquivos Go existem
if [ ! -f "cmd/main.go" ]; then
    echo "❌ Erro: cmd/main.go não encontrado"
    echo "   Execute este script no diretório do projeto"
    exit 1
fi

if [ ! -f "go.mod" ]; then
    echo "❌ Erro: go.mod não encontrado"
    exit 1
fi

echo "✅ Arquivos Go encontrados"

# Limpar builds anteriores
echo "🧹 Limpando builds anteriores..."
docker compose down --remove-orphans 2>/dev/null || true
docker system prune -f

# Build da imagem com multistage
echo "🔨 Construindo imagem com Multistage Build..."
echo "   Stage 1: Compilação Go (golang:1.21-alpine)"
echo "   Stage 2: Runtime otimizado (alpine:3.18 + FFmpeg)"

docker compose build --no-cache

if [ $? -eq 0 ]; then
    echo "✅ Build concluído com sucesso!"
    
    # Mostrar tamanho da imagem
    echo ""
    echo "📊 Informações da imagem otimizada:"
    docker images rota42/video-converter:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
    
    echo ""
    echo "🚀 Iniciando serviços..."
    docker compose up -d
    
    echo ""
    echo "✅ Setup concluído! Serviços rodando:"
    docker compose ps
    
    echo ""
    echo "🎯 Como usar:"
    echo "1. Coloque vídeos na pasta 'input/'"
    echo "2. Monitor logs: docker compose logs -f video-converter"
    echo "3. Conversão manual:"
    echo "   docker compose exec video-converter /app/video-converter \\"
    echo "     --input-file=/app/input/seu-video.mp4 \\"
    echo "     --output-file=/app/output/convertido.mp4 \\"
    echo "     --quality=high --verbose"
    
    echo ""
    echo "🏥 Health check:"
    echo "   docker compose exec video-converter /app/video-converter health"
    
else
    echo "❌ Erro no build. Verifique os logs acima."
    exit 1
fi
