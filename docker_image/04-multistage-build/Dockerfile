# Stage 1: Build stage
FROM golang:1.21-alpine AS builder

# Instalar dependências necessárias para build
RUN apk add --no-cache git ca-certificates tzdata

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos go.mod e go.sum primeiro (para cache de dependências)
COPY go.mod go.sum ./

# Baixar dependências
RUN go mod download

# Copiar código fonte
COPY . .

# Compilar aplicação com otimizações
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o video-converter ./cmd/main.go

# Stage 2: Runtime stage
FROM alpine:3.18 AS runtime

# Instalar FFmpeg e dependências mínimas
RUN apk add --no-cache \
    ffmpeg \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Criar diretórios necessários
RUN mkdir -p /app/input /app/output /app/temp && \
    chown -R appuser:appgroup /app

# Copiar binário compilado do stage anterior
COPY --from=builder /app/video-converter /app/video-converter

# Copiar certificados e timezone data
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Definir usuário não-root
USER appuser

# Definir diretório de trabalho
WORKDIR /app

# Expor porta (se necessário)
EXPOSE 8080

# Definir volumes
VOLUME ["/app/input", "/app/output", "/app/temp"]

# Comando padrão
ENTRYPOINT ["/app/video-converter"]
CMD ["--help"]
