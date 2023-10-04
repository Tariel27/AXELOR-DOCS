Классы репозитория предоставляют методы доступа к данным и манипулирования ими для моделей предметной области.

Атрибут `repository`on `<entity>`можно использовать для настройки генерации классов репозитория.

*   `default`\- создать класс репозитория по умолчанию (это поведение по умолчанию)

*   `abstract`\- генерировать абстрактный класс репозитория (модуль может предоставлять конкретную реализацию)

*   `none`\- не генерировать класс репозитория (если это не требуется или модуль предоставляет собственный класс репозитория)


Классы репозитория дополнительно настраиваются с помощью разделов `<finder>`и `<extra-code>`. Однако всегда желательно создавать только необходимые репозитории, а если требуются дополнительные функции, создавать абстрактный репозиторий и предоставлять конкретную реализацию с большим количеством функций.

Модули могут предоставлять различные реализации репозитория и настраивать их с помощью модуля Guice (однако можно привязать только одну реализацию).

[](#finders)Искатели
--------------------

Тег `<finder>`можно использовать для определения методов поиска для классов репозитория.



Атрибут

Описание

**`name`**

имя метода, в качестве `findBy`префикса использования соглашения

**`using`**

поля, которые будут использоваться в качестве параметров метода, пользовательские параметры см. ниже.

`filter`

предоставить собственное выражение фильтра (предложение jpqlwhere)

`all`

возвращать ли все значения (по умолчанию false)

`orderBy`

имя поля для заказа результата

`cacheable`

является ли используемый запрос выбора кэшируемым

`flush`

whether the query flush mode is auto (default true)

The finder method parameters are specified by the `using` attribute value (comma-separated list). A parameter can be a field name defined above or/and a definition in the format `type:name` where `type` can be either of the following type:

*   `int`, `long`, `double`, `boolean`

*   `Integer`, `Long`, `Double`, `Boolean`

*   `String`, `BigDecimal`

*   `LocalDate`, `LocalTime`, `LocalDateTime`, `DateTime`


If all the parameters are field names and `filter` is not given then an ANDed filter on the given names is generated.

examples:

    <finder name="findByName" using="fullName" />
    <finder name="findByNameOrEmail" using="fullName,email" />
    
    <finder name="findByCountry" using="String:country"
      filter="self.country.code = :country" all="true" />
    
    <finder name="findByAnyOf" using="long:id,email,String:country"
      filter="self.id = :id or self.email = :email or self.country.code = :country"
      all="true" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

[](#extra-code)Extra Code
-------------------------

The `<extra-import>` and `<extra-code>` tags are used to define additional code to be included in generated repository classes.

Don’t use this feature extensively. Use abstract repository class and provide more features using concrete implementation. This is more readable and better supported in IDE code editors.

example:

    <extra-imports>
    <![CDATA[
    import org.slf4j.*;
    import java.util.*;
    ]]>
    </extra-imports>
    
    <extra-code>
    <![CDATA[
    protected final Logger log = LoggerFactory.getLogger(getClass());
    
    public List<String> getFooNames() {
      final List<String> names = new ArrayList<>();
      names.add("foo");
      names.add("bar");
      return names;
    }
    
    public Title saveAndLog(Title title) {
      log.info("saving Title instance: " + title.getCode());
      try {
        title = this.save(title);
      } catch (Exception e) {
        log.error("error saving Title");
      }
      return title;
    }
    ]]>
    </extra-code>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

Однако того же самого можно добиться следующим образом:

    <entity name="Title" repository="abstract">
    ...
    </entity>


и конкретная реализация сгенерирована `AbstractTitleRepository`следующим образом:

    package com.axelor.contact.db.repo;
    
    import org.slf4j.*;
    import java.util.*;
    
    public class TitleRepository extends AbstractTitleRepository {
    
      protected final Logger log = LoggerFactory.getLogger(getClass());
    
      public List<String> getFooNames() {
        final List<String> names = new ArrayList<>();
        names.add("foo");
        names.add("bar");
        return names;
      }
    
      public Title saveAndLog(Title title) {
        log.info("saving Title instance: " + title.getCode());
        try {
          title = this.save(title);
        } catch (Exception e) {
          log.error("error saving Title");
        }
        return title;
      }
    }

