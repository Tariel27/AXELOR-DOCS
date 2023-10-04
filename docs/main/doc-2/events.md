Открытая платформа Axelor реализует подмножество [модели уведомления о событиях CDI 2.0](http://docs.jboss.org/cdi/spec/2.0/cdi-spec.html#events) . Классы наблюдателей событий должны быть [связаны](coding.html#configuration) и иметь методы наблюдателя, т.е. методы, которые принимают событие в качестве параметра, аннотированное `@Observes`, необязательным `@Priority`(методы-наблюдатели вызываются в порядке возрастания приоритета) и другими необязательными квалификаторами, чтобы сузить список событий для наблюдения. Методы наблюдателя вызываются всякий раз, когда запускается соответствующее событие.

[](#built-in-events)Встроенные события
--------------------------------------

Все встроенные события расположены внутри `com.axelor.events`пакета.

### [](#login-events)События входа в систему

Эти события запускаются во время процесса входа пользователя в систему.

*   `PreLogin(AuthenticationToken token)`– запускается до входа пользователя в систему

*   `PostLogin(AuthenticationToken token, User user, Throwable error)`– запускается после входа пользователя в систему




Поле

Описание

`token`

[токен аутентификации](https://shiro.apache.org/static/current/apidocs/org/apache/shiro/authc/AuthenticationToken.html)

`user`

аутентифицированный пользователь

`error`

исключение, вызвавшее ошибку входа в систему

`PostLogin`Методы наблюдателя могут использовать `@Named`квалификатор с либо `PostLogin.SUCCESS`или `PostLogin.FAILURE`.

    import com.axelor.event.Observes;
    import com.axelor.events.PostLogin;
    
    import javax.inject.Inject;
    import javax.inject.Named;
    import javax.servlet.http.HttpServletRequest;
    
    @RequestScoped
    public class LoginObserver {
    
      @Inject private HttpServletRequest request;
    
      // Observes successful login.
      void onLoginSuccess(@Observes @Named(PostLogin.SUCCESS) PostLogin event) {
        final String userCode = event.getUser().getCode();
        final String userAgent = request.getHeader("User-Agent");
        System.out.printf("User: %s, User-Agent: %s%n", userCode, userAgent);
      }
    }



Если вы хотите перенаправить текущий запрос на новый URL-адрес, вы можете использовать [`WebUtils.issueRedirect`](https://shiro.apache.org/static/1.4.1/apidocs/org/apache/shiro/web/util/WebUtils.html#issueRedirect(javax.servlet.ServletRequest,javax.servlet.ServletResponse,java.lang.String)).

### [](#action-events)События действия

Эти события запускаются при вызове действий.

*   `PreAction(String name, Context context)`– запускается перед выполнением действия

*   `PostAction(String name, Context context, Object result)`– запускается после выполнения действия




Поле

Описание

`name`

название действия

`context`

контекст действия

`result`

объект, возвращаемый действием

Методы наблюдателя могут использовать `@Named`квалификатор с именем наблюдаемого действия.

    import com.axelor.event.Observes;
    import com.axelor.events.PostAction;
    
    import javax.inject.Named;
    
    public class SaleOrderObserver {
    
      // Observes built-in post-action event by its name.
      void onConfirmed(@Observes @Named("action-sale-order-confirm") PostAction event) {
        System.out.println(event.getName());
      }
    }



### [](#request-events)Запросить события

Эти события запускаются во время запросов к серверу (служба REST).

*   `PreRequest(Object source, Request request)`\- запускается перед запросом

*   `PostRequest(Object source, Request request, Response response)`\- уволен по запросу




Поле

Описание

`source`

источник события

`request`

объект запроса

`response`

объект ответа

Методы наблюдателя могут использовать `@Named`квалификатор с именем запроса для наблюдения:

*   `RequestEvent.SEARCH`

*   `RequestEvent.EXPORT`

*   `RequestEvent.READ`

*   `RequestEvent.FETCH`

*   `RequestEvent.SAVE`

*   `RequestEvent.MASS_UPDATE`

*   `RequestEvent.REMOVE`

*   `RequestEvent.COPY`

*   `RequestEvent.FETCH_NAME`


Методы наблюдателя также могут использовать встроенный `@EntityType`квалификатор для выбора типа объекта для наблюдения.

    import com.axelor.event.Observes;
    import com.axelor.event.Priority;
    
    import com.axelor.events.PostRequest;
    import com.axelor.events.RequestEvent;
    import com.axelor.events.qualifiers.EntityType;
    
    import javax.inject.Named;
    
    public class ContactObserver {
    
      void onExport(@Observes @Priority(0)
          @Named(RequestEvent.EXPORT) @EntityType(Contact.class) PostRequest event) {
        System.out.println(event.getSource());
      }
    }



#### [](#workflow-status-tags)Теги статуса рабочего процесса

_Новое в версии 5.4_

Наблюдая за событиями выборки, можно добавлять статус рабочего процесса в виде тегов в представлении формы.

    public void onFetch(@Observes @Named(RequestEvent.FETCH) PostRequest event) {
      @SuppressWarnings("unchecked")
      final Map<String, Object> values = (Map<String, Object>) event.getResponse().getItem(0);
      if (values != null) {
        final List<Map<String, Object>> status = new ArrayList<>();
        status.add(ImmutableMap.of("name", "s1", "title", "Status 1", "color", "red"));
        values.put("$wkfStatus", status);
      }
    }



`status`должен быть список карт со следующими ключами:

*   name – имя узла

*   title – отображать заголовок

*   цвет – цвет фона HTML


### [](#application-events)События приложения

Эти события запускаются во время запуска и завершения работы приложения.

*   `StartupEvent()`– запускается после инициализации приложения

*   `ShutdownEvent()`– запускается перед завершением работы приложения


[](#custom-events)Пользовательские события
------------------------------------------

### [](#event-object)Объект события

Вы можете создавать свои собственные события. Объектом события может быть любой тип POJO:

    public class ContactSaved {
      private final Contact contact;
    
      public ContactSaved(Contact contact) {
        this.contact = contact;
      }
    
      public Contact getContact() {
        return contact;
      }
    }



### [](#event-source)Источник события

Служба, запускающая событие, является источником событий. Чтобы запустить событие, службе необходимо внедрить параметризованный объект Event и вызвать его `fire`метод с экземпляром объекта события в качестве параметра:

    import com.axelor.event.Event;
    import javax.inject.Inject;
    
    public class ContactService {
    
      @Inject private Event<ContactSaved> contactSavedEvent;
    
      // Probably should be called from entity listener. (1)
      public void fireContactSavedEvent(Contact contact) {
        contactSavedEvent.fire(new ContactSaved(contact));
      }
    }



**1**

См. [прослушиватели сущностей](../models/models.html#entity-listeners) .

### [](#event-observer)Наблюдатель событий

Вы можете наблюдать за своими пользовательскими событиями в обозревателе событий. Помните, что класс наблюдателя должен быть [связан](coding.html#configuration) и состоит из методов наблюдателя.

    import com.axelor.event.Observes;
    
    public class ContactObserver {
    
      void onContactChanged(@Observes ContactSaved event) {
        Contact contact = event.getContact();
        System.out.println(contact);
      }
    }



### [](#qualifiers)Квалификации

При запуске событий вы также можете использовать `select`свои собственные квалификаторы, чтобы сузить круг вызовов методов наблюдателя:

    import com.axelor.event.Event;
    import com.axelor.event.NamedLiteral;
    import javax.inject.Inject;
    
    public class ContactService {
    
      @Inject private Event<ContactSaved> contactSavedEvent;
    
      public void fireContactSavedEvent(Contact contact) {
        contactSavedEvent.fire(new ContactSaved(contact));
      }
    
      public void fireContactSavedEventSuccess(Contact contact) {
        contactSavedEvent.select(NamedLiteral.of("success")).fire(new ContactSaved(contact));
      }
    
      public void fireContactSavedEventFailure(Contact contact) {
        contactSavedEvent.select(NamedLiteral.of("failure")).fire(new ContactSaved(contact));
      }
    }



    public class ContactObserver {
    
      void onContactChanged(@Observes ContactSaved event) {
        // Called by fireContactSavedEvent,
        // fireContactSavedEventSuccess, and fireContactSavedEventFailure.
      }
    
      void onContactChangedSuccess(@Observes @Named("success") ContactSaved event) {
        // Called by fireContactSavedEventSuccess.
      }
    
      void onContactChangedFailure(@Observes @Named("failure") ContactSaved event) {
        // Called by fireContactSavedEventFailure.
      }
    }

