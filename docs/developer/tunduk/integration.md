# Интеграция с _Тундук_

## Оглавление

1. [Введение](#1-введение)
2. [Предварительные условия](#2-предварительные-условия)
3. [Установка](#3-установка)
4. [Использование](#4-использование)
5. [Структура кода](#5-структура-кода)
6. [Функции/методы](#6-функцииметоды)
7. [Занятия](#7-классы)
8. [Конфигурация](#8-конфигурация)
9. [Примеры](#9-примеры)

## 1. Введение

Интеграция нужна для получения данных из разных (**доступных**) сервисов.

## 2. Предварительные условия

- Сервисы **тундука**
    - Их будет много.
    - Принимаемый\Возвращаемый **типы данных** не идентичны.
    - Параметры для настройки, есть одинаковые и разные.
- Следовать принципам ООП

## 3. Установка

1. Axelor v7.0.0
2. JDK 11

## 4. Использование

> Прежде чем вы начнете читать это часть советую посмотреть ["Структура кода"](#5-структура-кода)

### Сервис низкого уровня

Для каждого _тундукского_ сервиса создаём по (сервис) классу.
Они будут получать данные напрямую из [веб-сервисов][^1] и парсить их в нужный нам тип.

При создании такого сервиса, нужно следовать таким простым правилам.

- Кол-во методов внутри сервиса, зависит от **business** логики.
- Их возвращаемы и принимаемые типы должны быть схож с методами [веб-сервисов][^1]
- Для каждого создается класс _маппер_ для конвертации данных.

```java
public class TestService extends TunducService {

    private final WebServiceClassMapper mapper;
    private WebService webService;

    // Получения одной записи
    public AxelorClass findById(WebServiceRequest request) {
        WebServiceResponse response = webService.findById(request);
        return mapper.parse(response.getObject());
    }

    // Получения два и больше записи
    public AxelorClass[] findByIds(WebServiceRequest request) {
        WebServiceResponse response = webService.findByIds(request);
        return mapper.parse(response.getObjects());
    }
}
```

### _Мапперы_

Классы, которые будут парсит данные.
Нужно переопределить метод `parse` из базового, и в нём реализовать код.

```java
public class MinJustMapper extends BaseMapper<Subject, Partner> {

    @Inject
    private PartnerCategoryRepository partnerCategoryRepository;
    @Inject
    private RegionRepository regionRepository;
    @Inject
    private DistrictRepository districtRepository;
    @Inject
    private CityRepository cityRepository;

    @Override
    public Partner parse(Subject subject) {
        if (subject == null) {
            responseIsNull();
            return null;
        }

        customMessage(String.format("Parsing subject %s to partner!", subject.getTin()));
        Partner partner = new Partner();
        partner.setName(subject.getFullNameGl());
        partner.setRepresentativesName(subject.getChief());
        partner.setNameOfCompanyGov(subject.getFullNameGl());
        partner.setNameOfCompanyOfficial(subject.getFullNameOl());
        //....some-code
        return partner;
    }
}
```

### _Хендлер_
Он отвечает за обработку **SOAP** сообщения. Нужен он, для того чтобы добавить нужные нам заголовки в запрос.

```java
public class MinJustHandler extends BaseHandler {

  public MinJustHandler(Header header) {
    super(header);
  }

  @Override
  public boolean handleMessage(SOAPMessageContext context) {
    boolean handled = super.handleMessage(context);

    try {
      SOAPMessage message = context.getMessage();
      SOAPEnvelope envelope = message.getSOAPPart().getEnvelope();
      SOAPHeader header = envelope.getHeader();
      header.addChildElement("test", PREFIX_XRO).addTextNode("test"); //<xro:test>test</test>
    } catch (SOAPException e) {
      throw new RuntimeException(e);
    }

    return handled;
  }
}
```

### Провайдер
Объект, способный предоставлять экземпляры T  
Плюс, в нём же мы настраиваем параметры сервиса. 

```java
public class MinJustProvider extends BaseTundukProvider<MinJustService> {

    private final static String wsdlPath = "integration.tunduk.<service-name>";

    @Override
    public MinJustService get() {
        return new MinJustService(getHandler(), getWsdlUrl(wsdlPath));
    }

    @Override
    protected Header getHeader() {
        Map<String, String> parameters = new HashMap<>();
        parameters.put("id", UUID.randomUUID().toString());
        parameters.put("userId", "<test>");
        parameters.put("protocolVersion", "<test>");
        return new Header(
                parameters,
                getService(),
                getClient());
    }

    @Override
    protected Service getService() {
        return new Service(
                XRoadObjectType.SERVICE.value(),
                "<xRoadInstance>",
                "<memberClass>",
                "<memberCode>",
                "<subsystemCode>");
    }

    @Override
    protected BaseHandler getHandler() {
        return new MinJustHandler(getHeader()); // select need handler
    }

}
```


## 5. Структура кода

```text
├───provider
├───module
├───integrations
│   ├───tunduk
│   │   ├───exception
│   │   ├───handler
│   │   ├───helper
│   │   ├───mapper
│   │   ├───service
│   │   └───web_service
│   │       ├───dto
├───service
    └───tunduk
        └───impl
```

### Базовые классы
#### Сервис
```java
public abstract class TundukService {

    protected final URL wsldUrl;
    protected final BaseHandler handler;


    public TundukService(BaseHandler handler, URL wsldUrl) {
        this.handler = handler;
        this.wsldUrl = wsldUrl;
        setHandler();
    }

    protected void setServiceCode(String serviceCode, String version) {
        getHandler().setServiceCode(serviceCode);
        getHandler().setServiceVersion(version);
    }

    public BaseHandler getHandler() {
        return handler;
    }

    public URL getWsldUrl() {
        return wsldUrl;
    }

    protected abstract void setHandler();

    @Override
    public String toString() {
        return "TundukService{" +
                "handler=" + handler +
                '}';
    }
}
```
#### Маппер
```java
public abstract class BaseMapper<T, R> {

    private final static Logger LOGGER = LoggerFactory.getLogger(BaseMapper.class);

    public abstract R parse(T t);

    public List<R> parse(List<T> t) {
        if (Objects.isNull(t)) {
            responseIsNull();
            return Collections.emptyList();
        }
        return t.stream()
                .map(this::parse)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    protected void responseIsNull() {
        LOGGER.warn("{}:Response is null!", this.getClass().getName());
    }

    protected void customMessage(String message) {
        LOGGER.debug("{}:{}", this.getClass().getName(), message);
    }

    protected void successMessage() {
        LOGGER.debug("{}:Success parsed!", this.getClass().getName());
    }

    protected void errorMessage(Exception exception) {
        LOGGER.error("{}:Failed to parse:", this.getClass().getName(), exception);
    }
}
```
#### Хендлер
```java
public class BaseHandler implements SOAPHandler<SOAPMessageContext> {

    protected final Header headerParams;

    private static final Logger LOGGER = LoggerFactory.getLogger(BaseHandler.class);

    protected static final String PREFIX_XRO = "xro";
    protected static final String PREFIX_TUN = "tun";
    protected static final String PREFIX_SOAPENV = "soapenv";
    protected static final String PREFIX_XMLNS = "xmlns";
    protected static final String PREFIX_IDEN = "iden";
    protected static final String PREFIX_OBJECT_TYPE = "objectType";

    protected static final String URL_XROADXSD = "http://x-road.eu/xsd/xroad.xsd";
    protected static final String URL_XMLSOAP = "http://schemas.xmlsoap.org/soap/envelope/";
    protected static final String URL_TUNDUK = "http://tunduk.gov.kg";
    protected static final String URL_IDENTIFIERS = "http://x-road.eu/xsd/identifiers";

    public BaseHandler(Header header) {
        this.headerParams = header;
    }

    @Override
    public Set<QName> getHeaders() {
        return null;
    }

    @Override
    public boolean handleMessage(SOAPMessageContext context) {
        SOAPMessage message = context.getMessage();

        if (!(Boolean) context.get(SOAPMessageContext.MESSAGE_OUTBOUND_PROPERTY)) {
            try {
                printXmlBody(message);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
            return true;
        }

        try {
            SOAPEnvelope envelope = message.getSOAPPart().getEnvelope();
            SOAPHeader header = envelope.getHeader();
            //set default attrs TODO if all services similar
            envelope.addAttribute(envelope.createName(concat(PREFIX_XMLNS, PREFIX_XRO)), URL_XROADXSD);
//            envelope.addAttribute(envelope.createName(concat(PREFIX_XMLNS, PREFIX_SOAPENV)), URL_XMLSOAP);
            envelope.addAttribute(envelope.createName(concat(PREFIX_XMLNS, PREFIX_IDEN)), URL_IDENTIFIERS);
//            envelope.addAttribute(envelope.createName(concat(PREFIX_XMLNS, PREFIX_TUN)), URL_TUNDUK);
            //TODO if all services similar
            setService(header, envelope, headerParams.getService());
            setClient(header, envelope, headerParams.getClient());

            for (Map.Entry<String, String> param : headerParams.getParameters().entrySet()) {
                if (Objects.isNull(param.getKey()) || Objects.isNull(param.getValue())) continue;

                header.addChildElement(param.getKey(), PREFIX_XRO).addTextNode(param.getValue());
            }

            message.saveChanges();
            LOGGER.debug("set {} headers", this.getClass().getSimpleName());
            printXmlBody(message);
        } catch (SOAPException | IOException e) {
            throw new RuntimeException(e);
        }
        return true;
    }

    private void printXmlBody(SOAPMessage message) throws SOAPException, IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        message.writeTo(out);
        String strMsg = out.toString();
        LOGGER.debug("{} xml Body: {}", this.getClass().getSimpleName(), strMsg);
    }

    private void setService(SOAPHeader header, SOAPEnvelope envelope, Service service) throws SOAPException {
        if (service == null) {
            throw new RuntimeException("Service is null!");
        }

        SOAPElement serviceElement = header.addChildElement("service", PREFIX_XRO);
        serviceElement.addAttribute(envelope.createName(concat(PREFIX_IDEN, PREFIX_OBJECT_TYPE)), service.getObjectType());

        serviceElement.addChildElement("xRoadInstance", PREFIX_IDEN).addTextNode(service.getxRoadInstance());
        serviceElement.addChildElement("memberClass", PREFIX_IDEN).addTextNode(service.getMemberClass());
        serviceElement.addChildElement("memberCode", PREFIX_IDEN).addTextNode(service.getMemberCode());
        if (service.getSubsystemCode() != null) {
            serviceElement.addChildElement("subsystemCode", PREFIX_IDEN).addTextNode(service.getSubsystemCode());
        }
        serviceElement.addChildElement("serviceCode", PREFIX_IDEN).addTextNode(service.getServiceCode());
        if (service.getServiceVersion() != null) {
            serviceElement.addChildElement("serviceVersion", PREFIX_IDEN).addTextNode(service.getServiceVersion());
        }

    }

    private void setClient(SOAPHeader header, SOAPEnvelope envelope, Client client) throws SOAPException {
        if (client == null) {
            throw new RuntimeException("Client is null!");
        }
        SOAPElement childElement = header.addChildElement("client", PREFIX_XRO);
        childElement.addAttribute(envelope.createName(concat(PREFIX_IDEN, PREFIX_OBJECT_TYPE)), client.getObjectType());

        childElement.addChildElement("xRoadInstance", PREFIX_IDEN).addTextNode(client.getxRoadInstance());
        childElement.addChildElement("memberClass", PREFIX_IDEN).addTextNode(client.getMemberClass());
        childElement.addChildElement("memberCode", PREFIX_IDEN).addTextNode(client.getMemberCode());
        if (client.getSubsystemCode() != null) {
            childElement.addChildElement("subsystemCode", PREFIX_IDEN).addTextNode(client.getSubsystemCode());
        }
    }

    protected String concat(String prefix1, String prefix2) {
        return String.format("%s:%s", prefix1, prefix2);
    }

    @Override
    public boolean handleFault(SOAPMessageContext context) {
        SOAPBody soapBody = null;
        try {
            soapBody = context.getMessage().getSOAPBody();
        } catch (SOAPException e) {
            throw new RuntimeException(e);
        }
        SOAPFault fault = soapBody.getFault();
        if (fault != null) throw new TundukException(fault.getFaultString());

        return true;
    }

    @Override
    public void close(MessageContext context) {

    }

    public void setServiceCode(String serviceCode) {
        headerParams.getService().setServiceCode(serviceCode);
    }

    public void setServiceVersion(String version) {
        headerParams.getService().setServiceVersion(version);
    }

    @Override
    public String toString() {
        return "BaseHandler{" +
                "headerParams=" + headerParams +
                '}';
    }
}
```
#### Провайдер
```java
public abstract class BaseTundukProvider<T> implements Provider<T> {
    
    private final static Logger LOGGER = LoggerFactory.getLogger(BaseTundukProvider.class);
    protected abstract Header getHeader();
    protected abstract Service getService();

    protected BaseHandler getHandler() {
        return new BaseHandler(getHeader());
    }

    protected Client getClient() {
        return new Client(
                XRoadObjectType.SUBSYSTEM.value(),
                "<xRoadInstance>",
                "<memberClass>",
                "<memberCode>",
                "<subsystemCode>");
    }

    protected final URL getWsdlUrl(String wsdlPath) {
        try {
            AppSettings settings = AppSettings.get();
            String spec = settings.get(wsdlPath);
            if (Objects.isNull(spec)) {
                String msg = String.format("Wsdl path for %s is null!", this.getClass().getName());
                LOGGER.warn(msg);
                throw new RuntimeException(msg);
            }
            return new URL(spec);
        } catch (MalformedURLException e) {
            LOGGER.error("{}:", this.getClass().getName(), e);
            throw new RuntimeException(e.getMessage());
        }
    }
}
```

## 6. Функции/методы

Здесь я перечислю только те методы которые вам необходимо знать.

- `TundukService`
  - `setServiceCode` - переопределить значения двух полей из DTO(Service)
  - `abstract setHandler` - устанавливает обработчик к веб-сервису.
- `BaseHandler`
  - `handleMessage` - метод который вызывается до и после отправки запроса.
  - `setService, setClient` - установка параметр в заголовок запроса.
- `BaseMapper`
  - `parse` - конвертация из одного объекта в другой.
  - `responseIsNull, customMessage, successMessage, errorMessage` - для логов.
- `BaseTundukProvider`
  - `getHeader` - возвращает экземпляр DTO-заголовка
  - `getService` - возвращает экземпляр DTO-сервиса с указанными параметрами.
  - `getClient` - возвращает экземпляр DTO-клиента с указанными параметрами.
  - `getHandler` - возвращает экземпляр _Хендлер_ с указанными параметрами.
  - `getWsdlUrl` - возвращает экземпляр **URL** до WSDL.
## 7. Классы

```text
├───integrations
│   │
│   ├───tunduk
│   │   ├───exception
│   │   │       TundukException.java
│   │   │
│   │   ├───handler
│   │   │       BaseHandler.java
│   │   │       MinJustHandler.java
│   │   │       PassportHandler.java
│   │   │       VehicleHandler.java
│   │   │       ZagsHandler.java
│   │   │
│   │   ├───helper
│   │   │       DateHelper.java
│   │   │
│   │   ├───mapper
│   │   │   │   BaseMapper.java
│   │   │   │
│   │   │   ├───minjust
│   │   │   │       MinJustMapper.java
│   │   │   │
│   │   │   ├───passport
│   │   │   │       PassportDataByPSNMapper.java
│   │   │   │       PassportMapper.java
│   │   │   │
│   │   │   ├───vehicle
│   │   │   │       VehicleCarCheckByGovPlateResponseMapper.java
│   │   │   │       VehicleMapper.java
│   │   │   │
│   │   │   └───zags
│   │   │           ZagsMapper.java
│   │   │
│   │   ├───service
│   │   │   │   TundukService.java
│   │   │   │
│   │   │   ├───minjust
│   │   │   │       MinJustService.java
│   │   │   │
│   │   │   ├───passport
│   │   │   │       PassportService.java
│   │   │   │
│   │   │   ├───vehicle
│   │   │   │       VehicleService.java
│   │   │   │
│   │   │   └───zags
│   │   │           ZagsService.java
│   │   │
│   │   └───web_service
│   │       ├───dto
│   │       │       Client.java
│   │       │       Header.java
│   │       │       Service.java
│   │       │
│   │       ├───minjust
│   │       │   └───kg
│   │       │       └───gov
│   │       │           └───tunduk
│   │       │                   Founder.java
│   │       │                   GetSubjectByNameRequest.java
│   │       │                   GetSubjectByNameResponse.java
│   │       │                   GetSubjectByQueryRequest.java
│   │       │                   GetSubjectByQueryResponse.java
│   │       │                   GetSubjectByTinRequest.java
│   │       │                   GetSubjectByTinResponse.java
│   │       │                   ObjectFactory.java
│   │       │                   package-info.java
│   │       │                   QueryType.java
│   │       │                   Subject.java
│   │       │                   SubjectPort.java
│   │       │                   SubjectPortService.java
│   │       │
│   │       ├───passport
│   │       │       BankPinService.java
│   │       │       BankPinServiceResponse.java
│   │       │       InfocomService.java
│   │       │       InfocomServicePortType.java
│   │       │       LostPassportsByMonth.java
│   │       │       LostPassportsByMonthResponse.java
│   │       │       Notes.java
│   │       │       ObjectFactory.java
│   │       │       package-info.java
│   │       │       PassportDataByPin.java
│   │       │       PassportDataByPinResponse.java
│   │       │       PassportDataByPSN.java
│   │       │       PassportDataByPSNResponse.java
│   │       │       PassportDataForInfosystema.java
│   │       │       PassportDataForInfosystemaResponse.java
│   │       │       PassportLastPhotoByPin.java
│   │       │       PassportLastPhotoByPinResponse.java
│   │       │       PassportSearchByNSPDate.java
│   │       │       PassportSearchByNSPDateResponse.java
│   │       │       PassportStatus.java
│   │       │       PassportStatusResponse.java
│   │       │       RequestHash.java
│   │       │       StatusByPassportData.java
│   │       │       StatusByPassportDataResponse.java
│   │       │       TechNotes.java
│   │       │       TestBankPinService.java
│   │       │       TestBankPinServiceResponse.java
│   │       │       TestPassportDataByPSN.java
│   │       │       TestPassportDataByPSNResponse.java
│   │       │       Title.java
│   │       │       XRoadCentralServiceIdentifierType.java
│   │       │       XRoadClientIdentifierType.java
│   │       │       XRoadGlobalGroupIdentifierType.java
│   │       │       XRoadIdentifierType.java
│   │       │       XRoadLocalGroupIdentifierType.java
│   │       │       XRoadObjectType.java
│   │       │       XRoadSecurityCategoryIdentifierType.java
│   │       │       XRoadSecurityServerIdentifierType.java
│   │       │       XRoadServiceIdentifierType.java
│   │       │
│   │       ├───vehicle
│   │       │       Arests.java
│   │       │       CarCheckByGovPlate.java
│   │       │       CarCheckByGovPlateResponse.java
│   │       │       CarCheckFree.java
│   │       │       CarCheckFreeResponse.java
│   │       │       CarCheckGeneratePayment.java
│   │       │       CarCheckGeneratePaymentResponse.java
│   │       │       CarCheckGeneratePaymentTest.java
│   │       │       CarCheckGeneratePaymentTestResponse.java
│   │       │       CarCheckPaid.java
│   │       │       CarCheckPaidResponse.java
│   │       │       CarCheckPaidTest.java
│   │       │       CarCheckPaidTestResponse.java
│   │       │       Cars.java
│   │       │       CertificateStatus.java
│   │       │       CertificateStatusResponse.java
│   │       │       Data.java
│   │       │       InfocomService.java
│   │       │       InfocomServicePortType.java
│   │       │       Notes.java
│   │       │       ObjectFactory.java
│   │       │       package-info.java
│   │       │       RecordsByDate.java
│   │       │       RecordsByDateResponse.java
│   │       │       RequestHash.java
│   │       │       TechNotes.java
│   │       │       TestTransportByPin.java
│   │       │       TestTransportByPinResponse.java
│   │       │       Title.java
│   │       │       Transport.java
│   │       │       TransportArestByGovPlate.java
│   │       │       TransportArestByGovPlateResponse.java
│   │       │       TransportByPin.java
│   │       │       TransportByPinResponse.java
│   │       │       TransportCarInfoWithHistory.java
│   │       │       TransportCarInfoWithHistoryResponse.java
│   │       │       TransportCurrentArestInfo.java
│   │       │       TransportCurrentArestInfoResponse.java
│   │       │       TransportCurrentInfo.java
│   │       │       TransportCurrentInfoResponse.java
│   │       │       TransportDataByVin.java
│   │       │       TransportDataByVinBrandPeriod.java
│   │       │       TransportDataByVinBrandPeriodResponse.java
│   │       │       TransportDataByVinResponse.java
│   │       │       TransportOwnersPeriod.java
│   │       │       TransportOwnersPeriodResponse.java
│   │       │       TransportReferenceBrand.java
│   │       │       TransportReferenceBrandResponse.java
│   │       │       TransportReferenceColor.java
│   │       │       TransportReferenceColorResponse.java
│   │       │       TransportReferenceModel.java
│   │       │       TransportReferenceModelResponse.java
│   │       │       TransportSearchByFullname.java
│   │       │       TransportSearchByFullnameResponse.java
│   │       │       TransportSearchByParameters.java
│   │       │       TransportSearchByParametersResponse.java
│   │       │       TransportStatement.java
│   │       │       TransportStatementResponse.java
│   │       │       TransportStatusByGovPlate.java
│   │       │       TransportStatusByGovPlateResponse.java
│   │       │       TransportVinByGovPlate.java
│   │       │       TransportVinByGovPlateResponse.java
│   │       │       TsMonitoringGeneralStatistics.java
│   │       │       TsMonitoringGeneralStatisticsResponse.java
│   │       │       TsMonitoringRegionStatistics.java
│   │       │       TsMonitoringRegionStatisticsResponse.java
│   │       │       XRoadCentralServiceIdentifierType.java
│   │       │       XRoadClientIdentifierType.java
│   │       │       XRoadGlobalGroupIdentifierType.java
│   │       │       XRoadIdentifierType.java
│   │       │       XRoadLocalGroupIdentifierType.java
│   │       │       XRoadObjectType.java
│   │       │       XRoadSecurityCategoryIdentifierType.java
│   │       │       XRoadSecurityServerIdentifierType.java
│   │       │       XRoadServiceIdentifierType.java
│   │       │
│   │       └───zags
│   │           ├───eu
│   │           │   └───x_road
│   │           │       └───xsd
│   │           │           ├───identifiers
│   │           │           │       ObjectFactory.java
│   │           │           │       package-info.java
│   │           │           │       XRoadCentralServiceIdentifierType.java
│   │           │           │       XRoadClientIdentifierType.java
│   │           │           │       XRoadGlobalGroupIdentifierType.java
│   │           │           │       XRoadIdentifierType.java
│   │           │           │       XRoadLocalGroupIdentifierType.java
│   │           │           │       XRoadObjectType.java
│   │           │           │       XRoadSecurityCategoryIdentifierType.java
│   │           │           │       XRoadSecurityServerIdentifierType.java
│   │           │           │       XRoadServiceIdentifierType.java
│   │           │           │
│   │           │           └───xroad
│   │           │                   Notes.java
│   │           │                   ObjectFactory.java
│   │           │                   package-info.java
│   │           │                   RequestHash.java
│   │           │                   TechNotes.java
│   │           │                   Title.java
│   │           │
│   │           └───fi
│   │               └───x_road
│   │                   └───tunduk_seccurity_infocom
│   │                       └───producer
│   │                               Act.java
│   │                               CitizenshipCatalog.java
│   │                               CitizenshipCatalogResponse.java
│   │                               InfocomService.java
│   │                               InfocomServicePortType.java
│   │                               Item.java
│   │                               Items.java
│   │                               NationalityCatalog.java
│   │                               NationalityCatalogResponse.java
│   │                               ObjectFactory.java
│   │                               package-info.java
│   │                               TestPortalMarriageFormToZags.java
│   │                               TestPortalMarriageFormToZagsResponse.java
│   │                               TestZagsCatalog.java
│   │                               TestZagsCatalogResponse.java
│   │                               TestZagsDataByPin.java
│   │                               TestZagsDataByPinResponse.java
│   │                               TestZagsDivorceRecords.java
│   │                               TestZagsDivorceRecordsResponse.java
│   │                               TestZagsEduCatalog.java
│   │                               TestZagsEduCatalogResponse.java
│   │                               TestZagsMaritalStatus.java
│   │                               TestZagsMaritalStatusResponse.java
│   │                               TestZagsMarriageRecords.java
│   │                               TestZagsMarriageRecordsResponse.java
│   │                               ZagsBirthList.java
│   │                               ZagsBirthListResponse.java
│   │                               ZagsCatalog.java
│   │                               ZagsCatalogResponse.java
│   │                               ZagsChildren.java
│   │                               ZagsChildrenResponse.java
│   │                               ZagsDataByPin.java
│   │                               ZagsDataByPinExtended.java
│   │                               ZagsDataByPinExtendedResponse.java
│   │                               ZagsDataByPinResponse.java
│   │                               ZagsDeathActByPin.java
│   │                               ZagsDeathActByPinResponse.java
│   │                               ZagsDeathList.java
│   │                               ZagsDeathListResponse.java
│   │                               ZagsDivorceList.java
│   │                               ZagsDivorceListResponse.java
│   │                               ZagsFIOByPin.java
│   │                               ZagsFIOByPinResponse.java
│   │                               ZagsMaritalStatus.java
│   │                               ZagsMaritalStatusResponse.java
│   │                               ZagsMarriageList.java
│   │                               ZagsMarriageListResponse.java
│   │                               ZagsMonitoringRecordsCount.java
│   │                               ZagsMonitoringRecordsCountResponse.java
│   │                               ZagsMonitoringRecordsPeriod.java
│   │                               ZagsMonitoringRecordsPeriodResponse.java
│   │                               ZagsPinAdoptionAct.java
│   │                               ZagsPinAdoptionActResponse.java
│   │                               ZagsPinBirthAct.java
│   │                               ZagsPinBirthActResponse.java
│   │                               ZagsPinDeathAct.java
│   │                               ZagsPinDeathActResponse.java
│   │                               ZagsPinDivorceAct.java
│   │                               ZagsPinDivorceActResponse.java
│   │                               ZagsPinMarriageAct.java
│   │                               ZagsPinMarriageActResponse.java
│   │                               ZagsPinNameChangeAct.java
│   │                               ZagsPinNameChangeActResponse.java
│   │                               ZagsPinPaternityAct.java
│   │                               ZagsPinPaternityActResponse.java
│   │                               ZagsPinRequest.java
│   │                               ZagsPinRequestResponse.java
│   │                               ZagsPinsByNSPDate.java
│   │                               ZagsPinsByNSPDateResponse.java
│   │                               ZagsStatement.java
│   │                               ZagsStatementResponse.java
│   │
│   └───utils
│           GlobalVariable.java
│           IntegrationUtils.java
│
├───module
│       NotaryModule.java
├───provider
│       BaseTundukProvider.java
│       MinJustProvider.java
│       PassportProvider.java
│       VehicleProvider.java
│       ZagsProvider.java
├───service
│   │   CompanyService.java
│   │   DataApiService.java
│   │   FileConverterService.java
│   │   FileService.java
│   │   MailService.java
│   │   NotaryService.java
│   │   PartnerService.java
│   │   RatingCalculateService.java
│   │   RegistrationService.java
│   │   SaleOrderMailMessageService.java
│   │   SourceTrustService.java
│   │
│   ├───impl
│   │       NotaryServiceImpl.java
│   │       PartnerServiceImpl.java
│   │       SourceTrustServiceImpl.java
│   │
│   └───tunduk
│       │   IndividualInfoService.java
│       │   MinJustInfoService.java
│       │   PassportInfoService.java
│       │   TundukInfoService.java
│       │   UnaaServiceInfo.java
│       │   VehicleInfoService.java
│       │   ZagsInfoService.java
│       │
│       └───impl
│               IndividualInfoServiceImpl.java
│               MinJustInfoServiceImpl.java
│               PassportInfoServiceImpl.java
│               UnaaServiceInfoImpl.java
│               VehicleInfoServiceImpl.java
│               ZagsInfoServiceImpl.java
```

## 8. Конфигурация

В axelor-config.properties нужно добавить ссылки(Url или Путь до файла) до wsdl.
Например
```properties
integration.tunduk.minjust = file://<HOME>/wsdl/minjust.wsdl
integration.tunduk.zags = <URL>/minjust.wsdl
```

## 9. Примеры

Если у вас есть доступ к репозиторию.

- [Сервис низкого уровня](https://github.com/Tariel27/Notary-AOS/blob/dev/axelor-notary/src/main/java/com/axelor/notary/integrations/tunduk/service/minjust/MinJustService.java)
- [_Маппер_](https://github.com/Tariel27/Notary-AOS/blob/dev/axelor-notary/src/main/java/com/axelor/notary/integrations/tunduk/mapper/minjust/MinJustMapper.java)
- [_Хендлер_](https://github.com/Tariel27/Notary-AOS/blob/dev/axelor-notary/src/main/java/com/axelor/notary/integrations/tunduk/handler/MinJustHandler.java)
- [Провайдер](https://github.com/Tariel27/Notary-AOS/blob/dev/axelor-notary/src/main/java/com/axelor/notary/provider/MinJustProvider.java)
- [Сервис _Impl_](https://github.com/Tariel27/Notary-AOS/blob/dev/axelor-notary/src/main/java/com/axelor/notary/service/tunduk/impl/MinJustInfoServiceImpl.java)

[^1]: Классы, которые были сгенерированы из WSDL.