В этой главе мы увидим различные варианты конфигурации, доступные для приложений Axelor Open Platform.

[](#introduction)Введение
-------------------------

Конфигурация приложения предоставляется через различные файлы конфигурации. Это:

*   `axelor-config.properties`\- конфигурация приложения

*   `persistence.xml`\- конфигурация спящего режима/jpa


Самый важный из них `axelor-config.properties`.

[](#application-configuration)Конфигурация приложения
-----------------------------------------------------

АОП считывает значения конфигурации из нескольких источников (в порядке возрастания):

*   Внутренний файл конфигурации в формате `src/main/resources`.

*   Внешний файл конфигурации, использующий `AXELOR_CONFIG`переменную среды или `axelor.config`системное свойство.

*   Переменные среды с префиксом`AXELOR_CONFIG_`

*   Системные свойства с префиксом`axelor.config.`


Каждый из этих источников переопределяет значения предыдущего. Окончательная конфигурация — это совокупность свойств, определенных всеми этими источниками. Например, свойство, настроенное с использованием свойства среды, переопределяет значение, указанное в файле axelor-config.properties.

### [](#internal-configuration)Внутренняя конфигурация

Main `axelor-config.properties`предоставляет различные значения конфигурации для приложения. Он расположен в `src/main/resources`каталоге проекта приложения.

Обратите внимание, что этот внутренний файл конфигурации является необязательным.

Формат YAML также поддерживается. `axelor-config.properties`может быть в формате YAML ( `yml`или `yaml`ext). Он должен иметь только один внутренний файл конфигурации (в свойствах или формате YAML).

### [](#external-configuration)Внешняя конфигурация

The external configuration file is similar to the internal configuration file. It can a properties file or a YAML file format.

To use external configuration file, either add `AXELOR_CONFIG` environment variable or `axelor.config` system property. Note that system properties gets preferences over the environment variable

    $ export JAVA_OPTS="-Daxelor.config=/path/to/dev.properties"

sh![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

### [](#environment-variables)Environment variables

Environment variables should be prefixed by `AXELOR_CONFIG_`. It uses the `AXELOR_CONFIG_<key>=value` format, where `<key>` is underscored uppercase equivalent of the configuration key. For example `db.default.user` becomes `AXELOR_CONFIG_DB_DEFAULT_USER`.

    $ export AXELOR_CONFIG_DB_DEFAULT_PASSWORD=secret"

sh![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

### [](#system-properties)System properties

System properties can be handed to the application through the `-D` flag during startup System properties should be prefixed by `axelor.config.`. It uses the `axelor.config<key>=value` format, where `<key>` is a setting name.

    $ export JAVA_OPTS="-Daxelor.config.db.default.password=secret"

sh![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

### [](#encoded-properties)Encoded properties

Configuration values can be encrypted. Value should be wrapped in `ENC()` to indicate that the value is encrypted: `db.default.password = ENC(<some_thing>)`

To use encrypted secrets, `config.encryptor.password` properties should be added: this is the secret key used to encrypt/decrypt data.

Others optional properties can be added to use custom encryption:

*   `config.encryptor.algorithm`:Algorithm to be used by the encryptor

*   `config.encryptor.key-obtention-iterations`: Number of hashing iterations to obtain the signing key

*   `config.encryptor.provider-name`: Name of the security provider to be asked for the encryption algorithm

*   `config.encryptor.provider-class-name`: Security provider to be used for obtaining the encryption algorithm

*   `config.encryptor.salt-generator-classname`: Salt generator to be used by the encryptor

*   `config.encryptor.iv-generator-classname`: IV generator to be used by the encryptor

*   `config.encryptor.string-output-type`: Sets the form in which String output will be encoded


The default algorithm is `PBEWITHHMACSHA512ANDAES_256`. Most of the time, default encryption configuration will be enough.

For convenience, 2 Gradle task has been added to deal with encryption :

*   `encryptText` : Encrypt a single given String

*   `encryptFile` : Search and encrypt for values wrapped with `ENC()` in configuration file


#### [](#task-encrypttext)Task 'encryptText'

To encrypt a single given String, run:

    $ ./gradlew :encryptText --text="A secret to encode" --password="MySecureKey"
    
    -------Configs-------
    config.encryptor.password = MySecureKey
    
    WARNING : Do not add property `config.encryptor.password` with the password in your configuration file.
    Use a reference to an external file : `file:<path_to_file>` as password value.
    
    -------OUTPUT-------
    EFevga4IJ68kgt+YS8nuRXt/7TmvL94aVGCU2l5WeBLDn4ie8tZM7UjypiBZA4rCTv4VogKAB1wRAJZpa3q12w==

bash![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

This will generate for you, the necessary properties and the encrypted value to used inside `ENC()`.

#### [](#task-encryptfile)Task 'encryptFile'

To search and encrypt all properties wrapped with `ENC()` in configuration file, run:

    $ ./gradlew :encryptFile --password="MySecureKey"
    
    -------Configs-------
    config.encryptor.password = MySecureKey
    
    WARNING : Do not add property `config.encryptor.password` with the password in your configuration file.
    Use a reference to an external file : `file:<path_to_file>` as password value.
    
    -------OUTPUT-------
    Found and encrypt 1 setting(s) : db.default.password

bash![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

This will encrypt all settings in the configuration file for you. By default, it looks for a configuration file in current project. If needed, that file can be overridden with parameter `--file="<path_to_file>"`. Encryption settings (`algorithm`, `key-obtention-iterations`, …​) are determinate from that configuration file. This can be overridden with CLI arguments : `--algorithm="PBEWithMD5AndTripleDES"`, …​

[](#database-settings)Database Settings
---------------------------------------

We can configure database connection settings with following properties:

    # Database settings
    # ~~~~~
    # See hibernate documentation for connection parameters
    db.default.ddl = update (1)
    db.default.url = jdbc:postgresql://localhost:5432/my-database (2)
    db.default.user = username (3)
    db.default.password = secret (4)

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

**1**

hbm2ddl option, (update, create, create-drop or validate)

**2**

the jdbc url to connect to

**3**

user name to be used to connect to the database server

**4**

user password to authenticate the user

If you want to use [MySQL](https://www.mysql.com/) use following settings:

    # Database settings
    # ~~~~~
    # See hibernate documentation for connection parameters
    db.default.ddl = update
    db.default.url = jdbc:mysql://localhost:3306/my_database
    db.default.user = username
    db.default.password = secret

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

[](#others-settings)Others Settings
-----------------------------------



Key Name

Description

Default

`application.name`

application name

My App

`application.description`

application description

`application.version`

application version

`application.author`

application author

`application.copyright`

application copyright

`application.logo`

header logo. Should be 40px in height with transparent background

img/axelor.png

`application.home`

home website. Link to be used with header logo

`application.help`

online help. Link to be used in About page

`application.mode`

application deployment mode. Can be `prod` or `dev`

dev

`application.theme`

CSS theme

default theme

`application.locale`

default locale

system default

`application.base-url`

base url of the application

`application.multi-tenancy`

enable multi-tenancy

false

`application.config-provider`

`if-feature` custom class

`application.domain-blocklist-pattern`

pattern to validate domain expressions

`application.script.cache.size`

groovy scripts cache size

500

`application.script.cache.expire-time`

groovy scripts cache entry expire time (in minutes)

10

`application.permission.disable-action`

whether to not check action permissions

false

`application.permission.disable-relational-field`

whether to not check relational fields permissions

false

`view.single-tab`

whether to use single tab layout

false

`view.max-tabs`

define the maximum opened tabs allowed

`view.menubar.location`

set menu style. Can be `left`, `top` or `both`

both

`view.toolbar.show-titles`

whether to show button titles in toolbar

false

`view.confirm-yes-no`

whether show confirm dialog with yes/no buttons (else is Cancel/OK)

false

`view.grid.selection`

if set to `checkbox`, grid widgets will have checkbox selection enabled

`view.grid.editor-buttons`

whether to show confirm/cancel buttons from grid row editor

true

`view.allow-customization`

whether to disable views customization

true

`view.adv-search.share`

whether to disable advance search sharing

true

`view.adv-search.export-full`

whether to disable export full option in advance search

true

`view.collaboration.enabled`

whether to enable view collaboration

true

`view.form.check-version`

whether to check version value for concurrent updates when switching tabs

false

`user.password.pattern`

pattern to validate user password

.{4,}

`user.password.pattern-title`

title displayed for the password pattern

"Please use at least 4 characters."

`api.pagination.max-per-page`

define the maximum number of items per page, -1 means unlimited

500

`api.pagination.default-per-page`

define the default number of items per page

40

`session.timeout`

session timeout (in minutes)

60

`session.cookie.secure`

define session cookie as secure

`encryption.password`

encryption password

`encryption.algorithm`

encryption algorithm (CBC or GCM)

`encryption.old-password`

old encryption password

`encryption.old-algorithm`

old encryption algorithm (CBC or GCM)

`reports.design-dir`

external directory for birt report designs

\\{user.home}/.axelor/reports

`reports.fonts-config`

custom fonts config path for birt report designs

`data.upload.dir`

storage path for upload files

\\{user.home}/.axelor/attachments

`data.upload.max-size`

maximum upload size (in MB)

5

`data.upload.filename-pattern`

upload filename pattern

`data.upload.allowlist.pattern`

allowlist file name pattern, only matching files will be allowed

`data.upload.blocklist.pattern`

blocklist file name pattern, matching files will be rejected

`data.upload.allowlist.types`

allowlist content type can be used to allow file upload with matching content

`data.upload.blocklist.types`

blocklist content type can be used to block file upload with matching content

`data.export.encoding`

data export encoding

UTF-8

`data.export.dir`

storage path for export action

\\{user.home}/.axelor/data-export

`data.export.max-size`

maximum number of records to export, -1 means unlimited

\-1

`data.export.fetch-size`

export fetch size

500

`data.export.separator`

default export separator

';'

`data.export.locale`

define a fixed locale for all exports

`data.import.demo-data`

whether to import demo data for the application

true

`template.search-dir`

template storage path for groovy template

\\{user.home}/.axelor/templates

`cors.allow-origin`

comma-separated list of origins to allow

'\*'

`cors.allow-credentials`

whether credentials are supported

true

`cors.allow-methods`

comma-separated list of methods to allow

GET,PUT,POST,DELETE,HEAD,OPTIONS

`cors.allow-headers`

comma-separated list of headers to allow in a request

Origin,Accept,Authorization,X-Requested-With,X-CSRF-Token,Content-Type,Access-Control-Request-Method,Access-Control-Request-Headers

`cors.expose-headers`

comma-separated list of headers to include in a response

`cors.max-age`

how long the response from a pre-flight request can be cached by clients (in seconds)

1728000

`cors.expose-headers`

comma-separated list of headers to include in a response

`quartz.enable`

whether to enable quartz scheduler

false

`quartz.thread-count`

total number of threads in quartz thread pool

3

`mail.smtp.host`

smtp server host

`mail.smtp.port`

smtp server port

`mail.smtp.user`

smtp login username

`mail.smtp.password`

smtp password

`mail.smtp.channel`

smtp encryption channel (starttls or ssl)

`mail.smtp.timeout`

smtp socket read timeout

60000

`mail.smtp.connection-timeout`

smtp socket connection timeout

60000

`mail.smtp.from`

default from attribute

`mail.imap.host`

imap server host

`mail.imap.port`

imap server port

`mail.imap.user`

imap login username

`mail.imap.password`

imap password

`mail.imap.channel`

imap encryption channel (starttls or ssl)

`mail.imap.timeout`

imap socket read timeout

60000

`mail.imap.connection-timeout`

imap socket connection timeout

60000

All specified path can use special variables:

*   `{user.home}`: reference to the home directory, `System.getProperty("user.home")`

*   `{java.io.tmpdir}`: reference to the tmp directory, `System.getProperty("java.io.tmpdir")`

*   `{year}`: current year, `YYYY` format

*   `{month}`: current month, from `1` to `12`

*   `{day}`: current day, from `1` to `31`


The differences between `prod` and `dev` mode are:

*   use minify js/css file.

*   use browser cache.

*   don’t display technical popup.


[](#example-configuration)Example configuration
-----------------------------------------------

Here is a complete configuration file with default values

    # Application Information
    # ~~~~~
    
    application.name = Axelor application
    application.description = Axelor Demo application
    application.version = 1.0.0
    application.author = Axelor
    application.copyright = Copyright (c) {year} Axelor. All Rights Reserved.
    
    # Header logo. Should be 40px in height with transparent background.
    application.logo = img/axelor-logo.png
    
    # Home website. Link to be used with header logo.
    application.home = https://www.axelor.com
    
    # Online help. Link to be used in About page.
    application.help = https://docs.axelor.com
    
    # Application deployment mode. Can be `prod` or `dev`
    application.mode = dev
    
    # CSS theme
    #application.theme =
    
    # Default Locale (en, fr, fr_FR, en_US)
    #application.locale =
    
    # Base url of the application.
    #application.base-url =
    
    # Enable multi-tenancy
    #application.multi-tenancy = false
    
    # `if-feature` custom class
    #application.config-provider = com.axelor.app.MyAppConfig
    
    # Pattern to validate domain expressions
    #application.domain-blocklist-pattern = (\\(\\s*(SELECT|DELETE|UPDATE)\\s+)|query_to_xml|some_another_function
    
    # Groovy scripts cache size
    #application.script.cache.size = 1000
    
    # Groovy scripts cache entry expire time (in minutes)
    #application.script.cache.expire-time = 20
    
    # whether to not check action permissions
    #application.permission.disable-action = false
    
    # whether to not check relational fields permissions
    #application.permission.disable-relational-field = false
    
    # View configuration
    # ~~~~~
    
    # Whether to use single tab layout
    #view.single-tab = false
    
    # Define the maximum opened tabs allowed
    #view.max-tabs = 10
    
    # Menu style (left, top, both)
    view.menubar.location = both
    
    # Whether to show button titles in toolbar
    #view.toolbar.show-titles = false
    
    # Whether show confirm dialog with yes/no buttons (else is Cancel/OK)
    #view.confirm-yes-no = false
    
    # If `checkbox`, grid widgets will have checkbox selection enabled
    #view.grid.selection =
    
    # Whether to show confirm/cancel buttons from grid row editor
    #view.grid.editor-buttons = true
    
    # Whether to disable views customization
    view.allow-customization = true
    
    # Whether to disable advance search sharing
    #view.adv-search.share = false
    
    # Whether to disable export full option in advance search
    #view.adv-search.export-full = false
    
    # Whether to disable view collaboration
    #view.collaboration.enabled = true
    
    # Whether to check version value for concurrent updates when switching tabs
    #view.form.check-version = false
    
    # Pattern to validate user password
    #user.password.pattern =
    
    # Title displayed for the password pattern
    #user.password.pattern-title =
    
    # API
    # ~~~~~
    
    # Define the maximum number of items per page
    #api.pagination.max-per-page = 500
    
    # Define the default number of items per page
    #api.pagination.default-per-page = 40
    
    # Session configuration
    # ~~~~~
    
    # Session timeout (in minutes)
    session.timeout = 60
    
    # Define session cookie as secure
    #session.cookie.secure = true
    
    # Reports
    # ~~~~~
    
    # External directory for birt report designs
    #reports.design-dir = {user.home}/.axelor/reports
    
    # Custom fonts config path for birt report designs
    #reports.fonts-config = /path/to/custom-font-config.xml
    
    # Template
    # ~~~~~
    
    # Template storage path for groovy template
    #template.search-dir = {user.home}/.axelor/templates
    
    # Encryption
    # ~~~~~
    
    # Encryption password
    #encryption.password = MySuperSecretKey
    
    # Encryption algorithm (CBC or GCM)
    #encryption.algorithm = CBC
    
    # Old Encryption password
    #encryption.old-password = MySuperSecretKey
    
    # Old Encryption algorithm (CBC or GCM)
    #encryption.old-algorithm = CBC
    
    # Database settings
    # ~~~~~
    
    # PostgreSQL
    db.default.ddl = update
    db.default.url = jdbc:postgresql://localhost:5432/axelor-demo
    db.default.user = axelor
    db.default.password = ****
    
    # MySQL
    #db.default.ddl = update
    #db.default.url = jdbc:mysql://localhost:3306/axelor_demo_dev
    #db.default.user = axelor
    #db.default.password =
    
    # Oracle
    #db.default.ddl = update
    #db.default.url = jdbc:oracle:thin:@localhost:1521:oracle
    #db.default.user = axelor
    #db.default.password =
    
    # Shared cache mode settings (ALL, DISABLE_SELECTIVE, ENABLE_SELECTIVE, NONE)
    javax.persistence.sharedCache.mode = ENABLE_SELECTIVE
    
    # Hibernate full-text search
    #hibernate.search.default.directory_provider = none
    #hibernate.search.default.indexBase = {java.io.tmpdir}/axelor
    
    # HikariCP connection pool
    #hibernate.hikari.minimumIdle = 5
    #hibernate.hikari.maximumPoolSize = 20
    #hibernate.hikari.idleTimeout = 300000
    
    # define the batch size
    #hibernate.jdbc.batch_size = 20
    
    # define the fetch size
    #hibernate.jdbc.fetch_size = 20
    
    # second-level cache factory
    #hibernate.cache.region.factory_class = jcache
    
    # second-level cache provider
    #hibernate.javax.cache.provider =
    
    # Data
    # ~~~~~
    
    # Storage path for upload files
    data.upload.dir = {user.home}/.axelor/attachments
    
    # maximum upload size (in MB)
    data.upload.max-size = 5
    
    # Upload filename pattern
    #data.upload.filename-pattern = {year}-{month}/{day}/{name}
    
    # Allowlist file name pattern, only matching files will be allowed
    #data.upload.allowlist.pattern = \\.(xml|html|jpg|png|pdf|xsl)$
    
    # Blocklist file name pattern, matching files will be rejected
    #data.upload.blocklist.pattern = \\.(svg)$
    
    # Whitelist content type can be used to allow file upload with matching content.
    #data.upload.allowlist.types = image/*,video/webm
    
    # Blacklist content type can be used to block file upload with matching content.
    #data.upload.blocklist.types = image/*,video/webm
    
    # Data export encoding
    data.export.encoding = UTF-8
    
    # Storage path for export action
    #data.export.dir = {user.home}/.axelor/data-export
    
    # Maximum number of records to export, -1 means unlimited
    #data.export.max-size = 5000
    
    # Export fetch size
    #data.export.fetch-size = 1000
    
    # default export separator
    #data.export.separator = ,
    
    # define a fixed locale for all exports
    #data.export.locale =
    
    # Whether to import demo data for the application
    data.import.demo-data = true
    
    # CORS
    # ~~~~~
    
    # Comma-separated list of origins to allow
    #cors.allow-origin = *
    
    # whether credentials are supported
    #cors.allow-credentials = true
    
    # Comma-separated list of methods to allow
    #cors.allow-methods = GET,PUT,POST,DELETE,HEAD,OPTIONS
    
    # Comma-separated list of headers to allow in a request
    #cors.allow-headers = Origin,Accept,X-Requested-With,Content-Type,Access-Control-Request-Method,Access-Control-Request-Headers
    
    # how long the response from a pre-flight request can be cached by clients
    #cors.max-age =
    
    # comma-separated list of headers to include in a response
    #cors.expose-headers =
    
    # Context values
    # ~~~~~
    
    # Custom header logo per user
    #context.appLogo = com.axelor.some.Class:getAppLogo
    
    # Custom style
    #context.appStyle = com.axelor.some.Class:getAppStyle
    
    # Quartz Scheduler
    
    # Whether to enable quartz scheduler
    #quartz.enable = true
    
    # Total number of threads in quartz thread pool
    #quartz.thread-count = 3
    
    # Auth
    # ~~~~~
    
    # comma-separated list of provider names
    #auth.provider-order =
    
    # Default callback URL (for indirect clients)
    #auth.callback-url =
    
    # user provisioning: create / link / none
    #auth.user.provisioning = none
    
    # default group for created users
    #auth.user.default-group = users
    
    # attribute used as the value for the principal name.
    #auth.user.principal-attribute = email
    
    # logout URL
    #auth.logout.default-url =
    
    # logout URL pattern
    #auth.logout.url-pattern =
    
    # remove profiles from session
    #auth.logout.local = true
    
    # call identity provider logout endpoint
    #auth.logout.central = false
    
    # enable indirect and/or direct basic auth
    #auth.local.basic-auth = indirect, direct
    
    
    # Google OpenID Connect
    # ~~~~~
    
    # client ID
    #auth.provider.google.client-id =
    # client secret
    #auth.provider.google.secret =
    
    # Keycloak OpenID Connect
    # ~~~~~
    
    # client ID
    #auth.provider.keycloak.client-id = demo-app
    # client secret
    #auth.provider.keycloak.secret = 233d1690-4498-490c-a60d-5d12bb685557
    
    # authentication realm
    #auth.provider.keycloak.realm = demo-app
    # Keycloak server base URI
    #auth.provider.keycloak.base-uri = http://localhost:8083/auth
    
    # SAML 2.0
    # ~~~~~
    
    # path to keystore
    #auth.provider.saml.keystore-path = {java.io.tmpdir}/samlKeystore.jks
    # value of the -storepass option for the keystore
    #auth.provider.saml.keystore-password = open-platform-demo-passwd
    # value of the -keypass option
    #auth.provider.saml.private-key-password = open-platform-demo-passwd
    
    # path to IdP metadata
    #auth.provider.saml.identity-provider-metadata-path = http://localhost:9012/simplesaml/saml2/idp/metadata.php
    
    # path to SP metadata
    #auth.provider.saml.service-provider-metadata-path = {java.io.tmpdir}/sp-metadata.xml
    # SP entity ID (defaults to auth.callback-url + "?client_name=SAML2Client")
    #auth.provider.saml.service-provider-entity-id = sp.test.pac4j
    
    # LDAP Configuration
    # ~~~~~
    
    # server URL (SSL is automatically enabled with ldaps protocol)
    #auth.ldap.server.url = ldap://localhost:389
    # use StartTLS
    #auth.ldap.server.starttls = false
    # SASL authentication type: simple (default) / CRAM-MD5 / DIGEST-MD5 / EXTERNAL / GSSAPI
    #auth.ldap.server.auth.type = simple
    # maximum amount of time that connects will block
    #auth.ldap.server.connect-timeout =
    # maximum amount of time that operations will wait for a response
    #auth.ldap.server.response-timeout =
    
    # system user
    #auth.ldap.server.auth.user = cn=admin,dc=test,dc=com
    #auth.ldap.server.auth.password = admin
    
    # group search base
    #auth.ldap.group.base = ou=groups,dc=test,dc=com
    # a template to search groups by user login id
    #auth.ldap.group.filter = (uniqueMember=uid={0})
    
    # user search base
    #auth.ldap.user.base = ou=users,dc=test,dc=com
    # a template to search user by user login id
    #auth.ldap.user.filter = (uid={0})
    # define the user DN format
    #auth.ldap.user.dn-format =
    # define the id attribute
    #auth.ldap.user.id-attribute = uid
    # define the username attribute
    #auth.ldap.user.username-attribute = uid
    
    # path of the truststore
    #auth.ldap.server.ssl.trust-store.path =
    # password for the truststore
    #auth.ldap.server.ssl.trust-store.password =
    # type of the truststore
    #auth.ldap.server.ssl.trust-store.type =
    # aliases of the truststore
    #auth.ldap.server.ssl.trust-store.aliases =
    
    # path of the keystore
    #auth.ldap.server.ssl.key-store.path =
    # password of the keystore
    #auth.ldap.server.ssl.key-store.password =
    # type of the keystore
    #auth.ldap.server.ssl.key-store.type =
    # aliases of the keystore
    #auth.ldap.server.ssl.key-store.aliases =
    
    # path of the trust certificates
    #auth.ldap.server.ssl.cert.trust-path =
    # path of the authentication certificate
    #auth.ldap.server.ssl.cert.auth-path =
    # path of the authentication key
    #auth.ldap.server.ssl.cert.key-path =
    
    # CAS configuration
    # ~~~~~
    
    # login url
    #auth.provider.cas.login-url = https://localhost:8443/cas/login
    # prefix url
    #auth.provider.cas.prefix-url = https://localhost:8443/cas
    
    # CAS validation protocol: CAS10 / CAS20 / CAS20_PROXY / CAS30 (default) / CAS30_PROXY / SAML
    #auth.provider.cas.protocol = CAS30
    
    # for logout, you can use either central logout or logout default url
    #auth.logout.central = true
    #auth.logout.default-url = https://localhost:8443/cas/logout
    
    # Mail
    # ~~~~~
    
    # smtp server host
    #mail.smtp.host = smtp.gmail.com
    
    # smtp server port
    #mail.smtp.port = 587
    
    # smtp encryption channel (starttls or ssl)
    #mail.smtp.channel = starttls
    
    # smtp username
    #mail.smtp.user = user@gmail.com
    
    # smtp password
    #mail.smtp.password = secret
    
    # smtp socket read timeout
    #mail.smtp.timeout = 60000
    
    # smtp socket connection timeout
    #mail.smtp.connection-timeout = 60000
    
    # default from attribute
    #mail.smtp.from =
    
    # imap server host
    #mail.imap.host = imap.gmail.com
    
    # imap server port
    #mail.imap.port = 993
    
    # imap encryption channel (starttls or ssl)
    #mail.imap.channel = ssl
    
    # imap username
    #mail.imap.user = user@gmail.com
    
    # imap password
    #mail.imap.password = secret
    
    # imap socket read timeout
    #mail.imap.timeout = 60000
    
    # imap socket connection timeout
    #mail.imap.connection-timeout = 60000
    
    # Logging
    # ~~~~~
    
    # Custom logback configuration
    #logging.config = /path/to/logback.xml
    
    # Storage path of logs files
    #logging.path = {user.home}/.axelor/logs
    
    # Format of file log message
    #logging.pattern.file = %d{yyyy-MM-dd HH:mm:ss.SSS} %5p ${PID:- } --- [%t] %-40.40logger{39} : %m%n
    
    # Format of console log message
    #logging.pattern.console = %clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} %clr(%5p) %clr(${PID:- }){magenta} %clr(---){faint} %clr([%15.15t]){faint} %clr(%-40.40logger{39}){cyan} %clr(:){faint} %m%n
    
    # Global logging
    logging.level.root = ERROR
    
    # Axelor logging
    
    # Log everything.
    logging.level.com.axelor = INFO
    
    # Hibernate logging
    
    # Log everything. Good for troubleshooting
    #logging.level.org.hibernate = INFO
    
    # Log all SQL DML statements as they are executed
    #logging.level.org.hibernate.SQL = DEBUG
    #logging.level.org.hibernate.engine.jdbc = DEBUG
    
    # Log all SQL DDL statements as they are executed
    #logging.level.org.hibernate.tool.hbm2ddl = INFO
    
    # Log all JDBC parameters
    #logging.level.org.hibernate.type = ALL
    
    # Log transactions
    #logging.level.org.hibernate.transaction = DEBUG
    
    # Log L2-Cache
    #logging.level.org.hibernate.cache = DEBUG
    
    # Log JDBC resource acquisition
    #logging.level.org.hibernate.jdbc = TRACE
    #logging.level.org.hibernate.service.jdbc = TRACE
    
    # Log connection pooling
    #logging.level.com.zaxxer.hikari = INFO

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

[](#jpahibernate-configuration)JPA/Hibernate Configuration
----------------------------------------------------------

The `persistence.xml` located under `src/main/resources/META-INF` provides JPA/Hibernate configuration.

A minimal persistence xml file is required to confirm JPA requirements:

persistence.xml

    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <persistence version="2.1"
      xmlns="http://xmlns.jcp.org/xml/ns/persistence" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/persistence http://xmlns.jcp.org/xml/ns/persistence/persistence_2_1.xsd">
      <persistence-unit name="persistenceUnit" transaction-type="RESOURCE_LOCAL">
        <provider>org.hibernate.jpa.HibernatePersistenceProvider</provider>
        <shared-cache-mode>ENABLE_SELECTIVE</shared-cache-mode>
      </persistence-unit>
    </persistence>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

Some JPA/Hibernate configurations can also be set in `axelor-config.properties` file :



`hibernate.hikari.minimumIdle`

minimum number of idle connections to maintain in the pool

5

`hibernate.hikari.maximumPoolSize`

maximum size that the pool is allowed to reach

20

`hibernate.hikari.idleTimeout`

maximum amount of time that a connection is allowed to sit idle in the pool

300000

`hibernate.jdbc.batch_size`

maximum number of statements batch together before asking the driver to execute the batch

20

`hibernate.jdbc.fetch_size`

JDBC fetch size

20

All others `hibernate.*` properties are also passed to Hibernate.

[](#cache-configuration)Cache Configuration
-------------------------------------------

Property `javax.persistence.sharedCache.mode` can be used to enable or disable second level caching.

Following keys can be used :

*   `ALL` : Entities are always cached even if marked as non-cacheable.

*   `ENABLE_SELECTIVE` : Entities are not cached unless explicitly marked as cacheable (with the `@Cacheable` annotation). This is the recommended configuration.

*   `DISABLE_SELECTIVE` : Entities are cached unless explicitly marked as non-cacheable.

*   `NONE` (or anything else) : Completely disable second-level cache.


`jcache` is used as second-level cache provider (default value for `hibernate.cache.region.factory_class`).

By default `Caffeine` implementation is used with pre-configured settings. If you need more control on caching, add and edit `application.conf`. See `Caffeine` configs and settings.

There is also populars caching libraries such as [Ehcache](https://www.ehcache.org/), [Hazelcast](https://hazelcast.com/), [Redis](https://redis.io/) or [Infinispan](https://infinispan.org/) that can be used instead of `Caffeine` by specifying properties `hibernate.cache.region.factory_class` and `hibernate.javax.cache.provider` :

**Infinispan :**

    implementation "org.infinispan:infinispan-hibernate-cache-v53:${infinispan_version}"
    implementation "org.infinispan:infinispan-core:${infinispan_version}"
    implementation "org.infinispan:infinispan-jcache:${infinispan_version}"

gradle![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

    hibernate.cache.region.factory_class = infinispan
    hibernate.cache.infinispan.cfg = org/infinispan/hibernate/cache/commons/builder/infinispan-configs-local.xml

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

**Redis :**

    implementation "org.redisson:redisson-hibernate-53:${redisson_version}"

gradle![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

    hibernate.cache.region.factory_class = org.redisson.hibernate.RedissonRegionFactory
    # Make sure to add Redisson YAML config in classpath

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

**Hazelcast :**

    implementation "com.hazelcast:hazelcast:${hazelcast_version}"

gradle![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

    hibernate.javax.cache.provider = com.hazelcast.cache.impl.HazelcastServerCachingProvider
    # You may need to add `-Dhazelcast.ignoreXxeProtectionFailures=true` system property

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

**Ehcache :**

    implementation "org.ehcache:ehcache:${ehcache_version}"

gradle![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

    hibernate.javax.cache.provider = org.ehcache.jsr107.EhcacheCachingProvider

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

Makes sure to add required dependencies if you want to use another caching library. Refer to providers docs for extensive configuration : all properties prefix by `hibernate.` will be used.

[](#global-context-configuration)Global Context Configuration
-------------------------------------------------------------

Besides the static configuration values, we can also provide configuration for the dynamic global context with `context.` prefix. It’s used by actions and script handlers when evaluating expressions and domain filters. The values can be referenced from expressions with special variable `__config__`.

    # Custom context
    # ~~~~~
    
    # instance
    context.hello = com.axelor.script.TestContext
    
    # instance method
    context.world = com.axelor.script.TestContext:hello
    
    # static method
    context.some = com.axelor.script.TestContext:staticMethod
    
    # static field
    context.thing = com.axelor.script.TestContext:STATIC_FIELD
    
    # static values
    context.flag = true
    context.string = some static text value
    context.number = 100

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

Now, we can use them in expressions like this:

    <field ... value="#{__config__.hello.message}" /> (1)
    <field ... value="#{__config__.world}" /> (2)
    <field ... value="#{__config__.some}" /> (3)
    <field ... value="#{__config__.thing}" /> (4)
    <field ... value="#{__config__.flag}" /> (5)

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

**1**

calls getter on the instance

**2**

calls an instance method

**3**

calls a static method

**4**

public static final field value

**5**

any constant value

[](#custom-logo)Custom Logo
---------------------------

A special context setting `context.appLogo` can be used to dynamically change header logo per user. For example:

    context.appLogo = com.axelor.custom.LogoService:getLogo

properties![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

Метод `getLogo`должен возвращать либо:

*   строка, ссылка на изображение логотипа ( `img/my-logo.png`)

*   экземпляр `MetaFile`указания на файл логотипа


Вот пример, если он возвращает `MetaFile`:

    public class LogoService {
    
      public MetaFile getLogo() {
        final User user = AuthUtils.getUser();
        if(user == null || user.getActiveCompany() == null) {
            return null;
        }
        return user.getActiveCompany().getLogo();
      }
    }


Если возвращаемое значение равно нулю, будет отображаться логотип по умолчанию, указанный в `application.logo`файле конфигурации.

[](#custom-style)Пользовательский стиль
---------------------------------------

Специальную настройку контекста `context.appStyle`можно использовать для создания собственного стиля веб-интерфейса. Например:

    context.appStyle = com.axelor.custom.StyleService:getStyle


и код:

    public class StyleService {
    
      public String getStyle() {
        // we can even read the style from database
        return "header .navbar .nav .fa-bars { color: #86bc25; }"; (1)
      }
    }


**1**

изменить цвет значка переключения боковой панели

Метод `getStyle()`должен возвращать пользовательский стиль в виде строкового значения.

Пользовательский стиль применяется в следующем порядке:

1.  стиль по умолчанию

2.  пользовательская тема, если доступна

3.  индивидуальный стиль, если он предусмотрен


Таким образом, собственный стиль всегда будет переопределять стили по умолчанию и стили темы.