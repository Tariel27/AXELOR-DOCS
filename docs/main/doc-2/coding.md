До сих пор мы видели, как определять объекты, представления и действия, используя синтаксис XML. Однако бизнес-код необходимо реализовать путем написания реального кода.

Помимо Java, наиболее естественными кандидатами для написания бизнес-кода являются чистые языки JVM, такие как [Groovy](http://www.groovy-lang.org/) , [Scala](http://www.scala-lang.org/) или [Kotlin](https://kotlinlang.org/) . Поддержка [Groovy](http://www.groovy-lang.org/) встроена, просто обязательно добавьте `apply plugin: groovy`в свои модули `build.gradle`скрипт. Для других языков проверьте интеграцию gradle для них.

[](#services)Услуги
-------------------

Фактическая бизнес-реализация осуществляется на уровне обслуживания. Сервисы — это классы Java, жизненный цикл которых управляется платформой [Guice](https://github.com/google/guice) .

Схема примерно такая:

*   Определить интерфейс бизнес-сервиса

*   Предоставьте реализацию службы по умолчанию.

*   Привяжите интерфейс службы к реализации по умолчанию.


Интерфейс должен предоставлять схему ваших бизнес-требований, которые должны быть выполнены.

    package com.axelor.contact.service;
    
    import com.axelor.contact.db.Contact;
    
    public interface HelloService {
    
      String say(Contact contact);
    
      String hello();
    }



Интерфейс определяет два метода выполнения наших бизнес-требований. Модуль приложения, определяющий интерфейс, может предоставить реализацию этого интерфейса по умолчанию.

Для приведенного выше примера реализация может выглядеть так:

    package com.axelor.contact.service;
    
    import org.slf4j.Logger;
    import org.slf4j.LoggerFactory;
    
    import com.axelor.contact.db.Contact;
    
    public class HelloServiceImpl implements HelloService {
    
      protected Logger log = LoggerFactory.getLogger(getClass());
    
      @Override
      public String say(Contact contact) {
        return String.format("Welcome, '%s!'", contact.getFullName());
      }
    
      @Override
      public String hello() {
        return "Hello, World!";
      }
    }



При необходимости вы можете пометить реализацию соответствующей [областью](https://github.com/google/guice/wiki/Scopes) действия (внимательно прочитайте документацию перед ее использованием).

Теперь бизнес-сервис должен где-то использоваться для выполнения бизнес-требований. Обычно для предоставления услуг используйте веб-контроллеры.

[](#controllers)Контроллеры
---------------------------

Контроллеры являются посредниками между представлениями и уровнем обслуживания.

    package com.axelor.contact.web;
    
    import javax.inject.Inject;
    import com.google.inject.servlet.RequestScoped;
    
    import com.axelor.contact.db.Contact;
    import com.axelor.contact.service.HelloService;
    
    import com.axelor.meta.CallMethod;
    
    import com.axelor.rpc.ActionRequest;
    import com.axelor.rpc.ActionResponse;
    import com.axelor.rpc.Response;
    
    @RequestScope (1)
    public class HelloController {
    
      @Inject private HelloService service; (2)
    
      public void say(ActionRequest request, ActionResponse response) { (3)
    
        Contact contact = request.getContext().asType(Contact.class); (4)
        String message = service.say(contact); (5)
    
        response.setFlash(message); (6)
      }
    
      @CallMethod (7)
      public Response validate(String email) { (8)
    
        Response response = new ActionResponse();
    
        // validate email & set response properties
        // logic can be moved to service layer
    
        if (email == null) {
          response.addError("email", "Email required");
        } else if (!email.matches("\w+@\w+")) {
          response.addError("email", "Invalid email.");
        }
    
        return response;
      }
    }



**1**

жизненный цикл контроллера

**2**

внедрить услугу

**3**

метод контроллера

**4**

получить контекст представления и преобразовать в бизнес-объект

**5**

метод вызова службы

**6**

отметьте ответ, чтобы отправить сообщение на клиенте

**7**

Метод контроллера свободной формы должен быть помечен с помощью`@CallMethod`

**8**

метод контроллера свободной формы

И `ActionRequest`— `ActionResponse`это специальные классы для обработки запросов и ответов на действия. Более подробную информацию см. на странице [http://docs.axelor.com/adk/6.1/javadoc](http://docs.axelor.com/adk/6.1/javadoc) .

### [](#response-signals)Ответные сигналы

`ActionResponse.setSignal(signal, data)`используется для отправки любого произвольного сигнала клиенту. Вот пара из них, которые могут быть интересны:



`refresh-app`

обновить вкладку браузера (отправить нулевые данные)

`refresh-tab`

обновить текущую вкладку в приложении (отправить нулевые данные) — _новое в версии 5.4_

Методы контроллера свободной формы могут принимать любые параметры. Представления/действия могут передавать значения параметров из текущего контекста.

Контроллеры обычно не реализуют бизнес-логику, а обрабатывают только запросы RPC.

Методы контроллера можно использовать из действий и представлений XML:

    <button name="greet" title="Greet" onClick="com.axelor.contact.web.HelloController:say" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Или метод контроллера свободной формы

    <form name="contact-form" model="com.axelor.contact.db.Contact">
      ...
      <field name="email" onChange="com.axelor.contact.web.HelloController:validate(email)"/>
      ...
    </form>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Формат использования метода контроллера выглядит следующим образом:

<fqn>:<метод>\[(var1,var2\[,...\])\]

где `fqn`— полное имя контроллера, за которым следует двоеточие, `:` за которым следует `method`имя и, при необходимости, значения параметров из текущего контекста, если метод является методом свободной формы.

[](#configuration)Конфигурация
------------------------------

Службы должны быть настроены с помощью специального класса, называемого модулем Guice, но в нашем случае они должны быть производными от модуля `com.axelor.app.AxelorModule`.

    package com.axelor.contact;
    
    import com.axelor.app.AxelorModule;
    import com.axelor.contact.service.HelloService;
    import com.axelor.contact.service.HelloServiceImpl;
    
    public class ContactModule extends AxelorModule { (1)
    
      @Override
      protected void configure() {
        bind(HelloService.class).to(HelloServiceImpl.class); (2)
      }
    }



**1**

Класс модуля guice, используемый для настройки сервисов.

**2**

Свяжите службу с желаемой реализацией

Сообщает `bind(HelloService.class).to(HelloServiceImpl.class);`приложению, что «привяжите интерфейс HelloService к HelloServiceImpl».

Дополнительную информацию о внедрении зависимостей и привязках см. в документации Guice.

[](#overriding)Переопределение
------------------------------

Для некоторых других бизнес-требований нам, возможно, придется предоставить другую реализацию.

Например, здесь реализация метода Say по умолчанию возвращает `` "Welcome 'Some Name!'"` ``сообщение. Если мы хотим заменить это сообщение на Say, `"You are welcome 'Some Name!'"`не меняя исходный код, мы предоставляем новую реализацию.

Схема такая:

*   Переопределить реализацию по умолчанию в другом модуле

*   Цепочка связывает реализацию по умолчанию с новой реализацией

*   Интерфейс службы теперь привязан к новой реализации.


    package com.axelor.sale.service;
    
    import com.axelor.contact.db.Contact;
    import com.axelor.contact.service.HelloServiceImpl;
    
    public class HelloServiceSaleImpl extends HelloServiceImpl {
    
      @Override
      public String say(Contact contact) {
        log.info("Overriding the default HelloService.say ...");
        String message = super.say(contact);
        log.info("The default message was: {}", message);
        message = String.format("You are welcome '%s!'", contact.getFullName());
        log.info("I would say: {}", message);
        return message;
      }
    }



Технически мы можем предоставить чистую реализацию `HelloService`другого, а не расширение реализации по умолчанию, но это требует гораздо больше усилий для настройки приложения. В этом случае основной модуль приложения должен связывать исключительно бизнес-сервисы.

Однако в большинстве случаев описанная здесь схема работает нормально.

Расширяет и переопределяет `HelloServiceSaleImpl`метод другим сообщением.`HelloServiceImpl``say`

Теперь новую реализацию необходимо настроить так, чтобы приложение могло о ней знать. Это следует снова сделать из модуля конфигурации.

    package com.axelor.sale;
    
    import com.axelor.app.AxelorModule;
    import com.axelor.contact.service.HelloServiceImpl;
    import com.axelor.sale.service.HelloServiceSaleImpl;
    
    public class SaleModule extends AxelorModule {
    
      @Override
      protected void configure() {
        bind(HelloServiceImpl.class).to(HelloServiceSaleImpl.class);
      }
    }



Здесь вы можете видеть, что мы не привязываем `HelloService`интерфейс, а реализуем по умолчанию новый интерфейс. Это называется цепным связыванием. Это потому, что мы не можем связать один и тот же интерфейс/реализацию более одного раза в приложении.

Если в каком-то случае нам придется это сделать, привязку следует выполнять исключительно из основного модуля приложения.

Теперь приложение подберет `HelloServiceSaleImpl` для `HelloService`интерфейса, и куда бы вы ни ввели его `HelloService`, вы получите экземпляр класса `HelloServiceSaleImpl`.

Дополнительную информацию см. в [документации Guice .](https://github.com/google/guice)