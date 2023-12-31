В этой главе мы увидим один из основных компонентов модулей — объекты предметной области.

Объекты предметной области, также называемые моделями или сущностями, представляют собой не что иное, как представление данных в объектной форме, используемой модулями.

Объекты домена представляют собой классы JPA pojo. Открытая платформа Axelor использует [Hibernate](http://hibernate.org/orm/) в качестве поставщика JPA.

Объекты домена определяются с использованием XML в `src/main/resources/domains` папке. Затем это определение используется генератором кода для создания классов сущностей и репозиториев.

Сгенерированные классы сущностей представляют собой классы Pojo, совместимые с JPA, с некоторыми дополнительными функциями для работы с полями коллекции и вычисляемыми полями.

Сгенерированные классы репозитория предоставляют методы для операций CRUD и некоторые методы поиска. Генерацию классов репозитория можно настраивать, мы увидим это очень скоро.