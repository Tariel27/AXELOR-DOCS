В виде диаграммы данные отображаются в виде 2D-графиков и поддерживаются [NVD3](https://nvd3-community.github.io/nvd3/) .

    <chart name="chart.sales.per.month" title="Sales per month"> (1)
      <search-fields> (2)
         <field type="datetime" name="fromDateTime" title="From Date"/>
         <field type="datetime" name="toDateTime" title="To Date"/>
      </search-fields>
      <dataset type="jpql"> (3)
      <![CDATA[
      SELECT
          SUM(self.totalAmount) AS amount,
          MONTH(self.orderDate) AS month,
          _customer.fullName AS customer
      FROM
          Order self
      LEFT JOIN
          self.customer AS _customer
      WHERE
          YEAR(self.orderDate) = YEAR(current_date)
          AND self.orderDate > :fromDateTime
          AND self.orderDate < :toDateTime
      GROUP BY
          _customer,
          MONTH(self.orderDate)
      ORDER BY
          month
      ]]>
      </dataset>
      <category key="month" type="month"/> (4)
      <series key="amount" groupBy="customer" type="bar"/> (5)
    </chart>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

определить представление диаграммы

**2**

определить поля поиска (входные значения можно использовать в качестве параметров запроса)

**3**

определить источник данных для диаграммы (jpql, sql или rpc)

**4**

определить ось категорий

**5**

определить серию для диаграммы

Представление диаграммы не привязано ни к какому объекту, но зависит от набора данных, полученного с помощью запросов JPQL/SQL, или заданного rpc (вызова метода).

Необязательный параметр `<search-fields>`можно использовать для определения полей ввода для предоставления значений параметров запроса или контекста для вызовов RPC.

[](#chart-types)Типы диаграмм
-----------------------------

Поддерживаются следующие типы диаграмм:

*   пирог

*   бар

*   Хбар

*   линия

*   область

*   пончик

*   радар

*   измерять

*   разбрасывать


Для представления диаграммы требуется следующая информация:

*   `name`\- уникальное имя диаграммы

*   `title`\- название диаграммы

*   `stacked`\- создавать ли составную диаграмму

*   `onInit`\- действие, которое будет вызвано во время инициализации графика

*   `<dataset>`\- Запрос выбора JPQL/SQL с псевдонимами выбора имени.

*   `<category>`\- определяет ось X диаграммы с помощью

    *   `key`\- поле набора данных, которое будет использоваться для категоризации данных (используется как точки данных по оси X)

    *   `type`\- Тип категории может быть числовым, датой, временем, месяцем, годом или текстом.

    *   `title`\- название категории отображается по оси X


*   `<series>`\- список серий данных определяет ось Y (на данный момент разрешена только одна серия)

    *   `key`\- поле набора данных, которое будет использоваться в качестве точек данных по оси Y.

    *   `groupBy`\- поле набора данных используется для группировки связанных данных.

    *   `title`\- название оси Y

    *   `type`\- тип графика (круговая диаграмма, гистограмма, гбар, линия, площадь)

    *   `side`\- Сторона оси Y (левая или правая)


*   `<config>`\- пользовательские данные конфигурации

    *   `name`\- название элемента конфигурации

    *   `value`\- значение конфигурации


*   `<actions>`\- добавить действия в меню графика


[](#config)Конфигурация
-----------------------

Диаграммы можно настроить с использованием определенных значений конфигурации. Эти конфигурации могут быть применимы не ко всем типам диаграмм.

Наиболее важные значения конфигурации:

*   `width`\- ширина графика

*   `height`\- высота графика

*   `xFormat`\- пользовательский формат оси X, например `MM-YYYY`или`DD/MM/YYYY`

*   `percent`\- используется с круговой диаграммой, отображает метки в процентах

*   `colors`\- укажите базовые цвета для диаграмм, каждый цвет используется для создания 4 оттенков градиента

*   `shades`\- количество оттенков градиента, используемых для цветов

*   `hideLegend`\- показать/скрыть легенду

*   `min/max`\- используется с манометрической диаграммой, определяет минимальное и максимальное значения.

*   `onClick`\- вызвать указанное действие с выбранными данными в контексте


Пожалуйста, ознакомьтесь с [документацией NVD3](https://nvd3-community.github.io/nvd3/) для получения дополнительных конфигураций.

[](#colors)Цвета
----------------

Цвета можно указать с помощью значения конфигурации цветов (через запятую). Каждый цвет используется для создания 4 градиентных оттенков + 20 оттенков из пресета категории 20b d3.

    <chart ...>
      ...
      ...
      <!-- html named colors -->
      <config name="colors" value="red,green" />
    
      <!-- or html hex colors -->
      <config name="colors" value="#31a354,#e6550d" />
    
      <!-- with custom shades -->
      <config name="shades" value="10" />
    
    </chart>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

[](#actions)Действия
--------------------

Добавление действий в меню диаграммы (значок шестеренки в правом верхнем углу) поддерживается с использованием следующего синтаксиса:

    <chart ...>
      ...
      <actions>
        <action name="myBtn1" title="Act1" action="com.axelor.Hello:myAction1"/>
        <action name="myBtn2" title="Act2" action="some-action2"/>
      </actions>
    </chart>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

где :

*   `name`: Название действия

*   `title`: Название кнопки, отображаемой в меню графика.

*   `action`: Действие для выполнения.


`<actions>`должен быть хотя бы один `<action>`. Действие получит текущее имя диаграммы и данные в контексте. Пример :

    {
      "_chart": "chart.sales.per.month.pie",              (1)
      "_data": [{...}, ...],                              (2)
      "_domainAction": "chart:chart.sales.per.month.pie", (3)
      "_parent": {...},                                   (4)
      "fromDate": "2022-04-20",                           (5)
      "_signal": "myBtn1"                                 (6)
    }

JSON![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

: Название диаграммы

**2**

: Набор данных диаграммы

**3**

: Действие Dashlet

**4**

: Родительский контекст

**5**

: данные полей, определенные в`<search-fields>`

**6**

: сигнал действия (т. е. имя)