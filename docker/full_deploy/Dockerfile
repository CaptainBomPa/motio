FROM arm64v8/alpine:latest

RUN apk add --no-cache postgresql-client bash

COPY backup.sh /usr/local/bin/backup.sh

RUN chmod +x /usr/local/bin/backup.sh

CMD ["sh", "-c", "echo '0 3 * * * /usr/local/bin/backup.sh' | crontab - && crond -f"]
