#!/bin/bash

# Script de conversão de vídeos usando FFmpeg
# Uso: ./convert.sh <arquivo_entrada> <formato_saida>

set -e

# Função para exibir help
show_help() {
    echo "Uso: $0 <arquivo_entrada> <formato_saida>"
    echo ""
    echo "Formatos suportados:"
    echo "  mp4, avi, mkv, mov, webm, flv"
    echo ""
    echo "Exemplos:"
    echo "  $0 input.mov mp4"
    echo "  $0 video.avi webm"
    exit 0
}

# Verificar argumentos
if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

if [ $# -ne 2 ]; then
    echo "Erro: Número incorreto de argumentos"
    show_help
fi

INPUT_FILE="$1"
OUTPUT_FORMAT="$2"

# Verificar se arquivo de entrada existe
if [ ! -f "/videos/$INPUT_FILE" ]; then
    echo "Erro: Arquivo '$INPUT_FILE' não encontrado em /videos/"
    exit 1
fi

# Extrair nome base do arquivo
BASENAME=$(basename "$INPUT_FILE" | cut -d. -f1)
OUTPUT_FILE="/output/${BASENAME}.${OUTPUT_FORMAT}"

echo "Convertendo: $INPUT_FILE -> ${BASENAME}.${OUTPUT_FORMAT}"

# Configurações de conversão baseadas no formato
case $OUTPUT_FORMAT in
    mp4)
        ffmpeg -i "/videos/$INPUT_FILE" -c:v libx264 -c:a aac -movflags +faststart "$OUTPUT_FILE"
        ;;
    webm)
        ffmpeg -i "/videos/$INPUT_FILE" -c:v libvpx-vp9 -c:a libopus "$OUTPUT_FILE"
        ;;
    avi)
        ffmpeg -i "/videos/$INPUT_FILE" -c:v libx264 -c:a mp3 "$OUTPUT_FILE"
        ;;
    mkv)
        ffmpeg -i "/videos/$INPUT_FILE" -c:v libx264 -c:a aac "$OUTPUT_FILE"
        ;;
    mov)
        ffmpeg -i "/videos/$INPUT_FILE" -c:v libx264 -c:a aac -movflags +faststart "$OUTPUT_FILE"
        ;;
    flv)
        ffmpeg -i "/videos/$INPUT_FILE" -c:v libx264 -c:a aac "$OUTPUT_FILE"
        ;;
    *)
        echo "Erro: Formato '$OUTPUT_FORMAT' não suportado"
        echo "Formatos suportados: mp4, avi, mkv, mov, webm, flv"
        exit 1
        ;;
esac

echo "Conversão concluída: $OUTPUT_FILE"
