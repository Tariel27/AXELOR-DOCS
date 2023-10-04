Открытая платформа Axelor предоставляет веб-сервисы REST, подобные JSON.

Веб-сервисы являются доступной `/ws/`конечной точкой, например:

http://localhost:8080/open-platform-demo/ws/

Каждый веб-сервис возвращает данные JSON в определенном формате. Кроме того, некоторые веб-сервисы требуют данных JSON в качестве тела запроса.

[](#request)Запрос
------------------

    {
      "model"   : "",  (1)
      "offset"  : 0,   (2)
      "limit"   : 40,  (3)
      "sortBy"  : [],  (4)
      "data"    : {},  (5)
      "records" : [],  (6)
      "fields"  : []   (7)
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

`model`\- имя модели ресурса

**2**

`offset`\- смещение пагинации

**3**

`limit`\- ограничение на количество страниц

**4**

`sortBy`\- список полей для сортировки результата

**5**

`data`\- карта json, зависит от веб-сервиса

**6**

`records`\- список карт JSON или идентификаторов записей

**7**

`fields`\- название полей

Эти атрибуты запроса зависят от службы, необходимо указать только обязательные атрибуты.

[](#response)Ответ
------------------

    {
      "status"  : 0,    (1)
      "offset"  : 0,    (2)
      "total"   : 0,    (3)
      "errors"  : {},   (4)
      "data"    : {},   (5)
      "data"    : []    (5)
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

`status`\- статус ответа

**2**

`offset`\- текущее смещение нумерации страниц

**3**

`total`\- общее количество совпавших записей

**4**

`errors`\- ошибки проверки (ключ — имя поля, значение — сообщение об ошибке)

**5**

`data`\- json-карта или массив в зависимости от типа сервиса

Атрибуты ответа зависят от службы, служба может возвращать только определенные атрибуты.

Атрибут `status`может иметь следующие значения:



Код

Причина

0

успех

\-1

отказ

\-4

Ошибка проверки

[](#cors)КОРС
-------------

Открытая платформа Axelor поддерживает [CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) , обычно необходимый для вызова веб-сервисов из мобильных приложений.

Им можно управлять с помощью следующих настроек:

    # CORS configuration
    # ~~~~~
    # CORS settings to allow cross origin requests
    
    # regular expression to test allowed origin or * to allow all (not recommended)
    #cors.allow-origin = *
    #cors.allow-credentials = true
    #cors.allow-methods = GET,PUT,POST,DELETE,HEAD,OPTIONS
    #cors.allow-headers = Origin,Accept,X-Requested-With,Content-Type,Access-Control-Request-Method,Access-Control-Request-Headers
    #cors.expose-headers =
    #cors.max-age = 1728000

характеристики![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Как правило, вам следует установить только `cors.allow-origin`список разрешенных доменов. Остальные варианты следует оставить как есть.

Чтобы избежать предполетных запросов cors, не добавляйте `X-Requested-With`заголовок и не предоставляйте `Accept: application/json`заголовок для `GET`запросов `POST`и используйте `Content-Type: text/plain;json`заголовок для `POST`методов.

[](#csrf-protection)CSRF-защита
-------------------------------

В открытой платформе Axelor включена защита от CSRF с помощью [pac4j](https://www.pac4j.org) . Если вы хотите вызывать веб-службы из клиента браузера, вам необходимо убедиться, что вы обрабатываете токен CSRF:

*   прочитать файл cookie с именем`CSRF-TOKEN`

*   при выполнении вашего запроса передайте значение этого файла cookie в заголовке с именем`X-CSRF-Token`


Пример:

    <ul id="product-list"></ul>
    
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script type="text/javascript">
      function getCookies() {
        return decodeURIComponent(document.cookie)
          .split('; ')
          .reduce((acc, cur) => { const [k, v] = cur.split('='); return {...acc, [k]: v}; }, {});
      }
    
      const cookies = getCookies();
    
      $.ajax({
        url: 'ws/rest/com.axelor.sale.db.Product/search',
        type: 'POST',
        headers: { 'X-CSRF-Token': cookies['CSRF-TOKEN'] },
        data: JSON.stringify({
          fields: ['name'],
          sortBy: ['name'],
          limit: 20
        }),
        contentType: 'application/json'
      }).done(response => {
        const productNames = response.data.map(e => e.name);
        const productList = $('#product-list');
        productNames.forEach(name => {
          $(`<li>${name}</li>`).appendTo(productList);
        });
      });
    </script>

HTML![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!