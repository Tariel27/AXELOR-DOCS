# Интересный Факт, Публичный веб-сервис

## Детально

Для создания публичного веб-сервиса нужно просто создать\найти класс с аннотацией `@Path(value = "public")`, далее делаем что хотим.

## Почему так

Разработчики в ядре добавили сервтлет, которому есть доступ у всех.

```java
addFilterChain("/ws/public/**", ANON);
addFilterChain("/public/**", ANON);
```

## Пример
```java
import javax.ws.rs.GET;
import javax.ws.rs.Path;

@Path("public")
public class TestWebService {

    //Доступен по ссылке /ws/public
    @GET
    public String test() {
        return "hello world!";
    }
}
```
