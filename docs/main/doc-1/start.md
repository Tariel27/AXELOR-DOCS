В этой главе мы рассмотрим структуры приложений и модулей.

[](#application)Приложение
--------------------------

Приложение — это не что иное, как конфигурация набора модулей. Модули представляют собой пакеты времени сборки, обрабатываемые системой сборки [Gradle](http://gradle.org/) .

Вот структура каталогов типичного приложения axelor:

Структура каталогов

    axelor-demo
    └── src
    │   └── main
    │       ├── java
    │       └── resources
    │           └── META-INF
    │               ├── axelor-config.properties (1)
    │               └── persistence.xml (2)
    ├── gradle (3)
    │   └── wrapper
    │       ├── gradle-wrapper.jar
    │       └── gradle-wrapper.properties
    ├── modules (4)
    ├── gradlew (5)
    ├── gradlew.bat (5)
    ├── settings.gradle (6)
    └── build.gradle (7)

**1**

Конфигурационный файл приложения

**2**

XML-файл с минимальной стойкостью для подтверждения требований JPA.

**3**

Каталог для хранения файлов оболочки Gradle

**4**

Каталог для хранения проектов модулей.

**5**

Оболочка и пакетные сценарии для выполнения сборки с оболочкой.

**6**

Скрипт настроек градиента

**7**

Скрипт сборки Gradle

Каталог `modules`содержит функциональные модули, специфичные для приложения. Прежде чем проверять структуру модуля, давайте посмотрим на некоторые важные файлы.

Этот `build.gradle`файл представляет собой сценарий сборки, используемый [gradle](http://gradle.org/) для сборки приложения.

build.gradle

    plugins {
      id 'com.axelor.app' (1)
    }
    
    axelor { (2)
      title = 'Axelor DEMO'
    }
    
    allprojects {
    
      group = 'com.axelor'
      version = '1.0.0'
    
      java {
        toolchain {
          languageVersion = JavaLanguageVersion.of(11) (3)
        }
      }
    
      afterEvaluate {
        test {
          useJUnitPlatform() (4)
          beforeTest { descriptor ->
            logger.lifecycle('Running: ' + descriptor)
          }
        }
      }
    }
    
    dependencies {
      // add dependencies
      implementation project(':axelor-contact') (5)
    }

**1**

Используйте плагин приложения axelor

**2**

Конфигурация проекта приложения

**3**

Используйте Java 11

**4**

Используйте JUnit5 для модульного тестирования

**5**

Добавить зависимости

Плагин `com.axelor.app`gradle определяет точку расширения `axelor`, где мы можем определять различные свойства.

*   title - отображать заголовок приложения

*   описание - краткое описание приложения


Еще один важный сценарий сборки — это сценарий `settings.gradle`, в котором мы настраиваем сборку Gradle и объединяем все проекты функциональных модулей, которые будут использоваться в текущем процессе сборки:

настройки.gradle

    pluginManagement {
      repositories {
        maven {
          url 'https://repository.axelor.com/nexus/repository/maven-public/' (1)
        }
      }
      plugins {
        id 'com.axelor.app' version '6.0.+' (2)
      }
    }
    
    dependencyResolutionManagement {
      repositories {
        mavenCentral() {
          content {
            excludeGroup 'com.axelor' (3)
          }
        }
        maven {
          url 'https://repository.axelor.com/nexus/repository/maven-public/'
        }
        ivy { (4)
          name = "Node.js"
          setUrl("https://nodejs.org/dist/")
          patternLayout {
            artifact("v[revision]/[artifact](-v[revision]-[classifier]).[ext]")
          }
          metadataSources {
            artifact()
          }
          content {
            includeModule("org.nodejs", "node")
          }
        }
      }
    }
    
    rootProject.name = 'axelor-demo'
    
    // Include modules
    include 'modules:axelor-contact'

**1**

Репозиторий axelor maven

**2**

Версия плагина Gradle приложения axelor

**3**

Используйте maven Central, но не загружайте `com.axelor`с него

**4**

Репозиторий Node.js

Эта `include 'modules:axelor-contact'`строка сообщает gradle включить модуль `axelor-contact`в текущий цикл сборки. В файле необходимо перечислить все модули, используемые приложением `settings.gradle`.

### [](#aop-dependencies-resolution)Разрешение зависимостей АОП

По умолчанию Gradle разрешает конфликты версий зависимостей, используя новейшую версию библиотеки. В целом это нормально, но иногда, в зависимости от используемых модулей и версий АОП, использованных при их публикации, может использоваться нежелательная версия.

Чтобы избежать использования версии AOP, полученной из транзитивных зависимостей (выбранных Gradle), и, следовательно, использования версии AOP, определенной в самом проекте, примените плагин `DependenciesSupport` к корневому проекту:

настройки.gradle

    apply plugin: com.axelor.gradle.support.DependenciesSupport

[](#module)Модуль
-----------------

Проект приложения обычно не предоставляет никакой логики реализации. Функциональные возможности должны обеспечиваться путем создания модулей.

Модуль снова является подпроектом Gradle. Обычно создается внутри `modules`каталога. Однако вы можете использовать любую структуру каталогов. Дополнительную информацию см. в документации [по многопроектным сборкам gradle .](https://docs.gradle.org/current/userguide/multi_project_builds.html)

Теперь давайте посмотрим, как выглядит структура каталогов функционального модуля:

Структура каталогов

    axelor-contact
    ├── build.gradle (1)
    └── src
        ├── main (2)
        │   ├── java
        │   └── resources
        │       ├── domains (3)
        │       ├── views (4)
        │       └── i18n (5)
        └── test (6)
            ├── java
            └── resources

**1**

Скрипт сборки Gradle

**2**

Основные источники

**3**

Ресурсы XML для определений объектов домена

**4**

Ресурсы XML для определений представлений объектов

**5**

CSV-файлы с переводами.

**6**

Исходники модульных тестов

Вы можете видеть, что структура модуля соответствует стандартной структуре каталогов maven/gradle.

Давайте посмотрим `build.gradle`скрипт для модуля.

модули/axelor-contact/build.gradle

    plugins {
      id 'com.axelor.app' (1)
    }
    
    axelor { (2)
      title = "Axelor :: Contact"
    }

**1**

Плагин gradle для проекта модуля

**2**

Конфигурация проекта модуля

Плагин `com.axelor.app`определяет точку расширения `axelor`, в которой мы определяем различные свойства.

*   title - отображает заголовок модуля.

*   описание - краткое описание модуля