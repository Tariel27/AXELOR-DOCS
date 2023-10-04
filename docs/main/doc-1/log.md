Открытая платформа Axelor использует [logback](https://logback.qos.ch/) в качестве платформы ведения журналов.

[](#configuration)Конфигурация
------------------------------

Axelor Open Platform автоматически настроит ведение журнала, поэтому нет необходимости в каком-либо специальном файле конфигурации ведения журнала, `logback.xml`если только вы не хотите получить полный контроль над тем, как вести журнал (это все еще возможно).

В общем, будем настраивать логирование из `axelor-config.properties`файлов:

    # Storage path of logs files
    logging.path = {user.home}/.axelor/logs
    
    # Format of file log message
    logging.pattern.file = %d{yyyy-MM-dd HH:mm:ss.SSS} %5p ${PID:- } --- [%t] %-40.40logger{39} : %m%n
    
    # Format of console log message
    logging.pattern.console = %clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} %clr(%5p) %clr(${PID:- }){magenta} %clr(---){faint} %clr([%15.15t]){faint} %clr(%-40.40logger{39}){cyan} %clr(:){faint} %m%n
    
    # Global logging level
    logging.level.root = error
    
    # Logging level for `com.axelor` package
    logging.level.com.axelor = info
    
    # Logging level for `org.hibernate` package
    logging.level.org.hibernate = warn


[](#customization)Кастомизация
------------------------------

*   Если `logging.path`задано, файлы журналов будут храниться в этом каталоге.

*   Если `logging.pattern.file = OFF`тогда журналирование файлов будет отключено

*   Если `logging.pattern.console = OFF`тогда ведение журнала консоли будет отключено


Глобальный уровень журнала можно изменить с помощью `logging.level.root`свойства. Уровни журнала для конкретного пакета можно настроить с помощью `logging.level.<package-name> = <level>`настроек.

Консольный регистратор может регистрировать данные с использованием цветов, если терминал поддерживает цвета.

Мы можем обойти автоматическую настройку, `axelor-config.properties`включив `logback.xml` в `src/main/resources`. В этом случае вам придется настроить его самостоятельно. Мы также можем указать внешнее местоположение конфигурации, `logging.config = /path/to/logback.xml`если не хотим включать конфигурацию в военный пакет.