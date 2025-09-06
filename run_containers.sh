#!/bin/bash
# Script: run_containers.sh
# Objetivo: Mostrar como rodar um container simples com Docker (Nginx)

echo "=== 1. Baixando a imagem do Nginx ==="
docker pull nginx

echo -e "\n=== 2. Iniciando o container 'meu-servidor' ==="
docker run -d --name meu-servidor -p 8080:80 nginx

echo -e "\n=== 3. Listando containers em execução ==="
docker ps

echo -e "\n>>> Agora acesse http://localhost:8080 para ver o Nginx rodando <<<"

read -p $'\nPressione ENTER para parar e remover o container...'

echo -e "\n=== 4. Parando o container ==="
docker stop meu-servidor

echo -e "\n=== 5. Removendo o container ==="
docker rm meu-servidor

echo -e "\n=== 6. Listando todos os containers (inclusive parados) ==="
docker ps -a

echo -e "\n✅ Missão concluída: Docker é simples e eficiente!"

