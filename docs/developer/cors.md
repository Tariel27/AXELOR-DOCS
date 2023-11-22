## Настройки CORS и получение COOKIES при авторизации через браузер

### 1. Введение
***
При реализации Axelor с фронтенд-частью возникают проблемы с авторизацией и получением данных через API. Чтобы решить эту проблему, необходимо настроить CORS в файле axelor-config.properties.

Вторая проблема заключается в получении данных о Cookies. В нашем проекте "Навигационная пломба", backend-часть проекта была разработана на Axelor ERP. Фронтенд реализован через Traccar. 
Для получения данных авторизации через Traccar мы добавили одну API, которая отправляет запрос авторизации к Axelor. Затем полученные данные передаются на фронтенд.

### 2. Настройки CORS
Список разрешённых источников, разделённых запятыми
```java
cors.allow-origin = *
```

Поддерживаются ли учетные данные
```java
cors.allow-credentials = false
```

Список методов, разделённых запятыми, которые разрешены
```java
cors.allow-methods = *
```

Список заголовков, разделённых запятыми, которые разрешены в запросе
```java
cors.allow-headers = *
```

### 3. Авторизации и получения Cookies

В Traccar разрабатывается Java API для отправки запроса к Axelor ERP.

```java
@POST
    @Path("/axelor")
    public Response getCookies(UserAxelor userAxelor) throws IOException, InterruptedException {
        try {

            final String axelorUrl = "http://localhost:8443/axelor-erp/login.jsp";
            ObjectMapper objectMapper = new ObjectMapper();
            ObjectNode payload = objectMapper.createObjectNode();

            payload.put("username", userAxelor.getUsername());
            payload.put("password", userAxelor.getPassword());
            String body = payload.toString();

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(axelorUrl))
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .header("Content-Type", MediaType.APPLICATION_JSON)
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 401) {
                return Response.status(Response.Status.UNAUTHORIZED).build();
            }
            HttpHeaders headers = response.headers();
            List<String> cookies = headers.allValues("set-cookie");

            if (cookies.isEmpty()) return Response.status(Response.Status.FORBIDDEN).build();

            Map<String, String> necessaryCookies = new HashMap<>();
            cookies.forEach(cookie -> {
                if (cookie.startsWith("JSESSIONID") || cookie.startsWith("CSRF-TOKEN")) {
                    String[] cookieValue = getCookie(cookie);
                    necessaryCookies.put(cookieValue[0], cookieValue[1]);
                }
            });

            return Response.ok(necessaryCookies).build();

        } catch (IOException | InterruptedException e) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
    }
```
