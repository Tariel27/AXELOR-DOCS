, представленный `<action-script>`в версии 5, можно использовать для создания сложных действий с использованием языков сценариев.

    <action-script
      name="create.invoice" (1)
      model="com.axelor.sale.db.Order" (2)
      >
      <script
        language="js" (3)
        transactional="true" (4)
        >
      <![CDATA[
      var req = $request; (5)
      var res = $response; (6)
      var so = req.context;
      var invoice = new Invoice();
      invoice.date = so.confirmDate;
      // prepare invoice lines from sale order
      //TODO: invoice.invoiceLines = listOf(...);
    
      // if you want to save invoice
      //invoice.saleOrder = em.find(Order.class, so.id);
      //return $em.persist(invoice);
    
      res.setValue('invoice', invoice);
      res.setReadonly('customer', true);
      // and so on...
      ]]>
      </script>
    </action-script>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

название действия (обязательно)

**2**

имя контекстной модели

**3**

используемый язык сценариев (обязательно, в настоящее время `js`и `groovy`только)

**4**

является ли код транзакционным

**5**

доступен `ActionRequest`как`$request`

**6**

доступен `ActionResponse`как`$response`

Это `action-script`не что иное, как метод [контроллера](../modules/coding.html#controllers) , динамически созданный с использованием языка сценариев. Переменные `$request`и `$response`— это не что иное, как параметры `ActionRequest`и `ActionResponse`метода контроллера.

Следующие переменные доступны в контексте выполнения скрипта:



Имя

Описание

`$request`

тот`ActionRequest`

`$response`

тот`ActionReponse`

`$em`

`EntityManager`сценарий if`transactional`

`$json`

экземпляр для `MetaJsonRecordRepository`работы с [пользовательскими моделями](../models/custom-models.html)

Их `action-script`можно использовать и для нестандартных моделей. Вот пример:

    <action-script name="create.hello" model="com.axelor.meta.db.MetaJsonRecord">
      <script language="js" transactional="true">
      <![CDATA[
        var hello = $json.create('hello'); (1)
        hello.name = "Hello!!!";           (2)
    
        var world = $json.all('world').by('name', '=', 'World!!!').fetchOne(); (3)
        if (world == null) {
            world = $json.create('world');
            world.name = "World!!!";
            world = $json.save(world); (4)
            // now we can't update world, as it's converted to real instance
        }
    
        hello.world = world;  (5)
    
        // return as response values
        $response.values = hello;
    
      ]]>
      </script>
    </action-script>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

создать новый пустой контекст `MetaJsonRecord`для `hello`модели

**2**

контекст обеспечивает беспрепятственный доступ к значениям настраиваемых полей

**3**

найти `world`запись модели по полю`name`

**4**

записи, предназначенные для значений реляционных полей, необходимо сохранять вручную.

**5**

установить относительное значение (m2o)