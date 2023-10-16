## Интеграция с ЕАИС (Единая автоматизированная информационная система)

### Оглавление

1. [Введение](#1-введение)
2. [Предварительные условия](#2-предварительные-условия)
3. [Интеграция с ЕАИС: Генерация структуры и классов](#3-интеграция-с-еаис-генерация-структуры-и-классов)
4. [Интеграция с ЕАИС: Создание класса сервиса](#4-интеграция-с-еаис-создание-класса-сервиса)
5. [Интеграция с ЕАИС: Создание маппера](#создание-маппера)
6. [Интеграция с ЕАИС: Создание контроллера](#6-интеграция-с-еaис-создание-контроллера)
7. [Интеграция с ЕАИС: Обновление существующей декларации](#7-интеграция-с-еaис-обновление-существующей-декларации)
8. [Интеграция с ЕАИС: Сервис для сравнения новой декларации со старой](#8-интеграция-с-еaис-сервис-для-сравнения-новой-декларации-со-старой)
    * 8.1 [Метод сравнение продуктов](#метод-datacheckingproducts)
    * 8.2 [Метод для сравнения двух объектов](#метод-checkandupdate)
    * 8.3 [Метод сравнения данных ТС](#метод-datacheckingvehicle)
    * 8.4 [Метод сравнение объектов декларации](#метод-datacheckingdeclaration)
    * 8.5 [Метод для обновления "Поездки"](#метод-savedeclaration)
9. [Базовые операции CRUD](#9-базовые-операции-crud)
    * 9.1 [Cохранения](#метод-persistobject)
    * 9.2 [Удаления](#метод-removeobject)

### 1. Введение
***
Единая автоматизированная информационная система (ЕАИС) - автоматизированный учет и контроль перемещаемых товаров и транспортных средств, а также декларирование товаров и транспортных средств, их таможенное оформление.
Мы хотим интегрировать проект "Навигационная пломба ГТС" с системой ЕАИС, чтобы на основе номера транзитной декларации получать актуальные данные о каждом грузе.

### 2. Предварительные условия
***

Первым делом, мы должны получить от ЕАИС все нужные нам ссылки:
* **WSDL** - http://212.xxx.104.xxx:xxxx/TDService?wsdl
* **XSD** - http://212.xxx.104.xxx:xxxx/TDService?xsd=xsd0

Со стороны проекта **"Навигационная пломба ГТС"** технические условия:
* **JDK 8 - 11**
* База данных: **PostgreSQL, MySQL**
* **Axelor v7.0.0** и выше

### 3. Интеграция с ЕАИС: Генерация структуры и классов
***

* С помощью **WSDl** ссылки мы должны сгенерировать все нужные интерфейсы, сервисы и классы.
* Мы должны у себя в проекте указать нужный путь, куда мы должы сгенерировать классы, например:
```
C:\Users\...\IdeaProjects\Plomba\GovERP-master\modules\NavigationPlomb-AOS\electronic-navigation-seals\src\main\java\com\axelor\apps\ens\integrations\eais
```
* Если у вас **JDK 8** в терминале вводим команду
```
wsimport -Xnocompile http://212.112.104.124:8122/TDService?wsdl
```
* Для **JDK 11** и выше вы должны использовать внешние библиотеки для генерации классов **Java** из **WSDL**.

1. **Добавьте зависимость:**

Если вы используете **Maven**, добавьте следующую зависимость:
```java
<dependency>
    <groupId>org.glassfish.jaxb</groupId>
    <artifactId>jaxb-xjc</artifactId>
    <version>2.4.0-b180830.0438</version>
</dependency>
```

2. **Используйте инструмент **jaxb-xjc**:**

После добавления зависимости вы можете использовать инструмент **jaxb-xjc** для генерации классов Java из WSDL:

```java
xjc -wsdl http://212.112.104.124:8122/TDService?wsdl
```

3. **Для **Gradle** используйте следующий метод.**

В вашем **build.gradle** файле добавьте следующую зависимость:

```java
implementation 'org.glassfish.jaxb:jaxb-xjc:2.4.0-b180830.0438'
```
Это добавит **jaxb-xjc** в ваш проект.

4. **Используйте инструмент **jaxb-xjc** через **Gradle**:**

Вы можете добавить задачу в ваш **build.gradle** для генерации классов из **WSDL**:

```java
task generateJavaFromWsdl {
    doLast {
        def wsdlUrl = "http://212.112.104.124:8122/TDService?wsdl"
        def outputDir = file("$projectDir/src/main/java")

        ant.taskdef(name: 'xjc', classname: 'com.sun.tools.xjc.XJCTask', classpath: configurations.compile.asPath)
        ant.xjc(destdir: outputDir, schema: wsdlUrl, package: "your.package.name") {
            arg(value: "-wsdl")
        }
    }
}
```
Замените your.package.name на желаемое имя пакета для сгенерированных классов. После этого, когда вы запустите **./gradlew generateJavaFromWsdl**, **Gradle** выполнит задачу и сгенерирует классы Java из WSDL.

5. **Запуск:**

После добавления задачи и зависимости, выполните следующую команду:
```java
./gradlew generateJavaFromWsdl
```

### 4. Интеграция с ЕАИС: Создание класса сервиса
***

1. **После генерации классов, у себя  в проекте создаем специальный класс сервис - EAIService**
```java
public interface EAIService {

    Declaration getById(String id);
}
```
2. **Имплементация сервиса EAIServiceImpl**
```java
public class EAIServiceImpl implements EAIService {

    @Override
    public Declaration getById(String id) throws RuntimeException {
        
        ITDService itdService = new TDService().getBasicHttpBindingITDService();                //1
        
        ObjectFactory factory = new ObjectFactory();                                            //2     
        
        TDInfoRequest request = factory.createTDInfoRequest();                                  //3 
        request.setId(id);                                                                      //4 
        
        TransitDeclarationResponse transitDeclarationResponse = itdService.requestTD(request);  //5
        
        DeclarationMapper declarationMapper = Beans.get(DeclarationMapper.class);               //6

        return declarationMapper.from(transitDeclarationResponse);                              //7
    }
}
```
#1 - Этот вызов создает новый экземпляр класса **TDService**, `.getBasicHttpBindingITDService()` - вызывая этот метод у объекта **TDService**, вы получаете прокси, который позволяет вашему приложению вызывать методы удаленного веб-сервиса как будто это локальные методы.

#2 - Данная строка кода создает экземпляр класса **ObjectFactory**.

#3 - Эта строка кода создаёт экземпляр объекта **TDInfoRequest** с использованием метода **createTDInfoRequest()** объекта **factory**, который является экземпляром класса **ObjectFactory**.

#4 - Эта строка кода устанавливает значение **id** для объекта request типа **TDInfoRequest**.

#5 - Эта строка кода выполняет запрос к веб-сервису и получает ответ.

**Обращение к веб-сервису:**
  Вызывается метод **requestTD(request)** на объекте **itdService** (который представляет собой прокси для взаимодействия с веб-сервисом). Вы передаете request (объект типа TDInfoRequest с установленным идентификатором) в           качестве аргумента для этого метода.
      
**Получение ответа:**
  Веб-сервис обрабатывает ваш запрос, вероятно, выполняя некоторые операции на стороне сервера, такие как поиск в базе данных. После завершения этих операций веб-сервис возвращает ответ, который, в вашем случае, имеет       тип **TransitDeclarationResponse**.
      
**Сохранение ответа:**
  Полученный ответ сохраняется в переменной **transitDeclarationResponse**.

#6 - Эта строка кода создаёт экземпляр или получает существующий экземпляр класса **DeclarationMapper** из контейнера зависимостей или сервиса управления бинами (beans).

#7 - Эта строка кода преобразует (или "маппит") объект **transitDeclarationResponse** с помощью объекта **declarationMapper** и возвращает результат этого преобразования.

### 5. Создание маппера
***

Основная цель мапперов — преобразовать данные из одного представления в другое. 
Если вы получаете данные из внешнего источника (например, из веб-сервиса), вы можете использовать мапперы для фильтрации или очистки этих данных, прежде чем они будут использованы в вашем приложении.
```java
public class ProductMapper {

    @Inject
    private TnvedPositionCodeRepository tnvedPositionCodeRepository;

    public Product from(Good good){
        Product product = new Product();
        product.setName(good.getGoodsName());
        product.setDescription(good.getGoodsName());
        product.setGrossWeight(good.getGrossWeight());
        product.setTnvedPositionCode(tnvedPositionCodeRepository.findByCode(good.getHSCode()));
        product.setProductNumber((int) good.getItemNum());
        product.sethSCode(good.getHSCode());
        return product;
    }
}
```
Этот код представляет собой метод **from**, который преобразует объект типа Good в объект типа **Product**. 

```java
public TransportationVehicle from(String vehicleType, String vehicleRegCountry, String transportNumbers, String semiTrailerNumbers) {
        TransportationVehicle transportationVehicle = new TransportationVehicle();

        transportationVehicle.setTransportType(transportTypeRepository.findByCode(parseIntOrNull(vehicleType)));
        transportationVehicle.setCountryRegVehicle(countryRepository.findByNumericCode(vehicleRegCountry));
        if(semiTrailerNumbers != null) {
            transportationVehicle.setPlateNo(transportNumbers + "/" + semiTrailerNumbers);
        }else{
            transportationVehicle.setPlateNo(transportNumbers);
        }
        if (!isNull(transportationVehicle)){
            return transportationVehicle;
        }
        return null;
    }

    private boolean isNull(TransportationVehicle vehicle){
        return Objects.isNull(vehicle)
                || Objects.isNull(vehicle.getCountryRegVehicle())
                || Objects.isNull(vehicle.getTransportType())
                || Objects.isNull(vehicle.getPlateNo());
    }
```
Этот код представляет собой метод from, который преобразует переданные параметры (строки) в объект типа **TransportationVehicle**. 

```java
public Declaration from(TransitDeclarationResponse response) {
        if (response.getErrorMessage() != null) {
            throw new RuntimeException(response.getErrorMessage());
        }

        ProductMapper productMapper = Beans.get(ProductMapper.class);
        TransportationVehicleMapper transportationVehicleMapper = Beans.get(TransportationVehicleMapper.class);

        Declaration declaration = new Declaration();

        declaration.setRegistrationNumberTd(parseString(response.getGATDId()));
        declaration.setuId(parseString("03837639-af1a-4952-84d5-8bd43c0af0fa"));                            // После обновления декларации необходимо добавить UID

        /*if(response.getTDStatus().equals("Принята к офорлению")){
            declaration.settDStatus(StatusConstants.DECLARATION_STATUS_ACCEPTED_FOR_REGISTRATION);
        }else{
            declaration.settDStatus(StatusConstants.DECLARATION_STATUS_FORMALIZED);
        }*/
        declaration.settDStatus(StatusConstants.DECLARATION_STATUS_ACCEPTED_FOR_REGISTRATION);

        declaration.setDepartureCountry(
                countryRepository.findByNumericCode(response.getSendCountry()));
        declaration.setDestinationCountry(
                countryRepository.findByNumericCode(response.getDestinationCountry()));
        declaration.setCounterpartyName(response.getCounterPartyName());
        declaration.setCountryRegistration(
                countryRepository.findByNumericCode(response.getRegistrationCountry()));

        declaration.setFullNameDriver("Babaev Ali Karaevich");                                                     // После обновления декларации необходимо добавить ФИО
        declaration.setCountryDriver(
                countryRepository.findByNumericCode("860"));                                                       // После обновления декларации необходимо добавить страну

        TransportationVehicle transportationVehicle = transportationVehicleMapper
                .from(response.getVehicleType(), response.getVehicleRegCountry(), response.getTransportNumbers(), response.getSemiTrailerNumbers());
        if (transportationVehicle != null) {
            declaration.setTransportationVehicle(transportationVehicle);

            TransportationVehicle byPlateNumberAndRegisterCountry = transportationVehicleRepository
                    .findByPlateNumberAndRegisterCountry(transportationVehicle.getPlateNo(), transportationVehicle.getCountryRegVehicle());
            if (byPlateNumberAndRegisterCountry != null)
                declaration.setTransportationVehicle(byPlateNumberAndRegisterCountry);
        }

        declaration.setCustomsDeparture(
                customsOfficeRepository.findByCode(parseIntOrNull(response.getCustomsOrigCode())));
        declaration.setCustomsDestination(
                customsOfficeRepository.findByCode(parseIntOrNull(response.getCustomsDestCode())));

        if (response.getGoods() != null && response.getGoods().getGood() != null) {
            declaration.setProduct(response.getGoods().getGood().stream()
                    .map(productMapper::from)
                    .collect(Collectors.toList()));
        }

        return declaration;
    }
```
Данный метод from преобразует объект **TransitDeclarationResponse** в объект типа **Declaration**. Этот код иллюстрирует типичное преобразование (или "маппинг") данных из одного представления (ответ от какого-то сервиса или системы) в другое (доменный объект вашего приложения).

### 6. Интеграция с ЕАИС: Создание контроллера
***

```java
public class DeclarationController {
}
```
Класс DeclarationController является контроллером.

```java
public void setDeclarationFromOtherSystem(ActionRequest request, ActionResponse response) {
        try {
            String registrationNumberTd = (String) request.getContext().get("registrationNumberTd");
            if (registrationNumberTd == null) {
                response.setNotify(I18n.get("Not found declaration"));
                return;
            }

            Declaration declaration = eaiService.getById(registrationNumberTd);

            response.setNotify(I18n.get("Success"));
            response.setValue("declaration", declaration);
        } catch (RuntimeException exception) {
            response.setException(exception);
        }
    }
```
Этот код представляет собой метод **setDeclarationFromOtherSystem**, который предназначен для выполнения действия на основе входящего запроса **(ActionRequest)**. 
Основная цель метода — получить декларацию из другой системы на основе предоставленного номера регистрации **(registrationNumberTd)** и установить её в ответ **(ActionResponse)**.

### 7. Интеграция с ЕАИС: Обновление существующей декларации
***

1. **Создается метод updateDeclaration внутри DeclarationController**
```java
public void updateDeclaration(ActionRequest request, ActionResponse response) {
        try {
            TransportationTrip transportationTrip = request.getContext().asType(TransportationTrip.class);
            Declaration oldDeclaration = transportationTrip.getDeclaration();
            if (oldDeclaration == null) {
                response.setNotify(I18n.get("Not found declaration"));
                return;
            }
            Declaration newDeclaration = eaiService.getById(transportationTrip.getDeclaration().getRegistrationNumberTd());
            if (newDeclaration == null) {
                response.setNotify(I18n.get("The declaration was deleted"));
                return;
            }

            TransportationTrip trip = transportationTripService.saveDeclaration(transportationTrip, oldDeclaration, newDeclaration);
            response.setNotify(I18n.get("Success"));
            response.setValue("declaration", trip.getDeclaration());
        } catch (RuntimeException exception) {
            response.setException(exception);
        }
    }
```
Данный метод **updateDeclaration** предназначен для обновления декларации в контексте транспортной поездки (TransportationTrip).

* Получение объекта **TransportationTrip** из запроса: Из **request** извлекается объект **TransportationTrip**.
* С помощью сервиса **eaiService** метод пытается получить новую декларацию на основе регистрационного номера существующей декларации.
* С помощью **transportationTripService** обновляется декларация в контексте транспортной поездки.
* Если в процессе выполнения метода происходит исключение, оно перехватывается и устанавливается в ответ.

### 8. Интеграция с ЕАИС: Сервис для сравнения новой декларации со старой

#### Метод **dataCheckingProducts:**
```java
private List<Product> dataCheckingProducts(Declaration oldDeclaration, Declaration newDeclaration){
        try {
            List<Product> oldProducts = oldDeclaration.getProduct();
            List<Product> newProducts = newDeclaration.getProduct();
            List<Product> productsToRemove = new ArrayList<>();

            for (Product oldProduct : oldProducts) {
                // Поиск соответствующего продукта в новом списке по ID (или другому уникальному ключу)
                Product newProduct = newProducts.stream()
                        .filter(p -> p.gethSCode().equals(oldProduct.gethSCode()))
                        .findFirst()
                        .orElse(null);

                if (newProduct == null) {
                    // Если старого продукта нет в новом списке, добавляем его в список на удаление
                    productsToRemove.add(oldProduct);
                } else {
                    boolean isChanged = false; // Флаг для отслеживания изменений

                    // Сравниваем каждый атрибут продукта
                    if ((oldProduct.getName() == null && newProduct.getName() != null) ||
                            (oldProduct.getName() != null && !oldProduct.getName().equals(newProduct.getName()))) {
                        oldProduct.setName(newProduct.getName());
                        isChanged = true;
                    }

                    if ((oldProduct.getDescription() == null && newProduct.getDescription() != null) ||
                            (oldProduct.getDescription() != null && !oldProduct.getDescription().equals(newProduct.getDescription()))) {
                        oldProduct.setDescription(newProduct.getDescription());
                        isChanged = true;
                    }

                    if ((oldProduct.getGrossWeight() == null && newProduct.getGrossWeight() != null) ||
                            (oldProduct.getGrossWeight() != null && !oldProduct.getGrossWeight().equals(newProduct.getGrossWeight()))) {
                        oldProduct.setGrossWeight(newProduct.getGrossWeight());
                        isChanged = true;
                    }

                    if ((oldProduct.getTnvedPositionCode() == null && newProduct.getTnvedPositionCode() != null) ||
                            (oldProduct.getTnvedPositionCode() != null && !oldProduct.getTnvedPositionCode().equals(newProduct.getTnvedPositionCode()))) {
                        oldProduct.setTnvedPositionCode(newProduct.getTnvedPositionCode());
                        isChanged = true;
                    }

                    if ((oldProduct.getProductNumber() == null && newProduct.getProductNumber() != null) ||
                            (oldProduct.getProductNumber() != null && !oldProduct.getProductNumber().equals(newProduct.getProductNumber()))) {
                        oldProduct.setProductNumber(newProduct.getProductNumber());
                        isChanged = true;
                    }

                    if (isChanged) {
                        crudService.persistObject(oldProduct);
                    }
                }

            }

            // Удаление продуктов из базы данных и из старого списка
            for (Product productToRemove : productsToRemove) {
                crudService.removeObject(productToRemove);
                oldProducts.remove(productToRemove);

            }

            return oldProducts;
        }catch (Exception e) {
            LOG.error("THROW: ", e);
            throw new EaisException(e.getLocalizedMessage());
        }

    }
```
Метод **dataCheckingProducts** принимает две декларации - старую **(oldDeclaration)** и новую **(newDeclaration)**. Его цель - проверить и обновить список продуктов в старой декларации, согласно списку продуктов в новой декларации.

1. **Инициализация:**

Списки продуктов из обеих деклараций загружаются в **oldProducts** и **newProducts**.
Создается список **productsToRemove** для продуктов, которые необходимо удалить из старой декларации.

2. **Сравнение продуктов:**

Для каждого продукта из **oldProducts** метод пытается найти соответствующий продукт в newProducts на основе **hSCode**.
Если соответствующий продукт не найден в newProducts, он добавляется в список **productsToRemove**.
Если найден - продукт из **oldProducts** обновляется данными из **newProducts**, если они различаются. Если были изменения, продукт сохраняется в базе данных с помощью crudService.

3. **Удаление продуктов:**

Проходя по **productsToRemove**, метод удаляет каждый продукт из базы данных и из **oldProducts**.

4. **Обработка ошибок:**

Если в процессе выполнения метода происходит исключение, оно логируется и затем перевыбрасывается как **EaisException**.

Основная идея этого метода - обеспечить актуальность списка продуктов в **oldDeclaration** по отношению к **newDeclaration**. Если в новой декларации появились изменения (новые продукты, измененные атрибуты или удаленные продукты), старая декларация обновляется соответственно.

#### Метод **checkAndUpdate:**

```java
private <T> T checkAndUpdate(T oldValue, T newValue) {
        if (oldValue == null || (newValue != null && !oldValue.equals(newValue))) {
            return newValue;
        }
        return oldValue;
    }
```
Этот метод **checkAndUpdate** представляет собой обобщенный **(generic)** метод, который принимает два значения: старое **(oldValue)** и новое **(newValue)**. Метод проверяет, необходимо ли обновить **oldValue** значением **newValue**.

#### Метод **dataCheckingVehicle:**

```java
private TransportationVehicle dataCheckingVehicle(Declaration oldDeclaration, Declaration newDeclaration) {
        try {
            TransportationVehicle oldVehicle = oldDeclaration.getTransportationVehicle();
            TransportationVehicle newVehicle = newDeclaration.getTransportationVehicle();

            if (oldVehicle != null && newVehicle != null) {

                oldVehicle.setTransportType(checkAndUpdate(oldVehicle.getTransportType(), newVehicle.getTransportType()));
                oldVehicle.setCountryRegVehicle(checkAndUpdate(oldVehicle.getCountryRegVehicle(), newVehicle.getCountryRegVehicle()));
                oldVehicle.setPlateNo(checkAndUpdate(oldVehicle.getPlateNo(), newVehicle.getPlateNo()));

            } else {
                LOG.warn("One of the transportation vehicles is null. Old: " + oldVehicle + ", New: " + newVehicle);
            }
            return crudService.persistObject(oldVehicle);
        } catch (Exception e) {
            LOG.error("THROW: ", e);
            throw new EaisException(e.getLocalizedMessage());
        }
    }
```
Метод **dataCheckingVehicle** предназначен для проверки и, при необходимости, обновления объекта **TransportationVehicle**, связанного с **Declaration**.

#### Метод **dataCheckingDeclaration:**

```java
private Declaration dataCheckingDeclaration(Declaration oldDeclaration, Declaration newDeclaration) {
        try {
            if (oldDeclaration != null && newDeclaration != null) {

                oldDeclaration.setRegistrationNumberTd(checkAndUpdate(oldDeclaration.getRegistrationNumberTd(), newDeclaration.getRegistrationNumberTd()));
                oldDeclaration.setDepartureCountry(checkAndUpdate(oldDeclaration.getDepartureCountry(), newDeclaration.getDepartureCountry()));
                oldDeclaration.setDestinationCountry(checkAndUpdate(oldDeclaration.getDestinationCountry(), newDeclaration.getDestinationCountry()));
                oldDeclaration.setCounterpartyName(checkAndUpdate(oldDeclaration.getCounterpartyName(), newDeclaration.getCounterpartyName()));
                oldDeclaration.setCountryRegistration(checkAndUpdate(oldDeclaration.getCountryRegistration(), newDeclaration.getCountryRegistration()));
                oldDeclaration.setFullNameDriver(checkAndUpdate(oldDeclaration.getFullNameDriver(), newDeclaration.getFullNameDriver()));
                oldDeclaration.setCountryDriver(checkAndUpdate(oldDeclaration.getCountryDriver(), newDeclaration.getCountryDriver()));
                oldDeclaration.setCustomsDeparture(checkAndUpdate(oldDeclaration.getCustomsDeparture(), newDeclaration.getCustomsDeparture()));
                oldDeclaration.setCustomsDestination(checkAndUpdate(oldDeclaration.getCustomsDestination(), newDeclaration.getCustomsDestination()));
            } else {
                LOG.warn("One of the declarations is null. Old: " + oldDeclaration + ", New: " + newDeclaration);
            }

            return crudService.persistObject(oldDeclaration);
        } catch (Exception e) {
            LOG.error("THROW: ", e);
            throw new EaisException(e.getLocalizedMessage());
        }
    }
```
Метод **dataCheckingDeclaration** имеет функцию проверки и, при необходимости, обновления объекта **Declaration**.

* **Проверка объектов декларации:**

Если обе декларации **(oldDeclaration и newDeclaration)** не равны null:
Некоторые атрибуты oldDeclaration (такие как RegistrationNumberTd, DepartureCountry, DestinationCountry и так далее) обновляются значениями из newDeclaration, если они различаются, с использованием функции **checkAndUpdate**.

* **Предупреждение при отсутствии одной из деклараций:**

Если одна из деклараций равна null, выводится предупреждение с указанием, какая из деклараций отсутствует.

* **Сохранение и возврат:**

Обновленный **oldDeclaration** сохраняется с помощью **crudService** и возвращается.

* **Обработка ошибок:**

Любое возникшее исключение логируется, а затем выбрасывается как **EaisException**.

Этот метод особенно полезен, когда у вас есть две версии декларации, и вы хотите обновить старую версию с учетом изменений, найденных в новой версии, сохраняя при этом данные, которые остались неизменными.

#### Метод **saveDeclaration:**

```java
public TransportationTrip saveDeclaration(TransportationTrip trip,Declaration oldDeclaration, Declaration newDeclaration) {
        try {

            TransportationTrip transportationTrip = transportationTripRepository.find(trip.getId());
            transportationTrip.getDeclaration().setTransportationVehicle(dataCheckingVehicle(oldDeclaration, newDeclaration));
            transportationTrip.getDeclaration().setProduct(dataCheckingProducts(oldDeclaration, newDeclaration));
            transportationTrip.setDeclaration(dataCheckingDeclaration(oldDeclaration, newDeclaration));

            TransportationTrip transportationTripSaved = crudService.persistObject(transportationTrip);

            return transportationTripSaved;
        } catch (Exception e) {
            LOG.error("THROW: ", e);
            throw new EaisException(e.getLocalizedMessage());
        }
    }
```

Метод **saveDeclaration** предназначен для обновления **TransportationTrip** на основе данных из двух версий декларации: старой (**oldDeclaration**) и новой (**newDeclaration**).

* **Извлечение существующего объекта TransportationTrip:**

Метод извлекает **TransportationTrip** из репозитория по **ID**, полученному из переданного объекта **trip**.

* **Обновление транспортного средства в декларации:**

Метод вызывает функцию **dataCheckingVehicle**, чтобы проверить и, при необходимости, обновить транспортное средство в декларации на основе различий между старой и новой декларацией.

* **Обновление продуктов в декларации:**

Метод вызывает функцию **dataCheckingProducts** для проверки и обновления списка продуктов в декларации.

* **Обновление декларации:**

Метод вызывает функцию **dataCheckingDeclaration**, чтобы проверить и, при необходимости, обновить атрибуты декларации.

* **Сохранение и возврат:**

Обновленный **TransportationTrip** сохраняется с помощью **crudService** и возвращается.

* **Обработка ошибок:**

Если во время выполнения метода возникает исключение, оно логируется, и затем выбрасывается как EaisException.

Метод **saveDeclaration** является ключевым для обновления транспортной поездки на основе изменений в декларациях. Если вы изменяете данные в другой системе или из другого источника, этот метод позволит обновить вашу текущую систему, чтобы она соответствовала последним данным.

### 9. Базовые операции CRUD
***

```java
public interface CrudService {

    public <T extends Model> T persistObject(T entity);

    public <T extends Model> void removeObject(T entity);
}
```

**CrudService**, который определяет два обобщенных метода для выполнения базовых операций **CRUD (Create, Read, Update, Delete)** с сущностями.

#### Метод **persistObject:**

```java
@Override
    public <T extends Model> T persistObject(T entity) {
        if (!JPA.em().getTransaction().isActive()) {
            JPA.em().getTransaction().begin();
        }
        try {
            T savedEntity = JPA.save(entity);
            JPA.em().getTransaction().commit();
            return savedEntity;
        } catch (Exception e) {
            JPA.em().getTransaction().rollback();
            throw e;
        }
    }
```
Этот код представляет собой реализацию метода **persistObject** интерфейса **CrudService**. Он использует **JPA (Java Persistence API)** для выполнения операции сохранения объекта в базе данных. Давайте разберемся, что происходит в этой реализации:

* **Проверка транзакции:**

Сначала метод проверяет, активна ли текущая транзакция **(JPA.em().getTransaction().isActive())**. Если транзакция не активна, он начинает новую транзакцию с помощью **JPA.em().getTransaction().begin()**.

* **Попытка сохранения:**

Внутри блока **try**, метод пытается сохранить переданную сущность с использованием **JPA.save(entity)**.
После успешного сохранения сущности, транзакция фиксируется **(commit)**. Это означает, что все изменения, сделанные в этой транзакции, сохраняются в базе данных.

* **Обработка ошибок:**

Если при сохранении сущности возникает исключение, код переходит в блок catch.
В блоке **catch** текущая транзакция откатывается **(rollback)**, чтобы отменить все изменения, сделанные в этой транзакции. Это гарантирует, что база данных остается в согласованном состоянии даже при возникновении ошибки.
После отката транзакции исключение выбрасывается заново, чтобы его можно было обработать на более высоком уровне или информировать пользователя о проблеме.

Подход, примененный в этом коде, обеспечивает устойчивость и надежность при работе с базой данных. Он гарантирует, что даже если что-то пойдет не так во время сохранения объекта, база данных останется в безопасном и согласованном состоянии благодаря механизму транзакций.

#### Метод **removeObject:**

```java
@Override
    public <T extends Model> void removeObject(T entity) {
        if (!JPA.em().getTransaction().isActive()) {
            JPA.em().getTransaction().begin();
        }
        try {
            JPA.remove(entity);
            JPA.em().getTransaction().commit();
        } catch (Exception e) {
            JPA.em().getTransaction().rollback();
            throw e;
        }
    }
```

Этот код представляет собой реализацию метода **removeObject** интерфейса **CrudService**. Этот метод использует **JPA (Java Persistence API)** для удаления объекта из базы данных.
Метод **removeObject** обеспечивает безопасное удаление объекта из базы данных, используя механизм транзакций для гарантирования целостности данных даже в случае возникновения ошибки.





    







