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

echo "Budowanie obrazów Docker dla motio-core, motio-auth, motio-admin i motio_web_admin..."

cd motio-core
docker build -t motio-core .
docker save -o motio-core.tar motio-core
cd ..

cd motio-auth
docker build -t motio-auth .
docker save -o motio-auth.tar motio-auth
cd ..

cd motio-admin
docker build -t motio-admin .
docker save -o motio-admin.tar motio-admin
cd ..

cd motio_web_admin
docker build -t motio-web-admin .
docker save -o motio-web-admin.tar motio-web-admin
cd ..

echo "Kopiowanie obrazów Docker i pliku docker-compose.yml na Raspberry Pi..."

ssh ${RPI_USER}@${RPI_HOST} "mkdir -p ${RPI_DEST_DIR}"

scp motio-core/motio-core.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp motio-auth/motio-auth.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp motio-admin/motio-admin.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp motio_web_admin/motio-web-admin.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp docker/full_deploy/docker-compose.yml ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp docker/full_deploy/.env ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}

echo "Wczytywanie obrazów Docker na Raspberry Pi..."
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-core.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-auth.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-admin.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-web-admin.tar"

echo "Proces wdrażania zakończony pomyślnie."
