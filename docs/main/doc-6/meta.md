Ниже приведены сервисы для получения метаданных моделей предметной области.

[](#get-models)Получить модели
------------------------------

Этот сервис возвращает список всех моделей домена.

Запрос

ПОЛУЧИТЬ /ws/meta/models HTTP/1.1
Принять: приложение/json

Ответ:

    {
      "status"  : 0,
      "total"   : 32,
      "data"    : ["com.axelor.contact.db.Contact", "..."]
    }


[](#get-model-properties)Получить свойства модели
-------------------------------------------------

Этот сервис можно использовать для получения свойств модели предметной области.

Запрос

GET /ws/meta/fields/com.axelor.contact.db.Contact HTTP/1.1
Принять: приложение/json

Ответ:

    {
      "status": 0,
      "data": {
        "model": "com.axelor.contact.db.Contact",
        "fields": [{
          "name": "firstName",
          "type": "STRING",
          "required": true
        }, {
          "name": "lastName",
          "type": "STRING"
        }, "..."]
      }
    }

