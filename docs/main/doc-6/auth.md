На данный момент веб-сервисы используют аутентификацию на основе сеанса. Таким образом, клиентское приложение должно отслеживать идентификатор сеанса и файлы cookie между запросами.

Сеанс можно установить с помощью служб входа:

[](#login)Авторизоваться
------------------------

Запрос

POST/login.jsp HTTP/1.1

Заголовок

Тип контента: приложение/json

Тело

    {
      "username": "admin",
      "password" : "secret"
    }


Данные аутентификации отправляются в теле запроса.

Возвращает ответ со статусом HTTP `200`, если вход в систему выполнен успешно, в противном случае возвращается статус HTTP `401`.

Показаны только соответствующие заголовки и тело запроса.

[](#logout)Выйти
----------------

Запрос

    GET /logout HTTP/1.1


Ответ на вход возвращает файлы cookie сеанса, которые должны отслеживаться клиентским приложением.

Некоторые библиотеки, которые могут отслеживать сеансы:

*   [Запрос на PHP](http://requests.ryanmccue.info/)

*   [Запрос на Python](http://docs.python-requests.org/en/latest/)

*   [Запрос на NodeJS](https://github.com/request/request)

*   [HTTP-клиент Apache (Java)](http://hc.apache.org/)