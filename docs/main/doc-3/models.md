Классы сущностей представляют модели предметной области и определяются с использованием формата XML.

Каждый файл должен иметь правильное объявление:

    <?xml version="1.0" encoding="UTF-8"?>
    <domain-models xmlns="http://axelor.com/xml/ns/domain-models"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://axelor.com/xml/ns/domain-models
      https://axelor.com/xml/ns/domain-models/domain-models_6.0.xsd">
    
      <!-- entity definitions here -->
    
    </domain-models>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Зарезервированные ключевые слова Java не могут использоваться в качестве имен полей. Зарезервированные ключевые слова SQL (PostgreSQL, MySQL и Oracle) не могут использоваться в качестве имен столбцов.

Давайте посмотрим на примере:

axelor-contact/src/main/resources/domains/Address.xml

    <module name="contact" package="com.axelor.contact.db" />
    
    <entity name="Contact">
      <many-to-one name="title" ref="Title"/> (1)
      <string name="firstName" required="true" /> (2)
      <string name="lastName" required="true" />
    
      <string name="fullName" namecolumn="true" search="firstName,lastName"> (3)
        <![CDATA[
        if (firstName == null && lastName == null)
            return null;
        if (title == null)
            return firstName + " " + lastName;
        return title.getName() + " " + firstName + " " + lastName;
      ]]></string>
    
      <date name="dateOfBirth"/>
    
      <string name="email" required="true" unique="true" max="100" />
      <string name="phone" max="20" massUpdate="true"/>
      <string name="notes" title="About me" large="true" />
    
      <one-to-many name="addresses" ref="Address" mappedBy="contact"/> (4)
    
      <finder-method name="findByName" using="fullName" /> (5)
      <finder-method name="findByEmail" using="email" />
    </entity>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

определить объект, `title`ссылающийся на поле «многие к одному»`Title`

**2**

определить строковое поле`firstName`

**3**

определить вычисляемое строковое поле`fullName`

**4**

определить объект `addresses`, ссылающийся на поле «один ко многим»`Address`

**5**

определить собственный метод поиска`findByName`

Модель предметной области определяется с помощью `<entity>`тега и поддерживает некоторые атрибуты.

*   `name`\- название организации (должно начинаться с заглавной буквы)

*   `sequential`\- использовать ли новую последовательность идентификаторов (по умолчанию — true)

*   `cacheable`\- следует ли сделать этот объект кэшируемым (по умолчанию — false)

*   `repository=[none|default|abstract]`\- как сгенерировать класс репозитория

*   `table`\- имя таблицы для сущности

*   `logUpdates`\- включать ли ведение журнала обновлений (по умолчанию — true)

*   `extends`\- базовый класс сущности наследования

*   `implements`\- список интерфейсов для реализации (обычно пустой или подтверждающий геттер/сеттер)

*   `persistable`\- является ли эта сущность постоянной (в базе данных).

*   `strategy=[SINGLE|JOINED|CLASS]`\- стратегия наследования (по умолчанию SINGLE)

*   `equalsIncludeAll`\- включать ли все простые нефункциональные поля в тест на равенство (по умолчанию — false) — _новое в версии 5.4_

*   `jsonAttrs`\- включать/отключать генерацию json-поля «attrs»


Атрибут `strategy`можно использовать только для базовой сущности.

Атрибут `persistable`можно использовать для определения непостоянного класса сущности, аннотированного им, `@MappedSuperclass`который можно использовать в качестве базового класса для других сущностей.

Тег `<module>`можно использовать для определения имен пакетов сгенерированных сущностей и репозиториев:

    <!-- default behavior -->
    <module name="contact"
      package="com.axelor.contact.db"
      repo-package="com.axelor.contact.db.repo"
      table-prefix="contact" />
    
    <!-- custom behavior -->
    <module name="contact"
      package="my.models"
      repo-package="my.repos"
      table-prefix="my" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

