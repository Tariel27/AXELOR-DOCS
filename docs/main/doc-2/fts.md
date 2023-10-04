Полнотекстовый поиск реализован в версии 5 с использованием [hibernate-search](http://hibernate.org/search) . Сейчас поиск ведется только по полям имен, кроме файлов ( `DMSFile`и `MetaFile`). Поле глобального поиска в виде сетки используется для полнотекстового поиска.

[](#configuration)Конфигурация
------------------------------

Чтобы включить полнотекстовую поддержку, предоставьте следующую конфигурацию:

    hibernate.search.default.directory_provider = filesystem
    hibernate.search.default.indexBase = {user.home}/.axelor/indexes


[](#customization)Кастомизация
------------------------------

По умолчанию доступны только файлы и пользователи. Приложение должно обеспечить пользовательскую конфигурацию индекса с использованием API поиска в спящем режиме, предоставив реализацию `com.axelor.db.search.SearchMappingContributor`.

Пример

    @Singleton
    public class MySearchMappingContributor implements SearchMappingContributor {
    
        @Override
        public void contribute(SearchMapping mapping) {
    
            // index contacts
            mapping.entity(Contact.class)
                .indexed().indexName("contact")
                .property("fullName", ElementType.FIELD).field()
                .property("addresses", ElementType.FIELD).indexEmbedded();
        }
    }


и в вашей привязке из класса модуля приложения:

    public class DemoModule extends AxelorModule {
    
        @Override
        protected void configure() {
            bind(SearchMappingContributor.class).to(MySearchMappingContributor.class);
        }
    }


Дополнительную информацию см. [в документации по hibernate-search .](https://docs.jboss.org/hibernate/search/5.7/reference/en-US/html_single/#hsearch-mapping-programmaticapi)