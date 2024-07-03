#!/bin/bash

if [ -f "./scripts/.env" ]; then
  export $(cat ./scripts/.env | grep -v '#' | awk '/=/ {print $1}')
else
  echo "Plik .env nie został znaleziony. Upewnij się, że istnieje plik .env w katalogu scripts."
  exit 1
fi

echo "Uruchamianie Gradle clean build test..."
./gradlew clean build test

if [ $? -ne 0 ]; then
    echo "Gradle build test failed. Exiting..."
    exit 1
fi

echo "Budowanie obrazów Docker dla motio-core i motio-auth..."

cd motio-core
docker build -t motio-core .
docker save -o motio-core.tar motio-core
cd ..

cd motio-auth
docker build -t motio-auth .
docker save -o motio-auth.tar motio-auth
cd ..

echo "Kopiowanie obrazów Docker i pliku docker-compose.yml na Raspberry Pi..."

ssh ${RPI_USER}@${RPI_HOST} "mkdir -p ${RPI_DEST_DIR}"

scp motio-core/motio-core.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp motio-auth/motio-auth.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp docker/full_deploy/docker-compose.yml ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}

echo "Wczytywanie obrazów Docker na Raspberry Pi..."
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-core.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-auth.tar"

echo "Proces wdrażania zakończony pomyślnie."
