# Интеграция ЕСИ

## Endpoints:
  https://{base_url}/axelor-erp/login/esi-link - Генерирует ссылку для входа через ЕСИ.

  ПИ: https://{base_url}/sanarip-tamga/esi-auth?code={code_value}
  
  Нотариус: https://{base_url}/login/esi?code={code_value}.


## Документация по интеграции системы аутентификации и авторизации через ЕСИ (Единую Систему Идентификации)

## Общий обзор
Мы успешно интегрировали систему аутентификации и авторизации через сторонний сервер, называемый ЕСИ. Этот процесс включает в себя несколько шагов, которые описаны ниже.

## Шаги процесса

1. **Создание путей для обращения к коду**: 
    - Первый путь генерирует ссылку на сторонний сервис с параметрами. 
    - Пользователь переходит по этой ссылке и попадает на сайт ЕСИ.

2. **Ввод данных пользователем на сайте ЕСИ**: 
    - На сайте ЕСИ пользователь вводит свои данные.

3. **Получение кода от сервиса**: 
    - С сервиса к нам на второй эндпоинт приходит код. 
    - С помощью этого кода мы запрашиваем данные о пользователе у сервиса.

4. **Обработка полученных данных**: 
    - Если запрос успешен, то приходит метаданные в формате JSON. 
    - Мы преобразуем эти данные в DTO (Data Transfer Object) и с его помощью создаем сущности (User/Partner).

5. **Аутентификация и авторизация пользователя**: 
    - Мы аутентифицируем пользователя и с помощью группы (у каждой группы есть свои разрешения (permissions)) авторизуем его.
    - В ответе на фронт в заголовках возвращаем куки и логин пользователя.
  
```java
public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        Subject subject = SecurityUtils.getSubject();

        HttpServletRequest req = (HttpServletRequest)request;
        HttpServletResponse res = (HttpServletResponse)response;

        JEEContext context = new JEEContext(req, res);
        Response responseResponse = new Response();
        String token = req.getParameter("code");

        try {
            User userFromDB = this.esiService.authWithEsi(token);
            if (userFromDB == null) {
                throw new NullPointerException();
            }

            LOG.info("AUTH");
            UsernamePasswordCredentials credentials = new UsernamePasswordCredentials(userFromDB.getCode(), userFromDB.getPassword());
            this.esiAuthenticator.validate(credentials, context, JEESessionStore.INSTANCE);

            CommonProfile profile = (CommonProfile)credentials.getUserProfile();
            Pac4jToken tokenPac4j = new Pac4jToken(Collections.singletonList(profile), false);
            subject.login(tokenPac4j);

            HttpServletRequest httpRequest = (HttpServletRequest)request;
            HttpSession session = httpRequest.getSession();
            session.setAttribute("user", AuthUtils.getUser());

            ShiroProfileManager profileManager = new ShiroProfileManager(context, JEESessionStore.INSTANCE);
            profileManager.save(true, profile, false);

            LOG.info("SUCCESSFULLY!");
            res.setHeader("username", userFromDB.getCode());
            res.setStatus(200);

            ObjectMapper objectMapper = (ObjectMapper)Beans.get(ObjectMapper.class);
            ObjectNode jsonParameters = objectMapper.createObjectNode();
            jsonParameters.put("username", userFromDB.getCode());

            res.getWriter().write(jsonParameters.asText());
        } catch (Exception var19) {
            LOG.error("AUTH EXCEPTION:", var19);
            responseResponse.setStatus(Response.STATUS_FAILURE);
        }

    }
```
#### Мы произвели интгерацию ЕСИ по документации от Tunduk.
#### Ссылка https://wiki.tunduk.kg/doku.php?id=iis-info&s[]=еси#протокол_работы_еси

Это общий обзор процесса интеграции системы аутентификации и авторизации через ЕСИ.
