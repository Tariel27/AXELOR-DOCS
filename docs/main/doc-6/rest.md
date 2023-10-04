REST-подобные сервисы для обычных операций поиска, создания, чтения, обновления и удаления.

[](#find-records)Найти записи
-----------------------------

Веб-сервис доступен по следующему шаблону URL:

ПОЛУЧИТЬ /ws/rest/:модель

Запрос

GET /ws/rest/com.axelor.contact.db.Contact?offset=0&limit=10 HTTP/1.1
Принять: приложение/json

Ответ:

    {
      "status": 0,
      "offset": 0,
      "total": 120,
      "data": [{
        "id": 1,
        "fullName": "John Smith",
        "email": "j.smith@gmail.com",
        "version": 1
      }, {
        "id": 9,
        "fullName": "Tom Boy",
        "email": "tom.boy@gmail.com",
        "version": 0
      }, "..."]
    }


[](#read-a-record)Прочитать запись
----------------------------------

Веб-сервис доступен по следующему шаблону URL:

ПОЛУЧИТЬ /ws/rest/:модель/:id

Запрос

GET /ws/rest/com.axelor.contact.db.Contact/1 HTTP/1.1
Принять: приложение/json

Ответ:

    {
      "status": 0,
      "data": [{
        "id": 1,
        "version": 0,
        "fullName": "John Smith",
        "firstName": "John",
        "..."
      }]
    }


[](#create-a-record)Создать запись
----------------------------------

Веб-сервис доступен по следующему шаблону URL:

ВСТАВЬТЕ /ws/rest/:модель

Запрос

PUT /ws/rest/com.axelor.contact.db.Contact HTTP/1.1
Принять: приложение/json
Тип контента: приложение/json

    {
      "data": {
        "firstName": "John",
        "lastName": "Smith",
        "email": "j.smith@gmail.com",
        "..."
      }
    }


Ответ:

    {
      "status": 0,
      "data": [{
        "id": 1,
        "version": 0,
        "fullName": "John Smith",
        "firstName": "John",
        "..."
      }]
    }


[](#update-a-record)Обновить запись
-----------------------------------

Веб-сервис доступен по следующему шаблону URL:

POST /ws/rest/:модель/:id

Запрос

POST /ws/rest/com.axelor.contact.db.Contact/1 HTTP/1.1
Принять: приложение/json
Тип контента: приложение/json

    {
      "data": {
        "id": 1,
        "version": 1,
        "firstName": "John",
        "lastName": "SMITH"
        "..."
      }
    }


Ответ:

    {
      "status": 0,
      "data": [{
        "id": 1,
        "version": 2,
        "fullName": "John SMITH",
        "firstName": "John",
        "lastName": "SMITH",
        "..."
      }]
    }


Номер версии используется для обеспечения неконфликтных изменений записи и поэтому должен быть указан.

[](#delete-a-record)Удалить запись
----------------------------------

Веб-сервис доступен по следующему шаблону URL:

УДАЛИТЬ /ws/rest/:модель/:id

Запрос

УДАЛИТЬ /ws/rest/com.axelor.contact.db.Contact/1 HTTP/1.1
Принять: приложение/json

Ответ:

    {
      "status": 0,
      "data": [1]
    }


Это `data`массив, в котором идентификатор удаленной записи является единственным элементом.