*   `name`\- обязателен, используется для группировки сущностей в логический модуль

*   `package`\- обязателен, используется как имя Java-пакета сгенерированного класса сущности.

*   `repo-package`\- необязательно, используется как имя Java-пакета сгенерированного класса репозитория, по умолчанию`<package>.repo`

*   `table-prefix`\- не является обязательным, используется в качестве префикса имени таблицы, по умолчанию — модуль.`name`


Если имя пакета заканчивается на .db, то предпоследняя часть имени пакета используется вместо модуля `name`в качестве префикса таблицы по умолчанию, например, если имя пакета `com.axelor.sale.db`, `sale`будет использоваться в качестве префикса таблицы по умолчанию.

[](#fields)Поля
---------------

Поля разных типов используются для определения свойств модели.

Ниже приведены общие атрибуты для всех типов полей:



Атрибут

Описание

**`name`**

название поля (обязательно)

`title`

отображать заголовок поля

`help`

подробная строка справки

`column`

имя столбца базы данных (если имя поля зарезервировано в базовой базе данных)

`index`

генерировать ли индекс этого поля

`default`

значение поля по умолчанию

`required`

требуется ли значение поля

`readonly`

является ли значение поля доступным только для чтения

`unique`

уникально ли значение поля (определяет ограничение уникальности)

`insertable`

включен ли столбец в инструкции SQL INSERT, созданные поставщиком сохраняемости — _новое в версиях 5.3.8, 5.4.1_

`updatable`

включен ли столбец в операторы SQL UPDATE, созданные поставщиком сохраняемости — _новое в версиях 5.3.8, 5.4.1_

`hidden`

скрыто ли поле по умолчанию в пользовательских интерфейсах

`transient`

является ли поле временным (невозможно сохранить в базе данных)

`initParam`

использовать ли поле в качестве параметра подрядчика

`massUpdate`

разрешить ли массовое обновление в этом поле

Нереляционные поля имеют следующие дополнительные атрибуты:



Атрибут

Описание

`nullable`

разрешить сохранение нулевого значения для полей, которые по умолчанию используют системные значения по умолчанию, когда значение не указано

`selection`

имя клавиши выбора

`equalsInclude`

включено ли поле в проверку на равенство — _новое в версии 5.4_

`formula`

является ли это собственным полем формулы SQL

### [](#field-types)Типы полей

#### [](#string)Нить

Поле `<string>`используется для определения полей текстовых данных.

Поле принимает следующие дополнительные атрибуты:



Атрибут

Описание

`min`

минимальная длина текстового значения

`max`

максимальная длина текстового значения

`large`

использовать ли крупный шрифт

`search`

разделенный запятыми список имен полей, используемых компонентом пользовательского интерфейса автозаполнения для поиска.

`sequence`

использовать указанный генератор пользовательских последовательностей

`multiline`

является ли строка многострочным текстом (используется компонентами пользовательского интерфейса)

`translatable`

можно ли перевести значение поля

`password`

хранит ли поле текст пароля

`encrypted`

зашифровано ли поле ( [подробнее](#field-encryption) )

`json`

используется ли поле для хранения данных JSON

`namecolumn`

является ли это столбцом имени (используется компонентами пользовательского интерфейса для отображения записи)

пример:

    <string name="firstName" min="1" />
    <string name="lastName"/>
    <string name="notes" large="true" multiline="true"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Атрибут `translatable`можно использовать, чтобы пометить значения поля как переводимые. Например:

    <entity name="Product">
      <string name="name" translatable="true" />
    </entity>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Переведенные значения хранятся в той же общей таблице перевода (контекст не сохраняется).

Значения полей `encrypted`хранятся в базе данных с использованием зашифрованных значений AES-256. Пароль должен быть указан из файла конфигурации приложения с использованием `encryption.password`ключа.

#### [](#boolean)логическое значение

Поле `<boolean>`используется для определения полей логического типа.

пример:

    <boolean name="active" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#integer)Целое число

Поле `<integer>`используется для определения недесятичных числовых полей.



Атрибут

Описание

`min`

минимальное значение (включительно)

`max`

максимальное значение (включительно)

пример:

    <integer name="quantity" min="1" max="100"/>
    <integer name="count"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#long)Длинный

Поле `<long>`используется для определения недесятичного числового поля, значение которого не может быть представлено `integer`типом.

Избегайте использования этого типа поля, поскольку некоторые СУБД (оракул) допускают только один длинный столбец в таблице (один для `id`столбца у нас уже есть).



Атрибут

Описание

`min`

минимальное значение (включительно)

`max`

максимальное значение (включительно)

пример:

    <long name="counter"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#decimal)Десятичная дробь

Поле `<decimal>`используется для определения полей десятичного типа с использованием `java.math.BigDecimal`типа Java.



Атрибут

Описание

`min`

минимальное значение (включительно)

`max`

максимальное значение (включительно)

`precision`

точность десятичного значения (общее количество цифр)

`scale`

масштаб десятичного значения (общее количество цифр в десятичной части)

пример:

    <decimal name="price" precision="8" scale="2" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#date)Дата

Поле `<date>`используется для определения полей для хранения даты с использованием `java.time.LocalDate`типа Java.

пример:

    <date name="orderDate" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#time)Время

Поле `<time`используется для определения полей для хранения значений времени с использованием `java.time.LocalTime`типа Java.

пример:

    <time name="duration" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#datetime)ДатаВремя

Поле `<datetime>`используется для определения полей для хранения значений даты и времени с использованием `java.time.LocalDateTime`типа Java.



Атрибут

Описание

`tz`

использовать ли информацию о часовом поясе

Если `tz`true, тип Java`java.time.ZonedDateTime`

пример:

    <datetime name="startsOn" />
    <datetime name="startsOn" tz="true"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#enum)Перечисление

Поле `<enum>`используется для определения полей с типом перечисления Java.



Атрибут

Описание

`ref`

полное имя типа перечисления

пример:

    <enum name="status" ref="OrderStatus" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Перечисление `OrderStatus`должно быть определено с использованием XML-файла домена следующим образом:

Перечисление со значениями по умолчанию

    <enum name="OrderStatus">
      <item name="DRAFT" />
      <item name="OPEN" />
      <item name="CLOSED" />
      <item name="CANCELED" />
    </enum>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Перечисление с пользовательскими строковыми значениями

    <enum name="OrderStatus">
      <item name="DRAFT" value="draft" />
      <item name="OPEN" value="open" />
      <item name="CLOSED" value="closed" />
      <item name="CANCELED" value="canceled" />
    </enum>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Перечисление с пользовательскими числовыми значениями

    <enum name="OrderStatus" numeric="true">
      <item name="DRAFT" value="1" />
      <item name="OPEN" value="2" />
      <item name="CLOSED" value="3" />
      <item name="CANCELED" value="4" />
    </enum>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Для запроса JPQL по `enum`полям мы всегда должны использовать параметр запроса.

    // this is a correct way
    TypedQuery<Order> query = em.createQuery(
      "SELECT s FROM Order s WHERE s.status = :status");
    
    query.setParameter("status", OrderStatus.OPEN);
    
    // this is a wrong way
    TypedQuery<Order> query = em.createQuery(
      "SELECT s FROM Order s WHERE s.status = 'OPEN'");
    
    // using ADK query api
    Query<Order> q = Query.of(Order.class)
      .filter("self.status = :status")
      .bind("status", "OPEN");
    
    // or
    
    Query<Order> q = Query.of(Order.class)
      .filter("self.status = :status")
      .bind("status", OrderStatus.OPEN);
    
    // or directly as positional arguments
    Query<Order> q = Query.of(Order.class)
      .filter("self.status = ?1 OR self.status = ?2", "DRAFT", OrderStatus.OPEN);



В выражениях сценариев `enum`на него следует ссылаться по имени его типа. Например:

    <check
      field="confirmDate"
      if="status == OrderStatus.OPEN &amp;&amp; confirmDate == null"
      error="Invalid value..." />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#binary)Двоичный

Поле `<binary>`используется для хранения двоичных объектов.



Атрибут

Описание

`image`

если поле предназначено для хранения данных изображения

`encrypted`

зашифровано ли поле

используйте это поле только для небольших или не подлежащих повторному использованию двоичных данных, предпочтительнее использовать `many-to-one`расширение `com.axelor.meta.db.MetaFile`.

пример:

    <binary name="photo" image="true" />
    <binary name="report" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#manytoone)МногиеToОдин

Поле `<many-to-one>`используется для определения ссылочного поля с одним значением с использованием отношения «многие к одному».



Атрибут

Описание

`ref`

имя ссылочного класса сущности (FQN, если не в том же пакете)

`table`

укажите имя объединяемой таблицы.

`column2`

имя столбца внешнего ключа в базовой таблице базы данных, ссылающееся на таблицу, не являющуюся владельцем.

пример:

    <many-to-one name="customer" ref="com.axelor.contact.db.Contact" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#onetoone)Один к одному

Поле `<one-to-one>`используется для определения ссылочного поля с одним значением с использованием связи «один к одному».



Атрибут

Описание

`ref`

имя ссылочного класса сущности (FQN, если не в том же пакете)

`mappedBy`

для двунаправленных полей — имя поля на стороне владельца

`orphanRemoval`

укажите, следует ли удалять потерянные записи, если они были удалены из связи.

`table`

укажите имя объединяемой таблицы.

`column2`

имя столбца внешнего ключа в базовой таблице базы данных, ссылающееся на таблицу, не являющуюся владельцем.

    <!-- defined in Engine object -->
    <one-to-one name="car" ref="com.axelor.cars.db.Car" />
    
    <!-- defined in Cat object -->
    <one-to-one name="engine" ref="com.axelor.cars.db.Engine" mappedBy="car"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#onetomany)Один ко многим

Поле `<one-to-many>`используется для определения полей с несколькими значениями с использованием связи «один ко многим».



Атрибут

Описание

`ref`

имя ссылочного класса сущности (FQN, если не в том же пакете)

`mappedBy`

для двунаправленных полей — имя обратного поля «многие к одному»

`orphanRemoval`

удалять ли потерянные записи (по умолчанию true)

`orderBy`

указать порядок значения коллекции по данному полю

`table`

укажите имя объединяемой таблицы.

`column2`

имя столбца внешнего ключа в базовой таблице базы данных, ссылающееся на таблицу, не являющуюся владельцем.

    <one-to-many name="items" ref="OrderItem" mappedBy="order" />
    <one-to-many name="addresses" ref="Address" mappedBy="contact" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

#### [](#manytomany)МногиеToМногие

Поле `<many-to-many>`используется для определения полей с несколькими значениями с использованием отношений «многие ко многим».



Атрибут

Описание

`ref`

имя ссылочного класса сущности (FQN, если не в том же пакете)

`mappedBy`

для двунаправленных полей — имя поля на стороне владельца

`orderBy`

укажите порядок значения коллекции по данному полю.

`table`

укажите имя объединяемой таблицы.

`column2`

имя столбца внешнего ключа в базовой таблице базы данных, ссылающееся на таблицу, не являющуюся владельцем.

    <many-to-many name="taxes" ref="Tax" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

### [](#other-usages)Другое использование

#### [](#formula)Формула

Поле `formula="true"`on используется для определения фрагмента SQL (также известного как формула) вместо сопоставления свойства в столбце. Свойство такого типа доступно только для чтения (его значение вычисляется по фрагменту формулы). Это поле не будет создано/сохранено в базе данных.

Определенный фрагмент SQL может быть настолько сложным, насколько вы хотите, и может даже включать подвыборки.

Вы должны знать, что использование поля формулы требует наличия собственного предложения SQL, что может повлиять на переносимость базы данных.

    <string name="fullName" namecolumn="true" search="firstName,lastName" formula="true">
      <![CDATA[
            CASE
                WHEN title IS NULL THEN first_name || ' ' || last_name
                ELSE (SELECT contact_title.name FROM contact_title WHERE contact_title.id = title) || ' ' || first_name || ' ' || last_name
            END
      ]]>
    </string>
    
    <string name="owner" formula="true">
      <![CDATA[
            ( SELECT CASE WHEN c.type = 'owner' THEN c.firstname + ' ' + c.lastname END FROM contacts c where c.folder_id = id )
      ]]>
    </string>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

[](#index)Индекс
----------------

Тег `<index>`можно использовать для определения составного индекса.

Он определяется путем указания в `columns`атрибуте списка имен столбцов, разделенных запятыми. Имя можно определить с помощью `name`атрибута.

    <index columns="firstName,lastName,fullName" name="idx_names"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Индекс можно определить для поля с помощью `index`атрибута. Можно указать собственное имя индекса (начинающееся с префикса «idx\_»), в противном случае имя индекса по умолчанию генерируется с использованием имени таблицы и имени столбца. По умолчанию все ссылочные поля, столбец имени, имя и код автоматически индексируются.

    <string name="firstName" required="true" index="true"/>
    <string name="lastName" required="true" index="idx_contact_last_name"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

[](#unique-constraint)Уникальное ограничение
--------------------------------------------

Тег `<unique-constraint>`можно использовать для определения составного уникального ограничения.

Он определяется путем указания в `columns`атрибуте списка имен столбцов, разделенных запятыми. Имя можно определить с помощью `name`атрибута.

    <unique-constraint columns="first_name,last_name" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

[](#field-encryption)Шифрование полей
-------------------------------------

Начиная с версии 5.0, мы теперь можем шифровать конфиденциальные поля. Для использования этой функции необходимы следующие настройки приложения:

    # Encryption
    # ~~~~~
    # Set encryption password
    encryption.password = MySuperSecretKey
    
    # Set encryption algorithm (CBC or GCM)
    #encryption.algorithm = CBC

характеристики![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Мы можем пометить поля `<string>`и `<binary>`как зашифрованные следующим образом:

    <string name="myEmail" encrypted="true" />
    <binary name="myPicture" encrypted="true" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Зашифрованные значения будут длиннее фактических значений, поэтому вам следует убедиться, что размер поля достаточен для хранения зашифрованного значения в базе данных.

[](#entity-listeners)Слушатели сущностей
----------------------------------------

[Для определения прослушивателей объектов](https://javaee.github.io/javaee-spec/javadocs/javax/persistence/EntityListeners.html)`<entity-listener>` можно использовать один или несколько тегов . Это добавит аннотацию к сгенерированному классу сущности:[](https://javaee.github.io/javaee-spec/javadocs/javax/persistence/EntityListeners.html)`@EntityListeners`

    <entity name="Contact">
      ...
      <entity-listener class="com.axelor.contact.db.repo.ContactListener"/>
    </entity>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!



Атрибут

Описание

`class`

полное имя класса прослушивателя сущности

Затем вы можете определить свои собственные классы прослушивателей сущностей с методами обратного вызова, аннотированными аннотациями событий жизненного цикла, для которых они вызываются:

    public class ContactListener {
    
      // Called upon PostPersist or PostUpdate events on Contact objects.
      @PostPersist
      @PostUpdate
      private void onPostPersistOrUpdate(Contact contact) {
        System.out.println("Contact saved");
      }
    }



Аннотации событий жизненного цикла:

*   `@PrePersist`

*   `@PostPersist`

*   `@PreRemove`

*   `@PostRemove`

*   `@PreUpdate`

*   `@PostUpdate`

*   `@PostLoad`