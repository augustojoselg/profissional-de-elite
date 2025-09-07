# Multi-stage build para minimizar o tamanho da imagem
FROM nginx:alpine AS production

# Remove arquivos desnecessários do nginx
RUN rm -rf /usr/share/nginx/html/*

# Copia os arquivos da página institucional
COPY ./site/ /usr/share/nginx/html/

# Configuração básica do nginx para servir arquivos estáticos
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
    error_page 500 502 503 504 /50x.html; \
    location = /50x.html { \
        root /usr/share/nginx/html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expõe a porta 80
EXPOSE 80

# Comando padrão
CMD ["nginx", "-g", "daemon off;"]
