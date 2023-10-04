[Scala](http://www.scala-lang.org/) — это язык программирования общего назначения, обеспечивающий поддержку функционального программирования и строгую систему статических типов. Многие проектные решения Scala, призванные быть краткими,\[10\] были направлены на устранение критики в адрес Java.

Вы можете использовать Scala для создания модулей приложения.

Мы можем использовать [Eclipse](http://scala-ide.org/) для Scala, но для лучшего опыта используйте [IntelliJ IDEA](http://www.scala-lang.org/documentation/getting-started-intellij-track/getting-started-with-scala-in-intellij.html) .

[](#create-scala-module)Создать модуль Scala
--------------------------------------------

Вы можете создать новый модуль приложения, используя Scala, используя следующее `build.gradle`:

    apply plugin: 'scala'
    apply plugin: 'com.axelor.app-module'
    
    dependencies {
        compile 'org.scala-lang:scala-library:2.11.8'
        testCompile 'org.scalatest:scalatest_2.11:3.0.0'
    }


Вот и все. Модуль вашего приложения теперь может использовать Scala для реализации бизнес-логики.

[](#create-services)Создать сервисы
-----------------------------------

Давайте создадим простой HelloService, используя Scala:

HelloService.scala

    package com.axelor.hello.service
    
    trait HelloService {
    
      def say(what: String): Unit
    }


и реализация:

HelloServiceImpl.scala

    package com.axelor.hello.service
    
    class HelloServiceImpl extends HelloService {
    
      override def say(what: String): Unit = {
        println(s"Say: ${what}")
      }
    }


[](#create-controllers)Создание контроллеров
--------------------------------------------

Давайте создадим класс контроллера `HelloController`, который использует приведенное выше `HelloService`:

HelloController.scala

    package com.axelor.hello.web
    
    import javax.inject.Inject
    
    import com.axelor.hello.db.Hello
    
    import com.axelor.hello.service.HelloService
    import com.axelor.rpc.{Response, ActionRequest, ActionResponse}
    
    class HelloController @Inject() (service: HelloService) {
    
      def say(req: ActionRequest, res: ActionResponse): Unit = {
        val ctx = req.getContext.asType(classOf[Hello])
        service.say(ctx.getMessage)
        res.setStatus(Response.STATUS_SUCCESS)
      }
    }


[](#configure)Настроить
-----------------------

Теперь пришло время настроить наши службы Scala. Создайте модуль Guice:

HelloModule.scala

    package com.axelor.hello
    
    import com.axelor.app.AxelorModule
    import com.axelor.hello.service.{HelloService, HelloServiceImpl}
    
    class HelloModule extends AxelorModule {
    
      override protected def configure(): Unit = {
        bind(classOf[HelloService]).to(classOf[HelloServiceImpl])
      }
    }


Вот и все…​