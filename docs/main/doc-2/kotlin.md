[Kotlin](http://kotlinlang.org/) — новый статически типизированный язык программирования для современных мультиплатформенных приложений. Он на 100% совместим с Java и Android и в последнее время набирает популярность.

Начиная с версии 5, Axelor Open Platform теперь официально поддерживает Kotlin для создания модулей приложений.

Мы можем использовать [Eclipse для](http://kotlinlang.org/docs/tutorials/getting-started-eclipse.html) разработки на Kotlin, но для лучшего опыта используйте [IntelliJ IDEA](http://kotlinlang.org/docs/tutorials/getting-started.html) .

[](#create-kotlin-module)Создать модуль Котлина
-----------------------------------------------

Вы можете создать новый модуль приложения, используя Kotlin, используя следующее `build.gradle`:

    buildscript {
        ext.kotlin_version = '1.2.10'
        repositories {
            mavenCentral()
        }
        dependencies {
            classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        }
    }
    
    apply plugin: 'java'
    apply plugin: 'kotlin'
    apply plugin: 'com.axelor.app-module'
    
    axelor {
        title = "Axelor :: Hello"
    }
    
    sourceCompatibility = 1.8
    
    repositories {
        mavenCentral()
    }
    
    dependencies {
        compile "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version"
    }
    
    compileKotlin {
        kotlinOptions.jvmTarget = "1.8"
    }
    compileTestKotlin {
        kotlinOptions.jvmTarget = "1.8"
    }


Вот и все. Модуль вашего приложения теперь может использовать Kotlin для реализации бизнес-логики.

[](#create-services)Создать сервисы
-----------------------------------

Давайте создадим простой HelloService, используя Kotlin:

HelloService.kt

    package com.axelor.hello.service
    
    interface HelloService {
    
        fun say(what: String): Unit
    }


и реализация:

HelloServiceImpl.kt

    package com.axelor.hello.service
    
    open class HelloServiceImpl : HelloService {
    
        override fun say(what: String) {
            println("Say: ${what}")
        }
    }


[](#create-controllers)Создание контроллеров
--------------------------------------------

Давайте создадим класс контроллера `HelloController`, который использует приведенное выше `HelloService`:

HelloController.kt

    package com.axelor.hello.web
    
    import com.axelor.hello.db.Hello
    import com.axelor.hello.service.HelloService
    import com.axelor.rpc.ActionRequest
    import com.axelor.rpc.ActionResponse
    import javax.inject.Inject
    
    open class HelloController @Inject constructor(val service: HelloService) {
    
        fun say(req: ActionRequest, res: ActionResponse) {
            val ctx = req.context.asType(Hello::class.java)
            service.say(ctx.message)
            res.status = ActionResponse.STATUS_SUCCESS
        }
    }


[](#configure)Настроить
-----------------------

Теперь пришло время настроить наши сервисы Kotlin. Создайте модуль Guice:

HelloModule.kt

    package com.axelor.hello
    
    import com.axelor.app.AxelorModule
    import com.axelor.hello.service.DefaultHelloService
    import com.axelor.hello.service.HelloService
    
    class HelloModule : AxelorModule() {
    
        override fun configure() {
            bind(HelloService::class.java).to(DefaultHelloService::class.java)
        }
    }


Вот и все…​