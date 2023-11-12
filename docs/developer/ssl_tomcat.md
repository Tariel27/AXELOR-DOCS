# SSL через томкат

## Окружения

- Ubuntu 20.04 version
- Apache Tomcat 9.0.87 version
- Java Developent Kits 1.8 version
- Домен

## Оглавление.

1. Сгенерировать сертификат.
2. Pem конвертировать в pkcs12 (p12).
3. Конфигурация tomcat.

### 1. Сгенерировать сертификат.

Введите команду в терминале.

```bash
 sudo certbot certonly --standalone -d <url> -d www.<url>
```

### 2. Pem конвертировать в pkcs12 (p12).

Введите команду в терминале.

```bash
openssl pkcs12 -export -in /etc/letsencrypt/live/<url>/fullchain.pem -inkey /etc/letsencrypt/live/<url>/privkey.pem -out /etc/letsencrypt/tomcat/<url>.p12 -name tomcat -CAfile /etc/letsencrypt/live/<url>/chain.pem -caname root
```

### 3. Конфигурация файла.

Перейдите в каталог конфигурации Apache Tomcat, обычно это `/opt/tomcat/conf`.

Отредактируйте файл `server.xml`, и найдите или добавьте эту строку.

```xml
<Connector port="443" protocol="HTTP/1.1" SSLEnabled="true" maxThreads="150" scheme="https" secure="true" clientAuth="false" sslProtocol="TLS" keystoreFile="/etc/letsencrypt/tomcat/<url>.p12" keystoreType="PKCS12" keystorePass="<password>" />
```