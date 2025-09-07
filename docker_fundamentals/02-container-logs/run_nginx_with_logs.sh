#!/bin/bash
# Script: run_nginx_with_logs.sh
# Objetivo: Mostrar persistência de logs usando Docker Volumes

set -e

echo "=== 1. Criando volume persistente chamado 'nginx_logs' ==="
docker volume create nginx_logs

echo -e "\n=== 2. Subindo container 'meu-nginx' com volume montado ==="
docker run -d --name meu-nginx \
  -p 8080:80 \
  -v nginx_logs:/var/log/nginx \
  nginx

echo -e "\n=== 3. Gerando acessos para criar logs ==="
for i in {1..3}; do
  curl -s http://localhost:8080 > /dev/null
done

echo -e "\n=== 4. Listando os arquivos de log dentro do container ==="
docker exec meu-nginx ls -l /var/log/nginx

echo -e "\n=== 5. Parando e removendo o container 'meu-nginx' ==="
docker stop meu-nginx
docker rm meu-nginx

echo -e "\n=== 6. Subindo um novo container 'meu-nginx2' reutilizando o mesmo volume ==="
docker run -d --name meu-nginx2 \
  -p 8080:80 \
  -v nginx_logs:/var/log/nginx \
  nginx

echo -e "\n=== 7. Validando que os logs antigos ainda estão no volume ==="
docker exec meu-nginx2 ls -l /var/log/nginx
docker exec meu-nginx2 cat /var/log/nginx/access.log | head -n 5

echo -e "\n Missão concluída: os logs persistem mesmo após remover o container!"

