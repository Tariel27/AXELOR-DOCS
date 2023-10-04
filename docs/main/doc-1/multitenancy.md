В Axelor Open Platform v5 добавлена ​​поддержка [мультиарендности](https://en.wikipedia.org/wiki/Multitenancy) . Термин «мультитенантность» относится к архитектуре программного обеспечения, в которой один экземпляр программного обеспечения работает на сервере и обслуживает несколько арендаторов. Арендатор — это группа пользователей, которые имеют общий доступ с определенными привилегиями к экземпляру программного обеспечения.

Итак, теперь один экземпляр приложения Axelor может обслуживать несколько арендаторов (пользователей, компаний и т. д.).

[](#configuration)Конфигурация
------------------------------

Реализация мультитенантности по умолчанию использует несколько баз данных для каждого арендатора и требует настройки из `axelor-config.properties`.

Ключи конфигурации базы данных с форматом `db.<tenant-id>.<key>`используются для настройки подключений к базе данных.

    # enable multi-tenancy
    application.multi-tenancy = true (1)
    
    db.default.visible = false (2)
    db.default.driver = org.postgresql.Driver
    db.default.ddl = update (3)
    db.default.url = jdbc:postgresql://localhost:5432/open-platform-demo-db
    db.default.user = axelor
    db.default.password =
    
    db.db1.name = DB1 (4)
    db.db1.hosts = host1,host1:8080 (5)
    db.db1.roles = admin (6)
    db.db1.driver = org.postgresql.Driver
    db.db1.url = jdbc:postgresql://localhost:5432/open-platform-demo-db1
    db.db1.user = axelor
    db.db1.password =
    
    db.db2.name = DB2
    db.db2.hosts = host1,host1:8080
    db.db2.driver = org.postgresql.Driver
    db.db2.url = jdbc:postgresql://localhost:5432/open-platform-demo-db2
    db.db2.user = axelor
    db.db2.password =
    
    db.db3.name = DB3
    db.db3.hosts = host1,host1:8080,host2,host2:8080
    db.db3.driver = org.postgresql.Driver
    db.db3.url = jdbc:postgresql://localhost:5432/open-platform-demo-db3
    db.db3.user = axelor
    db.db3.password =


**1**

требуется для включения функции мультитенантности

**2**

база данных по умолчанию должна быть невидимой, поскольку это запасной вариант

**3**

только база данных по умолчанию поддерживает операции DDL, схему для других арендаторов необходимо создавать вручную

**4**

отображаемое имя арендатора

**5**

фильтр ролей, только пользователи с этими ролями могут получить доступ к этим арендаторам

**6**

фильтр на основе имени хоста, арендатор доступен только с этих хостов

Клиент по умолчанию является обязательным и будет использоваться в том случае, если приложению по какой-либо причине не удастся определить идентификатор клиента. Таким образом, арендатор по умолчанию не должен использоваться ни для чего, кроме демонстрационных/резервных целей.

[](#customization)Кастомизация
------------------------------

Мы можем переопределить эту реализацию по умолчанию, предоставив собственную реализацию этих двух интерфейсов:

*   `com.axelor.db.tenants.TenantConfig`— интерфейс для предоставления значений конфигурации подключения арендатора.

*   `com.axelor.db.tenants.TenantConfigProvider`\- интерфейс для получения TenantConfig, может быть с внешнего ресурса


Определяет `TenantConfigProvider`следующие методы для реализации:

*   `TenantConfig find(String tenantId)`\- найти экземпляр TenantConfig для данного идентификатора арендатора

*   `List<TenantConfig> findAll(String host)`\- найти все TenantConfig для данного имени хоста

*   `boolean hasAccess(User user, TenantConfig config)`\- проверить, может ли данный аутентифицированный пользователь использовать арендатора


Пользовательскую реализацию следует интегрировать из модуля приложения следующим образом:

    public class DemoModule extends AxelorModule {
    
        @Override
        protected void configure() {
            bind(TenantConfigProvider.class).to(MyTenantConfigProvider.class);
        }
    
    }


Решение о том, `MyTenantConfigProvider`как разрешить арендаторов (возможно, используется соединение jdbc с какой-либо внешней базой данных), зависит от компании.

[](#limitations)Ограничения
---------------------------

Следующие функции отключены в многопользовательском режиме:

*   [Планировщик](../modules/scheduler.html)

*   Поколения схемы