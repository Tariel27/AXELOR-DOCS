Аутентификация — это процесс проверки личности, а авторизация — это процесс определения прав доступа к ресурсам в приложении.

Поддержка аутентификации и авторизации в открытой платформе Axelor основана на [Apache Shiro](http://shiro.apache.org) , а различные виды механизмов аутентификации реализованы с помощью [механизма безопасности PAC4J](http://www.pac4j.org) .

В следующих нескольких разделах мы увидим, как аутентификация и авторизация поддерживаются в открытой платформе Axelor.

[](#authentication)Аутентификация
---------------------------------

Аутентификация — это процесс проверки личности, т.е. разрешение пользователям войти в систему для ее использования.

Axelor Open Platform — это платформа веб-приложений, используемая для создания веб-приложений. Поэтому по умолчанию он обеспечивает аутентификацию пользователя на основе форм.

Информация о пользователе поддерживается базой данных приложения, а также возможна интеграция серверной части LDAP.

**Пользователь**

Объект «Пользователь» имеет различные свойства, наиболее важными из них являются:

*   `code`\- имя пользователя для входа

*   `name`\- отображаемое имя

*   `password`\- пароль (хранится в зашифрованном виде в базе данных)

*   `blocked`\- заблокирован ли пользователь

*   `activateOn`\- время, с которого должен быть активирован доступ

*   `expiresOn`\- время, с которого должен истечь срок действия доступа

*   `groups`\- группы, назначенные пользователю

*   `roles`\- роли, назначенные пользователю

*   `permissions`\- явные разрешения, предоставленные пользователю


, и связаны с авторизацией, которую мы увидим в следующем разделе `groups`.`roles``permissions`

[](#authorization)Авторизация
-----------------------------

Авторизация, также называемая контролем доступа, — это процесс определения прав доступа к ресурсам в приложении.

Авторизация — важнейший элемент любого приложения, но она может быстро стать очень сложной. Основанная на простоте [Apache Shiro](http://shiro.apache.org) , открытая платформа Axelor предоставляет очень простой, но мощный способ определения правил авторизации.

Специальный пользователь `admin`и члены группы `admins`имеют полный доступ ко всем ресурсам.

**Функции**

*   Разрешения на основе ролей

*   Разрешение определяет единое правило доступа (более высокая степень детализации).

*   Группы предназначены для организационной структуры, но также поддерживают роли и разрешения.

*   Запретить все, предоставить выборочно (доказано, что это наиболее безопасно, поскольку по умолчанию все разрешения запрещены)

*   Правила разрешений на уровне пакета


Авторизация состоит из четырех основных элементов: разрешения, роли, группы и пользователи. Они представлены соответствующими объектами домена поддержки , `Permission`и `Role`соответственно .`Group``User`

**Объекты**

*   `User`есть один`Group`

*   `User`имеет много`Role`

*   `User`имеет много`Permission`

*   `Group`имеет много`Role`

*   `Group`имеет много`Permission`

*   `Role`имеет много`Permission`


Взаимосвязь между объектами авторизации позволяет достичь более высокого уровня детализации контроля доступа.

**Разрешение**

Объект разрешения определяет правило доступа. Он имеет следующие свойства:

*   `name`\- имя разрешения

*   `object`\- имя объекта (имя класса или имя пакета подстановочного знака)

*   `canRead`\- давать ли разрешение на чтение

*   `canWrite`\- давать ли разрешение на обновление

*   `canCreate`\- давать ли разрешение на создание

*   `canRemove`\- давать ли разрешение на удаление

*   `canExport`\- давать ли разрешение на экспорт данных

*   `condition`\- условие разрешения (предложение JPQLwhere с позиционными параметрами)

*   `conditionParams`\- список параметров условия, разделенный запятыми (оценивается в соответствии с текущим контекстом)


Не `condition`является обязательным, а логические флаги разрешаются только, то есть `false` значение не означает отказ.

Некоторые примеры разрешений (псевдокод):

имя: perm.sale.read.all
объект: com.axelor.sale.db.\*
можноЧитать: правда

имя: perm.sale.create.all
объект: com.axelor.sale.db.\*
можетСоздать: правда

имя: perm.sale.self
объект: com.axelor.sale.db.Order
можноЧитать: правда
можно написать: правда
можноУдалить: правда
canExport: правда
условие: self.createdBy = ?
УсловияПараметры: \_\_user\_\_

Первое правило предоставляет разрешение только на чтение всем объектам в `com.axelor.sale.db`пакете. Второе правило предоставляет разрешение на создание всем объектам в `com.axelor.sale.db`пакете. Третье правило предоставляет `com.axelor.sale.db.Order`пользователю-создателю разрешения на чтение, запись, удаление и экспорт.

Разрешение разрешений выполняется в следующем порядке:

*   проверить разрешения, назначенные объекту пользователя

*   проверить разрешения, назначенные ролям пользователя

*   проверьте разрешения, назначенные группе пользователя

*   проверьте разрешения, назначенные ролям группы


[](#view-access)Просмотр доступа
--------------------------------

Подобно авторизации объекта, права доступа к просмотру могут использоваться для управления полями просмотра объекта для пользователей, групп и ролей.

Объекты, `Permission (fields)`определенные в `User`, `Group`и `Role`можно использовать для определения правил разрешений для элемента просмотра.

Правила разрешений применяются ко всем представлениям, связанным с данным объектом. Элементы представления должны иметь имя, чтобы можно было определить для них правило.

Правило также позволяет устанавливать условия на стороне клиента (выражения js) для управления доступом только для чтения/видимостью полей/элементов.

Некоторые примеры (псевдокод):

Определите правило, чтобы скрыть общую сумму

имя: perm.sales.hide-total
объект: com.axelor.sale.db.Order
правила:
поле: общая сумма
можноЧитать: ложь
можно написать: ложь
канэкспорт: ложь

Определите правило для управления полем клиента

имя: perm.sales.customer-change
объект: com.axelor.sale.db.Order
правила:
поле: клиент
можноЧитать: правда
можно написать: правда
canExport: правда
readonlyIf: подтверждено && \_\_group\_\_ == 'менеджер'
скрытьЕсли: \_\_group\_\_ == 'пользователь'

Первое правило скрывает `totalAmount`поле из представлений. Второе правило определяет, как `customer`поле должно вести себя в зависимости от группы пользователей.

В отличие от правил разрешений объектов, правила разрешений просмотра следуют `Grant all → Deny Selectively`стратегии.

[](#single-sign-on)Единая точка входа
-------------------------------------

Единый вход в Axelor Open Platform опирается на различные клиенты [механизма безопасности PAC4J](http://www.pac4j.org) . Существует два типа клиентов: [прямые и косвенные клиенты](https://www.pac4j.org/docs/clients.html#1-direct-vs-indirect-clients) .

Для непрямых клиентов пользователь перенаправляется к внешнему поставщику удостоверений для входа в систему, а затем обратно в приложение. Если URL-адрес обратного вызова не настроен, по умолчанию используется `application.base-url`\+ «/callback».

axelor-config.properties

    # Single sign-on common configuration
    #
    # callback URL for all indirect clients (defaults to application.base-url + "/callback")
    auth.callback-url = http://localhost:8080/open-platform-demo/callback



Вы можете определить, как следует обращаться с пользователями, предоставленными централизованной аутентификацией. Вы можете выбирать между `create`(создавать и обновлять пользователей), `link`(только обновлять пользователей) и `none`(ничего не делать). Вы также можете указать группу по умолчанию для новых пользователей. Если вам нужно что-то более продвинутое, вы можете переопределить `AuthPac4jUserService`.

axelor-config.properties

    # user provisioning: create / link / none
    auth.user.provisioning = create
    # default group for created users
    auth.user.default-group = users



Вы можете определить, какой URL-адрес выхода из системы использовать, если `url`конечной точке выхода из системы не предоставлен параметр запроса. Вы также можете определить шаблон URL-адреса выхода из системы, которому `url`должен соответствовать параметр (по умолчанию разрешены только относительные URL-адреса). По умолчанию выполняется только локальный выход из системы, но вы можете выбрать, следует ли также выполнять центральный выход (должен поддерживаться настроенной центральной аутентификацией).

axelor-config.properties

    # logout URL
    auth.logout.default-url =
    # logout URL pattern
    auth.logout.url-pattern =
    # remove profiles from session
    auth.logout.local = true
    # call identity provider logout endpoint
    auth.logout.central = false



Отражение используется для настройки клиентов аутентификации. Синтаксис ключей свойств `auth.provider.<provider-name>.<setting-name>`: . Ниже описано несколько встроенных поставщиков с настройками по умолчанию, которые можно переопределить. Для особых нужд вы можете вручную настроить [любые другие клиенты, поддерживаемые pac4j,](http://www.pac4j.org/docs/clients.html) используя собственное имя поставщика. Вы даже можете создавать и использовать свои собственные клиенты аутентификации.

Поставщик аутентификации обычно состоит из клиента и его конфигурации. Есть несколько базовых настроек, общих для всех провайдеров. Все небазовые настройки передаются в конфигурацию клиента или в сам клиент.

Настройки базового поставщика аутентификации:



Параметр

Описание

`client`

имя класса клиента

`title`

заголовок, отображаемый на странице входа

`icon`

значок, отображаемый на странице входа в систему

`absolute-url-required`

укажите, требуются ли этому клиенту абсолютные URL-адреса (по умолчанию — false)

`exclusive`

если есть только один провайдер, укажите, является ли он эксклюзивным, то есть мы не показываем страницу входа по умолчанию (по умолчанию false)

Пример пользовательской конфигурации:

axelor-config.properties

    auth.provider.my-provider.client = org.pac4j.oidc.client.GoogleOidcClient
    auth.provider.my-provider.title = My Google Provider
    auth.provider.my-provider.icon = img/signin/google.svg
    auth.provider.my-provider.absolute-url-required = false
    auth.provider.my-provider.exclusive = false
    auth.provider.my-provider.client-id = 127736102816-tc5mmsfaasa399jhqkfbv48nftoc55ft.apps.googleusercontent.com
    auth.provider.my-provider.secret = qySuozNl72zzM5SKW-0kczwV



Вот клиент есть `org.pac4j.oidc.client.GoogleOidcClient`и его конфигурация `org.pac4j.oidc.config.OidcConfiguration`(автоматически определяется от клиента). `client-id`и `secret`устанавливаются в конфигурации, если свойства существуют. В противном случае мы пытаемся установить их на самом клиенте. Это делается с помощью отражения Java.

Конфигурация посредством отражения поддерживает строки настройки, примитивные/упаковочные типы, имена классов, списки строк, разделенные запятыми, и карты строковых объектов:

axelor-config.properties

    # class name
    auth.provider.oidc.state-generator = com.axelor.myapp.MyStateGenerator
    
    # list of strings
    auth.provider.saml.supported-protocols = urn:oasis:names:tc:SAML:2.0:protocol, urn:oasis:names:tc:SAML:1.1:protocol
    
    # string-object map
    auth.provider.oidc.custom-params.display = popup
    auth.provider.oidc.custom-params.prompt = none



Если вам нужна большая гибкость, вы можете определить свой собственный клиент и выполнить настройку на Java:

    public class MyOidcClient extends OidcClient {
      public MyOidcClient() {
        OidcConfiguration config = new OidcConfiguration();
        config.setStateGenerator(new MyStateGenerator());
        config.setCustomParams(Map.of("display", "popup", "prompt", "none"));
        // etc.
    
        setConfiguration(config);
      }
    }

Джава![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Каждый клиент должен иметь уникальное имя. Имена поставщиков в ключах свойств используются только для группировки настроек. Если вы хотите использовать один и тот же клиент для нескольких провайдеров, вам необходимо убедиться, что у них разные имена.

Кроме того, если у вас есть несколько поставщиков аутентификации, вы можете использовать это `auth.provider-order`свойство, чтобы указать порядок, в котором они отображаются на странице входа.

axelor-config.properties

    # My OIDC 1
    auth.provider.my-oidc1.client = org.pac4j.oidc.client.OidcClient
    # name defaults to client’s simple class name, ie. "OidcClient"
    auth.provider.my-oidc1.name = MyOidcClient1
    # ...
    
    # My OIDC 2
    auth.provider.my-oidc2.client = org.pac4j.oidc.client.OidcClient
    # name defaults to client’s simple class name, ie. "OidcClient"
    auth.provider.my-oidc2.name = MyOidcClient2
    # ...
    
    # comma-separated list of provider names
    auth.provider-order = my-oidc1, my-oidc2



### [](#openid-connect)OpenID Connect

Требуются идентификатор клиента и настройки секрета клиента. Некоторым провайдерам могут потребоваться дополнительные настройки.

#### [](#built-in-openid-connect-providers)Встроенные поставщики OpenID Connect

axelor-config.properties

    # Keycloak OpenID Connect
    # Client: org.pac4j.oidc.client.KeycloakOidcClient
    #
    # Keycloak client ID
    auth.provider.keycloak.client-id = demo-app
    # Keycloak client secret
    auth.provider.keycloak.secret = 233d1690-4498-490c-a60d-5d12bb685557
    # provider authentication realm
    auth.provider.keycloak.realm = demo-app
    # Keycloak server base URI
    auth.provider.keycloak.base-uri = http://localhost:8083/auth
    
    # Google
    # Client: org.pac4j.oidc.client.GoogleOidcClient
    #
    # Google client ID
    auth.provider.google.client-id = 127736102816-tc5mmsfaasa399jhqkfbv48nftoc55ft.apps.googleusercontent.com
    # Google client secret
    auth.provider.google.secret = qySuozNl72zzM5SKW-0kczwV
    
    # Azure Active Directory
    # Client: org.pac4j.oidc.client.AzureAd2Client
    #
    # Azure Active Directory client ID
    auth.provider.azure.client-id = 53baf26b-526d-4f5c-e08a-dc207a808854
    # Azure Active Directory client secret
    auth.provider.azure.secret = NMubGVqkcDwwGs6fa01tBBqlkTisfUd4nCpYgcxxx=
    # Azure Active Directory tenant ID
    auth.provider.azure.tenant = 491caf37-da1b-774c-b91f-f428b77d5055
    
    # Apple
    # Client: org.pac4j.oidc.client.AppleClient
    #
    # Apple client ID
    auth.provider.apple.client-id =
    # Apple client secret
    auth.provider.apple.secret =



#### [](#generic-openid-connect-provider)Общий поставщик OpenID Connect

Вам необходимо указать URI обнаружения, т.е. URI документа, который предоставляет подробную информацию о конфигурации провайдера OpenID Connect.

Вы можете усилить безопасность, используя `nonce`параметр, который представляет собой случайное значение, генерируемое вашим приложением, которое включает защиту от повтора, если она присутствует.

Вы можете определить поток, который хотите использовать, указав тип ответа и режим ответа. Для типа ответа, если значение равно `code`, запускается базовый поток, требующий обращения `POST`к конечной точке токена для получения токенов. Если значение равно `token id_token`или `id_token token`, запускает неявный поток, требующий использования JavaScript в URI перенаправления для получения токенов из URI `#fragment`. Если для режима ответа установлено значение `form_post`, параметры ответа на авторизацию кодируются как значения формы HTML, которые автоматически отправляются в агент пользователя.

Вы можете настроить область действия. В этом случае значение должно начинаться со строки, `openid`а затем включать `profile`, `email`и/или любые другие сведения о пользователе, поддерживаемые настроенным клиентом OpenID Connect.

axelor-config.properties

    # Client: org.pac4j.oidc.client.OidcClient
    #
    # title
    auth.provider.oidc.title = My OpenID Connect
    # icon URL (a default one is used if not specified)
    auth.provider.oidc.icon = img/signin/openid.svg
    
    auth.provider.oidc.client-id = 788339d7-1c44-4732-97c9-134cb201f01f
    auth.provider.oidc.secret = we/31zi+JYa7zOugO4TbSw0hzn+hv2wmENO9AS3T84s=
    
    auth.provider.oidc.discovery-uri = https://login.microsoftonline.com/38c46e5a-21f0-46e5-940d-3ca06fd1a330/.well-known/openid-configuration
    #auth.provider.oidc.use-nonce = true
    #auth.provider.oidc.response-type = id_token
    #auth.provider.oidc.response-mode = form_post
    #auth.provider.oidc.scope = openid email profile phone



### [](#oauth)OAuth

#### [](#built-in-oauth-providers)Встроенные поставщики OAuth

Требуются ключ клиента и настройки секрета клиента. Некоторым провайдерам могут потребоваться дополнительные настройки.

axelor-config.properties

    # OAuth
    
    # Client: org.pac4j.oauth.client.FacebookClient
    #
    # Facebook client key
    auth.provider.facebook.key =
    # Facebook client secret
    auth.provider.facebook.secret =
    
    # Client: org.pac4j.oauth.client.GitHubClient
    #
    # GitHub client key
    auth.provider.oauth.github.key =
    # GitHub client secret
    auth.provider.oauth.github.secret =



#### [](#generic-oauth-2-0-provider)Общий поставщик OAuth 2.0

Вы можете настроить URL-адрес аутентификации (где клиенты аутентифицируются), URL-адрес токена (где клиенты получают токены идентификации и доступа) и преобразователь атрибутов профиля.

axelor-config.properties

    # Generic OAuth 2.0
    # Client: org.pac4j.oauth.client.GenericOAuth20Client
    #
    # title
    auth.provider.oauth.title = My OAuth 2.0
    # icon URL (a default one is used if not specified)
    auth.provider.oauth.icon = img/signin/oauth.svg
    
    # client key
    auth.provider.oauth.key =
    # client secret
    auth.provider.oauth.secret =
    
    # authentication URL
    auth.provider.oauth.auth-url =
    # token URL
    auth.provider.oauth.token-url =
    # profile attributes: map of key: type|tag
    # supported types: Integer, Boolean, Color, Gender, Locale, Long, URI, String (default)
    auth.provider.oauth.profile-attrs.age = Integer|age
    auth.provider.oauth.profile-attrs.is_admin = Boolean|is_admin



### [](#saml)SAML

Вы можете настроить вход в систему с помощью любого поставщика удостоверений SAML, используя протокол SAML v2.0. Базовая конфигурация состоит из пути к хранилищу ключей, пароля хранилища ключей, пароля закрытого ключа, пути к метаданным поставщика удостоверений и пути к метаданным поставщика услуг.

Этот поставщик требует абсолютных URL-адресов и по умолчанию является эксклюзивным.

axelor-config.properties

    # SAML
    # Client: org.pac4j.saml.client.SAML2Client
    
    # Basic configuration
    #
    # path to keystore
    auth.provider.saml.keystore-path = path/to/samlKeystore.jks
    # value of the -storepass option for the keystore
    auth.provider.saml.keystore-password = open-platform-demo-passwd
    # value of the -keypass option
    auth.provider.saml.private-key-password = open-platform-demo-passwd
    # path to IdP metadata
    auth.provider.saml.identity-provider-metadata-path = http://localhost:9012/simplesaml/saml2/idp/metadata.php
    # path to SP metadata
    auth.provider.saml.service-provider-metadata-path = path/to/sp-metadata.xml



По умолчанию клиент SAML будет принимать утверждения на основе предыдущей аутентификации в течение одного часа, но вы можете изменить это поведение. Идентификатор объекта поставщика услуг по умолчанию имеет значение `auth.callback-url`\+ «?client\_name=SAML2Client», но вы можете настроить его.

axelor-config.properties

    # Additional configuration
    #
    # accept assertions based on a previous authentication for one hour by default
    auth.provider.saml.maximum-authentication-lifetime = 3600
    # custom SP entity ID
    auth.provider.saml.service-provider-entity-id = sp.test.pac4j



Вы можете контролировать такие аспекты запроса аутентификации, как принудительная и/или пассивная аутентификация.

axelor-config.properties

    # Advanced configuration
    #
    # forced authentication
    auth.provider.saml.force-auth = false
    # passive authentication
    auth.provider.saml.passive = false



Вы можете определить тип привязки для запроса аутентификации.

axelor-config.properties

    # binding type for the authentication request: SAML2_POST_BINDING_URI / SAML2_POST_SIMPLE_SIGN_BINDING_URI / SAML2_REDIRECT_BINDING_URI
    auth.provider.saml.authn-request-binding-type = SAML2_POST_BINDING_URI



Вы можете определить тип привязки для ответа аутентификации.

axelor-config.properties

    # binding type for the authentication response: SAML2_POST_BINDING_URI / SAML2_ARTIFACT_BINDING_URI
    auth.provider.saml.response-binding-type = SAML2_POST_BINDING_URI



Согласно спецификации SAML, запрос аутентификации не должен содержать NameQualifier, если объект SP имеет формат nameid-format:entity. Однако некоторые поставщики удостоверений требуют наличия этой информации. Вы можете принудительно использовать NameQualifier в запросе.

axelor-config.properties

    # force a NameQualifier in the request (defaults to false)
    auth.provider.saml.use-name-qualifier = true



Вы можете разрешить запросу аутентификации, отправляемому поставщику удостоверений, указывать индекс использования атрибутов и индекс службы потребителя утверждений.

axelor-config.properties

    # attribute consuming index
    auth.provider.saml.attribute-consuming-service-index = -1
    # assertion consumer service index
    auth.provider.saml.assertion-consumer-service-index = -1



Вы можете настроить поддерживаемые алгоритмы и методы дайджеста для первоначального запроса аутентификации.

axelor-config.properties

    # list of blacklisted signature signing algorithms
    auth.provider.saml.blacklisted-signature-signing-algorithms =
    # list of signature algorithms
    auth.provider.saml.signature-algorithms =
    # list of signature reference digest methods
    auth.provider.saml.signature-reference-digest-methods =
    # signature canonicalization algorithm
    auth.provider.saml.signature-canonicalization-algorithm =



По умолчанию утверждения должны быть подписаны, но это можно отключить. Вы также можете включить подписание запросов на аутентификацию и выход из системы.

axelor-config.properties

    # whether assertions must be signed (defaults to true)
    auth.provider.saml.wants-assertions-signed = true
    # enable signing of authentication requests (defaults to false)
    auth.provider.saml.authn-request-signed = true
    # enable signing of logout requests sent to the IdP (defaults to false)
    auth.provider.saml.sp-logout-request-signed = true



### [](#cas)КАС

Чтобы войти в систему с помощью CAS-сервера, вам необходимо настроить URL-адрес входа в CAS и/или URL-адрес префикса CAS (если требуются разные URL-адреса). Вы можете определить протокол CAS, который хотите поддерживать (по умолчанию CAS30).

Этот провайдер по умолчанию является эксклюзивным.

axelor-config.properties

    # CAS
    # Client: org.pac4j.cas.client.CasClient
    
    # Application configuration
    #
    # login URL of CAS server
    auth.provider.cas.login-url = https://localhost:8443/cas/login
    # CAS prefix URL
    auth.provider.cas.prefix-url = https://localhost:8443/cas
    # CAS protocol: CAS10 / CAS20 / CAS20_PROXY / CAS30 (default) / CAS30_PROXY / SAML
    auth.provider.cas.protocol = CAS30



Доступны различные параметры.

axelor-config.properties

    # Various parameters
    #
    # encoding used for parsing the CAS responses
    auth.provider.cas.encoding = UTF-8
    # whether the renew parameter will be used
    auth.provider.cas.renew = false
    # whether the gateway parameter will be used
    auth.provider.cas.gateway = false
    # time tolerance for the SAML ticket validation
    auth.provider.cas.time-tolerance = 1000
    # class name for specific UrlResolver
    auth.provider.cas.url-resolver =
    # class name for default TicketValidator
    auth.provider.cas.default-ticket-validator =



Вы можете включить поддержку прокси.

axelor-config.properties

    # proxy support by specifying a CasProxyReceptor
    auth.provider.cas.proxy-receptor = org.pac4j.cas.client.CasProxyReceptor



Вы можете указать собственную реализацию интерфейса [LogoutHandler](https://github.com/pac4j/pac4j/blob/master/pac4j-core/src/main/java/org/pac4j/core/logout/handler/LogoutHandler.java) .

axelor-config.properties

    # class name for specific `LogoutHandler`
    auth.provider.cas.logout-handler =



#### [](#other-cas-clients)Другие клиенты CAS

`CasClient`Встроена только поддержка. Если вы хотите использовать другой вид CAS-клиента, вам нужно настроить его вручную:

axelor-config.properties

    auth.provider.direct-cas.client = org.pac4j.cas.client.direct.DirectCasClient
    auth.provider.direct-cas.login-url = https://localhost:8443/cas/login
    auth.provider.direct-cas.prefix-url = https://localhost:8443/cas



[](#ldap)ЛДАП
-------------

Чтобы включить аутентификацию LDAP, вам обычно требуется как минимум такая конфигурация:

axelor-config.properties

    # LDAP
    
    # server URL (SSL is automatically enabled with ldaps protocol)
    auth.ldap.server.url = ldap://localhost:389
    
    # search base suffix for the users
    auth.ldap.user.base = ou=users,dc=example,dc=com
    
    # search base suffix for the groups
    auth.ldap.group.base = ou=groups,dc=example,dc=com



При необходимости вы можете настроить поиск пользователей и групп для вашего сервера LDAP.

axelor-config.properties

    # template to search users by user identifier
    auth.ldap.user.filter = (uid={0})
    
    # user identifier attribute: uid / cn
    auth.ldap.user.id-attribute = uid
    
    # template to search groups by user identifier
    auth.ldap.group.filter = (uniqueMember=uid={0},ou=users,dc=example,dc=com)



Если вы настроите системного пользователя, [LdapProfileService](https://github.com/pac4j/pac4j/blob/master/pac4j-ldap/src/main/java/org/pac4j/ldap/profile/service/LdapProfileService.java) сможет создавать, обновлять и удалять профили.

axelor-config.properties

    # system user
    auth.ldap.server.auth.user = uid=admin,ou=system
    # system password
    auth.ldap.server.auth.password = secret



Создание/обновление пользователей на стороне приложения контролируется конфигурацией [`auth.user.provisioning`](#auth-user-provisioning). В базовой реализации доступ к серверу LDAP доступен только для чтения. Если вы хотите добиться полной синхронизации, вам необходимо настроить пользователя системы и реализовать собственную логику синхронизации.

Простой пример обновления адреса электронной почты пользователя:

    public class MyUserRepository extends UserRepository {
      @Inject private AxelorLdapProfileService axelorLdapProfileService;
    
      @Override
      public User save(User user) {
        final LdapProfile profile = axelorLdapProfileService.findById(user.getCode());
    
        if (profile != null) {
          profile.addAttribute(AxelorLdapProfileDefinition.EMAIL, user.getEmail());
          axelorLdapProfileService.update(profile, null);
        }
    
        return super.save(user);
      }
    }

Джава![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Вы можете настроить механизм SASL и безопасность соединения.

axelor-config.properties

    # SASL authentication type: simple (default) / CRAM-MD5 / DIGEST-MD5 / EXTERNAL / GSSAPI
    auth.ldap.server.auth.type = simple
    
    # use StartTLS (defaults to false)
    auth.ldap.server.starttls = true



Для конфигурации SSL и startTLS вы можете настроить хранилище доверенных сертификатов, хранилище ключей или доверенные сертификаты.

axelor-config.properties

    # truststore
    auth.ldap.server.ssl.trust-store.path =
    auth.ldap.server.ssl.trust-store.password =
    auth.ldap.server.ssl.trust-store.type =
    auth.ldap.server.ssl.trust-store.aliases =
    
    # keystore
    auth.ldap.server.ssl.key-store.path =
    auth.ldap.server.ssl.key-store.password =
    auth.ldap.server.ssl.key-store.type =
    auth.ldap.server.ssl.key-store.aliases =
    
    # trust certificates
    auth.ldap.server.ssl.cert.trust-path =
    # authentication certificate
    auth.ldap.server.ssl.cert.auth-path =
    # authentication key
    auth.ldap.server.ssl.cert.key-path =



Вы можете установить таймауты.

axelor-config.properties

    # time that connections will block in seconds
    auth.ldap.server.connect-timeout =
    # time to wait for responses in seconds
    auth.ldap.server.response-timeout =



[](#basic-authentication)Базовая аутентификация
-----------------------------------------------

Вы можете включить базовую аутентификацию, которая представляет собой метод предоставления имени пользователя и пароля при отправке запроса (по умолчанию отключено). Существует два вида базовой аутентификации: `indirect`и `direct`.

*   Косвенная базовая аутентификация: пользователь должен предоставить имя пользователя и пароль для URL-адреса обратного вызова, прежде чем делать дальнейшие запросы. Когда пользователь закончит, он может вызвать конечную точку выхода из системы.

*   Прямая базовая аутентификация: пользователь должен указать имя пользователя и пароль в каждом запросе.


axelor-config.properties

    # Basic authentication
    auth.local.basic-auth = indirect, direct

