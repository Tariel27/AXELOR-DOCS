# Реализация Server-Sent Events (SSE) в Акселоре

## Оглавление

1. [Введение](#1-введение)
2. [Структура реализации](#2-структура-реализации)
3. [Как это работает](#3-как-это-работает)
4. [Отправка событий клиенту](#4-отправка-событий-клиенту)
5. [Структура кода](#5-структура-кода)
6. [Функции/методы](#6-функцииметоды)
7. [Занятия](#7-классы)

## Введение
SSE - это технология для отправки односторонних событий с сервера на клиент, что делает ее идеальным инструментом для реализации реального времени веб-приложений, таких как чаты и уведомления. Для реализации SSE используется JAX-RS (Java API для RESTful веб-сервисов) и Jersey (реализация JAX-RS).

## Структура реализации
Проект состоит из нескольких классов:\
- __SseWebService__: Класс, представляющий веб-сервис SSE. Он обрабатывает запросы клиента и устанавливает соединение SSE, регистрируя клиентский SseEventSink в SseBroadcaster.
```java
@Path("events")
@Singleton
public class SseWebService {

  @Inject private SseBroadcasterManager sseBroadcasterManager;

  @GET
  @Produces(MediaType.SERVER_SENT_EVENTS)
  public void messages(final @Context SseEventSink sink) throws Exception {
    SseBroadcaster sseBroadcaster = sseBroadcasterManager.getBroadcaster();
    sseBroadcaster.register(sink);
  }

}
```
- __SseBroadcasterManager__: Класс, ответственный за создание и управление SseBroadcaster, который используется для отправки событий клиентам.
```java
@Singleton
public class SseBroadcasterManager {
  private SseBroadcaster sseBroadcaster;

  private final Sse sse;


  @Inject
  public SseBroadcasterManager(Sse sse) {
    this.sse = sse;
  }

  public SseBroadcaster getBroadcaster() {
    if (sseBroadcaster == null) {
      sseBroadcaster = sse.newBroadcaster();
    }
    return sseBroadcaster;
  }
}
```
- __SseProvider__: Класс, реализующий интерфейс Provider для предоставления Sse. Он создает экземпляр SseImpl, который предоставляет необходимую функциональность SSE.
```java
public class SseProvider  implements Provider<Sse> {
  @Override
  public Sse get() {
    return new SseImpl();
  }
}
```

## Как это работает
1. Когда клиент отправляет GET-запрос на ``/events``, __SseWebService__ обрабатывает этот запрос. Он получает __SseEventSink__, представляющий клиентское соединение SSE.
2. _SseBroadcasterManager_ отвечает за создание и управление _SseBroadcaster_. Если SseBroadcaster уже существует, он возвращает его. В противном случае, он создает новый SseBroadcaster с помощью _Sse_.
3. Затем __SseWebService__ регистрирует клиентский SseEventSink в SseBroadcaster, что позволяет серверу отправлять события клиенту.
4. Далее сервер может отправлять события клиенту через SseBroadcaster, и клиент будет получать их в режиме реального времени.

## Отправка событий клиенту

