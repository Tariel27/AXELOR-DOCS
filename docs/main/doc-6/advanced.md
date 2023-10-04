Службы REST строго следуют традиционным правилам для restful API. Однако есть несколько случаев, которые сложно реализовать с помощью чистого REST.

Открытая платформа Axelor предоставляет некоторые дополнительные нестандартные API для таких случаев:

[](#advanced-read)Расширенное чтение
------------------------------------

Это специализированная `read`служба помимо стандартной службы REST для частичного чтения записи.

Веб-сервис доступен по следующему шаблону URL:

POST /ws/rest/:model/:id/fetch

Запрос

POST /ws/rest/com.axelor.contact.db.Contact/1/fetch HTTP/1.1
Принять: приложение/json
Тип контента: приложение/json

    {
      "fields": ["fullName"],
      "related": {
        "user": ["name", "email"],
        "parent": ["fullName"]
      }
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Ответ:

    {
      "status": 0,
      "data": [{
        "id": 1,
        "version": 1,
        "fullName": "John Smith",
        "user": {
          "name": "j.smith",
          "email": "j.smith@example.com",
          "id": 123,
          "version": 0
        },
        "parent": {
          "fullName": "Thomas Smith",
          "id": 12,
          "version": 0
        }
      }]
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

[](#advanced-delete)Расширенное удаление
----------------------------------------

Это специализированный `delete`сервис помимо стандартного REST-сервиса для массового удаления записей.

Веб-сервис доступен по следующему шаблону URL:

POST /ws/rest/:model/removeAll

Запрос

POST /ws/rest/com.axelor.contact.db.Contact/removeAll HTTP/1.1
Принять: приложение/json
Тип контента: приложение/json

    {
      "records": [{
        "id": 1,
        "version": 1
      }, {
        "id": 2,
        "version": 0
      }]
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Ответ:

    {
      "status": 0,
      "data": [{
        "id": 1,
        "version": 1
      }, {
        "id": 2,
        "version": 0
      }]
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

[](#advanced-search)Расширенный поиск
-------------------------------------

Служба расширенного поиска позволяет искать записи с расширенными критериями поиска.

Веб-сервис доступен по следующему шаблону URL:

POST /ws/rest/:модель/поиск

Некоторые примеры:

Поиск с использованием фильтра домена

POST/ws/rest/com.axelor.contact.db.Contact/search HTTP/1.1
Принять: приложение/json
Тип контента: приложение/json

    {
      "offset": 0,
      "limit": 10,
      "fields": ["fullName", "email"],
      "sortBy": ["fullName", "-createdOn"],
      "data": {
        "_domain": "self.email like :email",
        "_domainContext": {
          "email": "%gmail.com"
        },
        "_archived": true
      }
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Это `_domain`простое предложение [JPQL](https://docs.oracle.com/javaee/7/tutorial/persistence-querylanguage.htm) `where` с `self.`префиксом объекта. Значения именованных параметров могут быть предоставлены с помощью `_domainContext`.

Может `_archived`использоваться для поиска по архивным записям. По умолчанию архивные записи не возвращаются.

Поиск по расширенным критериям

POST/ws/rest/com.axelor.contact.db.Contact/search HTTP/1.1
Принять: приложение/json
Тип контента: приложение/json

    {
      "offset": 0,
      "limit": 10,
      "fields": ["fullName", "email"],
      "sortBy": ["fullName", "-createdOn"],
      "data": {
        "criteria": [{
          "operator": "or",
          "criteria": [{
            "fieldName": "email",
            "operator": "like",
            "value": "%gmail.com"
          }, {
            "fieldName": "lang",
            "operator": "=",
            "value": "FR"
          }, {
            "fieldName": "age",
            "operator": "between",
            "value": 18,
            "value2": 40
          }, {
            "operator": "and",
            "criteria": [{
              "fieldName": "firstName",
              "operator": "like",
              "value": "j%"
            }, {
              "fieldName": "lastName",
              "operator": "like",
              "value": "s%"
            }]
          }]
        }]
      }
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Вы можете видеть `criteria`, что они могут быть вложенными для создания сложных фильтров поиска:

Критерии имеют следующие атрибуты:



Атрибут

Значение

**`operator`**

оператор сопоставления (см. ниже)

`criteria`

список критериев (только для оператора `OR`или )`AND``NOT`

`fieldName`

имя поля для проверки

`value`

значение, соответствующее

`value2`

второе значение для ограничивающей проверки (между, notBetween)

Критериями `operator`могут быть:



Оператор

Значение

`and`

`AND`список вложенных критериев

`or`

`OR`список вложенных критериев

`not`

отменить список вложенных критериев

`=`

равно

`!=`

не равен

`>`

больше чем

`<`

меньше, чем

`>=`

больше или равно

`<=`

меньше или равно

`like`

искать такие значения, как

`notLike`

искать значения, которые не нравятся

`between`

поиск в диапазоне

`notBetween`

поиск вне диапазона

`isNull`

поиск нулевых значений

`notNull`

поиск ненулевых значений

В случае оператора `OR`и `AND`другого `NOT`свойства `criteria`представляет собой список из одного или нескольких критериев. Его можно вкладывать для создания сложных фильтров поиска.

Кроме того, оба `_domain`и `criteria`можно использовать для поиска.

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

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

[](#action-service)Служба действий
----------------------------------

Служба действий позволяет выполнять одно или несколько действий.

Веб-сервис доступен по следующему шаблону URL:

ПОСТ /ws/действие/

Некоторые примеры:

Выполнить действие

POST /ws/action HTTP/1.1
Принять: приложение/json
Тип контента: приложение/json

    {
      "action": "check-order-dates,com.axelor.sale.web.SaleOrderController:calculate",
      "data": {
        "context":  {
          "id": 1,
          ...
        },
      }
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Это `action`может быть одно действие или список действий, разделенных запятыми. Действие может быть либо действием XML, либо вызовом метода.

Ответ:

    {
      "status": 0,
      "data": [
        { ... },
        { ... }
      ]
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Результат действий возвращается в виде массива данных.