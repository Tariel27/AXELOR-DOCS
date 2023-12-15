#  Проверка и Подпись Документов

Этот документ описывает проверку и подпись документов с использованием криптографии, основанной на библиотеке Bouncy Castle.
# Документация по Бекенду: Проверка и Подпись Документов

1. [Основные Технологии](#основные-технологии)
2. [Проверка Подписи Документа](#проверка-подписи-документа)
   - [Тело Запроса](#тело-запроса)
   - [Успешный Ответ](#успешный-ответ)
   - [Ошибка Ответа](#ошибка-ответа)
3. [Библиотека Криптографии: Bouncy Castle](#библиотека-криптографии-bouncy-castle)
   - [Версия Библиотеки](#версия-библиотеки)
   - [Добавление Зависимости (Maven)](#добавление-зависимости-maven)
   - [Gradle](#gradle)
   - [Описание Класса SignatureValidatorImpl](#описание-класса-signaturevalidatorimpl)
     - [Метод `validateSignature`](#метод-validatesignature)
     - [Метод `extractCertificate`](#метод-extractcertificate)
     - [Метод `extractSerialNumber`](#метод-extractserialnumber)
     - [Метод `checkSerialNumber`](#метод-checkserialnumber)
     - [Примечание](#примечание)
```
## Основные Технологии

-   **Язык Программирования:** Java
-   **Библиотека Криптографии:** Bouncy Castle

## Проверка Подписи Документа

### Тело Запроса:

```javascript
`{
  "hash": "d41d8cd98f00b204e9800998ecf8427e",
  "file": "base64_encoded_file_data"
}` 
```
-   `hash`: Хэш документа, который нужно проверить.
-   `file`: Данные файла, закодированные в формате base64.

### Успешный Ответ:

```javascript
`{
  "status": "success",
  "message": "Signature verification success"
}` 

```

### Ошибка Ответа:

```javascript
`{
  "status": "error",
  "message": "Serial number does not match. Signature verification FAILED!"
}` 

```
## Библиотека Криптографии: Bouncy Castle

Для реализации проверки и подписи документов мы используем библиотеку криптографии Bouncy Castle. Эта библиотека предоставляет набор инструментов для работы с криптографическими операциями в Java. Она включает в себя различные алгоритмы шифрования, хэширования, цифровой подписи, генерации ключей и другие криптографические примитивы.

-   **Версия Библиотеки:** 1.68

### Добавление Зависимости (Maven):

```xml
`<dependencies>
    <!-- Другие зависимости -->

    <!-- Bouncy Castle provider library -->
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bcprov-jdk15on</artifactId>
        <version>1.68</version>
    </dependency>

    <!-- Bouncy Castle mail library -->
    <dependency>
        <groupId>org.bouncycastle</groupId>
        <artifactId>bcmail-jdk15on</artifactId>
        <version>1.68</version>
    </dependency>
</dependencies>` 
```
### Gradle:

```xml
`dependencies {
    // ... Другие зависимости

    // Bouncy Castle provider library
    implementation 'org.bouncycastle:bcprov-jdk15on:1.68'

    // Bouncy Castle mail library
    implementation 'org.bouncycastle:bcmail-jdk15on:1.68'
}` 
```
1.  **bcprov-jdk15on:** Эта библиотека предоставляет реализацию криптографических алгоритмов, таких как AES, RSA, DSA, SHA, и других, а также поддерживает работу с сертификатами X.509.
2.  **bcmail-jdk15on:** Эта библиотека добавляет поддержку криптографических алгоритмов, используемых в электронной почте, таких как S/MIME (Secure/Multipurpose Internet Mail Extensions) для подписи и шифрования электронных сообщений.

## Описание Класса SignatureValidatorImpl

### Метод validateSignature

java
```java
`public boolean validateSignature(String hash, byte[] file) throws CMSException` 
```
Метод `validateSignature` осуществляет проверку подписи документа. Принимает хэш документа (`hash`) и данные файла в виде массива байт (`file`). В случае успешной проверки возвращает `true`. В случае ошибки или несоответствия подписи возвращает исключение `CMSException`.

Пример использования:

java
```java
`try {
    boolean isValid = signatureValidator.validateSignature("d41d8cd98f00b204e9800998ecf8427e", fileData);
    if (isValid) {
        // Подпись документа верна
    } else {
        // Подпись документа неверна
    }
} catch (CMSException e) {
    // Обработка ошибок при проверке подписи
}` 
```
### Метод extractCertificate

java
```java
`private Optional<X509Certificate> extractCertificate(SignerInformation signer, Store certStore)` 
```
Метод `extractCertificate` извлекает сертификат из подписи. Принимает объект `SignerInformation` и хранилище сертификатов (`certStore`). Возвращает объект `Optional<X509Certificate>`. Если сертификат успешно извлечен, возвращает `Optional` с объектом `X509Certificate`. В случае ошибки возвращает пустой `Optional`.

### Метод extractSerialNumber

java
```java
`private static String extractSerialNumber(X509Certificate certificate)` 
```
Метод `extractSerialNumber` извлекает серийный номер из X.509 сертификата. Принимает объект `X509Certificate`. Возвращает серийный номер в виде строки или `null`, если номер не найден в сертификате.

### Метод checkSerialNumber

java
```java
`private boolean checkSerialNumber(String number)` 
```
Метод `checkSerialNumber` проверяет соответствие переданного серийного номера номеру, хранящемуся в компании пользователя. Возвращает `true`, если номера совпадают, иначе `false`.

#### Примечание

-   **Логирование:** Используется SLF4J для логирования. Рекомендуется настроить систему логирования в соответствии с требованиями вашего проекта.
-   **Библиотека Криптографии:** Для работы с криптографией используется Bouncy Castle версии 1.69. Удостоверьтесь, что данная библиотека подключена в вашем проекте.
-   **Аутентификация:** Для доступа к методам бекенда требуется валидный токен аутентификации, передаваемый в заголовке запроса.
-   **Безопасность:** При передаче данных между фронтендом и бекендом удостоверьтесь, что используется безопасное соединение (например, HTTPS) и данные защищены.

Эта документация предоставляет более подробное описание методов и их использования в контексте вашего проекта.
```java
public boolean validateSignature(String hash, byte[] file) throws CMSException {  
    byte[] signedData = Base64.getDecoder().decode(hash);  
    try (InputStream is = new ByteArrayInputStream(signedData)) {  
        CMSSignedData cmsSignedData = new CMSSignedData(new CMSProcessableByteArray(file), is);  
        Security.addProvider(new BouncyCastleProvider());  
  
        Store certStore = cmsSignedData.getCertificates();  
  
        SignerInformationStore signers = cmsSignedData.getSignerInfos();  
        for (Object signerObj : signers.getSigners()) {  
            SignerInformation signer = (SignerInformation) signerObj;  
            Optional<X509Certificate> optionalCert = extractCertificate(signer, certStore);  
            if (optionalCert.isPresent()) {  
                X509Certificate cert = optionalCert.get();  
                String serialNumber = extractSerialNumber(cert);  
                LOGGER.info("Serial Number: {}", serialNumber);  
                if (!checkSerialNumber(serialNumber)) {  
                    LOGGER.error("Serial number does not match. Signature verification FAILED!");  
                    throw new CMSException("Serial number does not match. Signature verification FAILED!");  
                }  
                if (!signer.verify(new JcaSimpleSignerInfoVerifierBuilder().setProvider("BC").build(cert))) {  
                    LOGGER.error("Signature verification FAILED!");  
                    throw new CMSException("Signature verification FAILED!");  
                } else {  
                    LOGGER.info("Signature verification success");  
                }  
            }  
        }  
    } catch (IOException | org.bouncycastle.cms.CMSException | OperatorCreationException e) {  
        LOGGER.error("Error during signature validation", e);  
        throw new CMSException("Error during signature validation", e);  
    }  
  
    return true;  
}  
  
private Optional<X509Certificate> extractCertificate(SignerInformation signer, Store certStore) {  
    Iterator certIt = certStore.getMatches(signer.getSID()).iterator();  
    while (certIt.hasNext()) {  
        try {  
            X509CertificateHolder certHolder = (X509CertificateHolder) certIt.next();  
            return Optional.of(new JcaX509CertificateConverter().getCertificate(certHolder));  
        } catch (Exception e) {  
            LOGGER.error("Error converting X509CertificateHolder to X509Certificate", e);  
        }  
    }  
    return Optional.empty();  
}  
  
private static String extractSerialNumber(X509Certificate certificate) {  
    String serialNumber = null;  
    if (certificate != null) {  
        String[] split = certificate.getSubjectDN().getName().split(", ");  
        for (String field : split) {  
            if (field.startsWith("SERIALNUMBER=")) {  
                serialNumber = field.substring("SERIALNUMBER=".length());  
                break;  
            }  
        }  
    }  
    return serialNumber;  
}  
  
private boolean checkSerialNumber(String number) {  
    User user = AuthUtils.getUser();  
    Company activeCompany = user.getActiveCompany();  
    String digitalSignNumber = activeCompany.getDigitalSignNumber();  
    LOGGER.info("Checking serial number: {}", number);  
  
    if (digitalSignNumber == null || digitalSignNumber.isEmpty()) {  
        LOGGER.warn("Digital sign number is empty. Unable to perform serial number check.");  
        return false;  
    }  
  
    return digitalSignNumber.equals(number);  
}
```
