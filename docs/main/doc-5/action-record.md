Может `<action-record>`использоваться для создания объекта с некоторыми значениями.

    <action-record name="default-order-record" model="com.axelor.sale.db.Order">
      <field name="customer" expr="action:default-customer-record" if="!(__ref__ instanceof Contact)"/>
      <field name="customer" expr="eval: __ref__" if="__ref__ instanceof Contact"/>
      <field name="orderDate" expr="eval: __date__"/>
      <field name="createDate" expr="eval: __date__"/>
      <field name="items" expr="action:default-orderline-record"/>
    </action-record>



Таблица 1. Атрибуты

Имя

Описание

**имя**

название действия

**модель**

модель предметной области для построения объекта

поиск

искать существующую запись перед созданием новой

ссылка

ссылка на существующую запись из контекста имеет преимущество перед`search`

копировать

если запись найдена, создавать ли ее копию

сохранитьЕсли

сохраните, если данное выражение истинно и `id`указано `null`или `version`указано значение.

Для действия требовались `<field>`элементы для установки свойств объекта.

*   `<field>`\- определить поле для обновления

    *   `name`\- название поля

    *   `expr`\- выражение, которое нужно выполнить, чтобы получить значение

    *   `if`\- отличное логическое выражение для текущего контекста

    *   `copy`\- если выражение возвращает объект модели, копировать ли его



Имеет `expr`следующий формат:

*   `eval: …​`\- оценить как заводное выражение

*   `call: …​`\- вызвать данный метод контроллера

*   `action: …​`\- вызвать заданное действие

*   `select: …​`\- выполнить запрос выбора и вернуть первую совпавшую запись

*   `select[]: …​`\- выполнить запрос выбора и вернуть все совпадающие записи

*   `…​`\- если ничего из вышеперечисленного, считать выражение статическим значением