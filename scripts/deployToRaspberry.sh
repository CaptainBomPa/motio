#!/bin/bash

# Sprawdzenie, czy Docker daemon jest uruchomiony
if ! docker info > /dev/null 2>&1; then
  echo "Błąd: Docker daemon nie jest uruchomiony. Upewnij się, że Docker jest włączony i spróbuj ponownie."
  exit 1
fi

# Sprawdzenie istnienia pliku .env i załadowanie zmiennych środowiskowych
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

echo "Budowanie obrazów Docker dla motio-core, motio-auth, motio-admin, motio_web_admin i postgres-backup..."

# Budowanie i zapisywanie obrazów Docker
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

cd motio-notification
docker build -t motio-notification .
docker save -o motio-notification.tar motio-notification
cd ..

cd motio_web_admin
docker build -t motio-web-admin .
docker save -o motio-web-admin.tar motio-web-admin
cd ..

# Budowanie i zapisywanie obrazu dla postgres-backup
cd docker/full_deploy
docker build -t motio-postgres-backup .
docker save -o motio-postgres-backup.tar motio-postgres-backup
cd ../..

echo "Kopiowanie obrazów Docker i pliku docker-compose.yml na Raspberry Pi..."

# Tworzenie katalogu docelowego na Raspberry Pi
ssh ${RPI_USER}@${RPI_HOST} "mkdir -p ${RPI_DEST_DIR}"

# Przesyłanie obrazów Docker na Raspberry Pi
scp motio-core/motio-core.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp motio-auth/motio-auth.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp motio-admin/motio-admin.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp motio-notification/motio-notification.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp motio_web_admin/motio-web-admin.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp docker/full_deploy/motio-postgres-backup.tar ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}

# Przesyłanie pliku docker-compose.yml i .env na Raspberry Pi
scp docker/full_deploy/docker-compose.yml ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}
scp docker/full_deploy/.env ${RPI_USER}@${RPI_HOST}:${RPI_DEST_DIR}

echo "Wczytywanie obrazów Docker na Raspberry Pi..."
# Ładowanie obrazów Docker na Raspberry Pi
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-core.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-auth.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-admin.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-notification.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-web-admin.tar"
ssh ${RPI_USER}@${RPI_HOST} "cd ${RPI_DEST_DIR} && docker load -i motio-postgres-backup.tar"

echo "Proces wdrażania zakończony pomyślnie."
