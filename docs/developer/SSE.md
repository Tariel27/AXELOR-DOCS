# Реализация Server-Sent Events (SSE) в Акселоре

## Оглавление

1. [Введение](#1-введение)
2. [Структура реализации](#2-структура-реализации)
3. [Как это работает](#3-как-это-работает)
4. [Отправка событий клиенту](#4-отправка-событий-клиенту)
5. [Клиентская часть](#5-структура-кода)


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

В нашем проекте класс Observers  содержит компонент, который отвечает за отправку Server-Sent Events (SSE) клиентам после события TransportationTripSaved. Этот класс использует SseBroadcasterManager и OutboundSseEvent.Builder, чтобы создавать и отправлять события SSE.
```java
public class Observers {

  private SseBroadcasterManager sseBroadcasterManager;
  private OutboundSseEvent.Builder eventBuilder;
  @Inject
  public Observers(SseBroadcasterManager sseBroadcasterManager, Sse sse) {
    this.sseBroadcasterManager = sseBroadcasterManager;
    this.eventBuilder = sse.newEventBuilder();
  }

  private static final Logger LOG = LoggerFactory.getLogger(SseWebService.class);

  void onSave(@Observes TransportationTripSaved tripSaved) {
    try {
      TransportationTrip trip = tripSaved.getTrip();
      if (trip != null) {
        if (trip.getMobileGroup() != null && !trip.getMobileGroup().getGroupStatus().equals(StatusConstants.MOBILE_GROUP_STATUS_ASSIGNED)
                && trip.getMobileGroup().getGroupStatus().equals(StatusConstants.MOBILE_GROUP_STATUS_AVAILABLE)) {
          JPA.runInTransaction(() -> trip.getMobileGroup().setGroupStatus(StatusConstants.MOBILE_GROUP_STATUS_PENDING));
        }

        sseBroadcasterManager.getBroadcaster().broadcast(eventBuilder
                .data(TransportationTrip.class, trip)
                .mediaType(MediaType.APPLICATION_JSON_TYPE)
                .build());
      }

    } catch (Exception e) {
      LOG.error("Exception in TransportationTripObserver onSave: {}", e.getMessage());
    }
  }
}
```

### Момент отправки SSE
```java
sseBroadcasterManager.getBroadcaster().broadcast(eventBuilder
        .data(TransportationTrip.class, trip)
        .mediaType(MediaType.APPLICATION_JSON_TYPE)
        .build());
```
- _sseBroadcasterManager.getBroadcaster()_: Получает экземпляр _SseBroadcaster_, который используется для отправки событий SSE клиентам. Этот экземпляр был предварительно настроен и управляется _SseBroadcasterManager_.
- _.broadcast(eventBuilder ...)_: Использует метод broadcast для отправки события клиентам, зарегистрированным в данном SseBroadcaster.
- _eventBuilder.data(TransportationTrip.class, trip)_: Здесь создается само событие SSE. Метод data принимает два аргумента: тип данных и данные. В данном случае, тип данных установлен как TransportationTrip.class, а данные представляют объект trip, который, предположительно, является экземпляром класса TransportationTrip.
- _.mediaType(MediaType.APPLICATION_JSON_TYPE)_: Устанавливает тип медиа-формата данных, отправляемых в событии SSE. В данном случае, это JSON, что указывается с использованием MediaType.APPLICATION_JSON_TYPE.\
Этот код отправляет событие SSE с данными о поездке TransportationTrip клиентам, которые подписаны на данный __SseBroadcaster__. События SSE могут быть обработаны клиентскими приложениями в режиме реального времени.

## Клиентская часть

О реализации SSE со стороны клиента можете прочитать [здесь](https://learn.javascript.ru/server-sent-events)

