## Интеграция с ЕАИС (Единая автоматизированная информационная система)

### Оглавление

### 1. Введение

Единая автоматизированная информационная система (ЕАИС) - автоматизированный учет и контроль перемещаемых товаров и транспортных средств, а также декларирование товаров и транспортных средств, их таможенное оформление.
Мы хотим интегрировать проект "Навигационная пломба ГТС" с системой ЕАИС, чтобы на основе номера транзитной декларации получать актуальные данные о каждом грузе.

### 2. Предварительные условия

Первым делом, мы должны получить от ЕАИС все нужные нам ссылки:
1. WSDL - http://212.112.104.124:8122/TDService?wsdl
2. XSD - http://212.112.104.124:8122/TDService?xsd=xsd0

Со стороны проекта "Навигационная пломба ГТС" технические условия:
1. JDK 8 - 11
2. База данных: PostgreSQL, MySQL
3. Axelor v7.0.0 и выше

### 3. Интеграция с ЕАИС - Генерация структуры и классов

1. С помощью WSDl ссылки мы должны сгенерировать все нужные интерфейсы, сервисы и классы,
2. Мы должны у себя в проекте указать нужный путь, куда мы должы сгенерировать классы, например:
```
C:\Users\...\IdeaProjects\Plomba\GovERP-master\modules\NavigationPlomb-AOS\electronic-navigation-seals\src\main\java\com\axelor\apps\ens\integrations\eais
```
3. Если у вас JDK 8 в терминале вводим команду
```
wsimport -Xnocompile http://212.112.104.124:8122/TDService?wsdl
```
### 3. Интеграция с ЕАИС - Создания класса сервиса

1. После генерации классов, у себя  в проекте создаем специальный класс сервис - EAIService
```java
public interface EAIService {

    Declaration getById(String id);
}
```
2. Имплементация сервиса EAIServiceImpl
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
#1 - Этот вызов создает новый экземпляр класса TDService, `.getBasicHttpBindingITDService()` - вызывая этот метод у объекта TDService, вы получаете прокси, который позволяет вашему приложению вызывать методы удаленного веб-сервиса как будто это локальные методы.

#2 - Данная строка кода создает экземпляр класса ObjectFactory.

#3 - Эта строка кода создаёт экземпляр объекта TDInfoRequest с использованием метода createTDInfoRequest() объекта factory, который является экземпляром класса ObjectFactory.

#4 - Эта строка кода устанавливает значение id для объекта request типа TDInfoRequest.

#5 - Эта строка кода выполняет запрос к веб-сервису и получает ответ.

**Обращение к веб-сервису:**
  Вызывается метод requestTD(request) на объекте itdService (который представляет собой прокси для взаимодействия с веб-сервисом). Вы передаете request (объект типа TDInfoRequest с установленным идентификатором) в           качестве аргумента для этого метода.
      
**Получение ответа:**
  Веб-сервис обрабатывает ваш запрос, вероятно, выполняя некоторые операции на стороне сервера, такие как поиск в базе данных. После завершения этих операций веб-сервис возвращает ответ, который, в вашем случае, имеет       тип TransitDeclarationResponse.
      
**Сохранение ответа:**
  Полученный ответ сохраняется в переменной transitDeclarationResponse.

#6 - Эта строка кода создаёт экземпляр или получает существующий экземпляр класса DeclarationMapper из контейнера зависимостей или сервиса управления бинами (beans).

#7 - Эта строка кода преобразует (или "маппит") объект transitDeclarationResponse с помощью объекта declarationMapper и возвращает результат этого преобразования.

### 4. Интеграция с ЕАИС - Создания маппера

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
Этот код представляет собой метод from, который преобразует объект типа Good в объект типа Product. 

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
Этот код представляет собой метод from, который преобразует переданные параметры (строки) в объект типа TransportationVehicle. 

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
Данный метод from преобразует объект TransitDeclarationResponse в объект типа Declaration. Этот код иллюстрирует типичное преобразование (или "маппинг") данных из одного представления (ответ от какого-то сервиса или системы) в другое (доменный объект вашего приложения).

### 5. Интеграция с ЕАИС - Создания контроллера

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
Этот код представляет собой метод setDeclarationFromOtherSystem, который предназначен для выполнения действия на основе входящего запроса (ActionRequest). 
Основная цель метода — получить декларацию из другой системы на основе предоставленного номера регистрации (registrationNumberTd) и установить её в ответ (ActionResponse).

### 6. Интеграция с ЕАИС - Обновление существующей декларации

1. Создается метод **updateDeclaration** внутри **DeclarationController**
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
Данный метод updateDeclaration предназначен для обновления декларации в контексте транспортной поездки (TransportationTrip).

1. Получение объекта **TransportationTrip** из запроса: Из **request** извлекается объект **TransportationTrip**.
2. С помощью сервиса **eaiService** метод пытается получить новую декларацию на основе регистрационного номера существующей декларации.
3. С помощью **transportationTripService** обновляется декларация в контексте транспортной поездки.
4. Если в процессе выполнения метода происходит исключение, оно перехватывается и устанавливается в ответ.

### 6. Интеграция с ЕАИС - Обновление существующей декларации - Серис для сранение новой декларации со старой

Метод **dataCheckingProducts:**
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
Метод **dataCheckingProducts** принимает две декларации - старую (oldDeclaration) и новую (newDeclaration). Его цель - проверить и обновить список продуктов в старой декларации, согласно списку продуктов в новой декларации.

1. Инициализация:

Списки продуктов из обеих деклараций загружаются в oldProducts и newProducts.
Создается список productsToRemove для продуктов, которые необходимо удалить из старой декларации.

2. Сравнение продуктов:

Для каждого продукта из oldProducts метод пытается найти соответствующий продукт в newProducts на основе hSCode.
Если соответствующий продукт не найден в newProducts, он добавляется в список productsToRemove.
Если найден - продукт из oldProducts обновляется данными из newProducts, если они различаются. Если были изменения, продукт сохраняется в базе данных с помощью crudService.

3. Удаление продуктов:

Проходя по productsToRemove, метод удаляет каждый продукт из базы данных и из oldProducts.












