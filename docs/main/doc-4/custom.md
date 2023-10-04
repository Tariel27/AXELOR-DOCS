[](#usage)Применение
--------------------

Пользовательский вид позволяет отображать произвольные данные с использованием шаблонов. Это представление обычно полезно для создания отчетов только для чтения.

Определение пользовательского представления:

    <custom name="view-name" title="View Title">
    
      <!-- dataset fields (optional) -->
      <field name="some" type="integer" />
      <field name="total" type="decimal" scale="4"/>
    
      <!-- dataset is required -->
      <dataset type="jpql|sql|rpc">
      <![CDATA[
      // jpql or sql or method call
      ]]>
      </dataset>
    
      <!-- template is require -->
      <template>
      <![CDATA[
      // angular.js template, data can be accessed using `data`, and first data item
      // is accessible as `first`.
      ]]>
      </template>
    </custom>



Пример использования с пользовательским шаблоном:

    <!-- Dashboard box with custom template -->
    <custom name="report.total.sale" title="Total sale" css="report-box">
      <dataset type="jpql">
      <![CDATA[
      select sum(self.totalAmount) as total from Order self
      ]]>
      </dataset>
      <template>
      <![CDATA[
      <div class="report-data">
        <h1>{{first.total}}</h1>
        <small>Total sale</small>
        <div class="report-percent font-bold text-info pull-right">20% <i class="fa fa-level-up"></i></div>
        <div class="report-tags"><span class="label label-important">Monthly</span></div>
      </div>
      ]]>
      </template>
    </custom>



Атрибуты:



Атрибут

Описание

**`name`**

название представления

**`title`**

отображать заголовок представления

Элементы:



Элемент

Описание

`<field>`

определения полей для набора данных (необязательно, их может быть несколько)

**`<dataset>`**

определение набора данных

**`<template>`**

шаблон [angular.js](https://docs.angularjs.org/guide/templates)

### [](#field)Поле

Этот `<field>`элемент можно использовать для предоставления метаданных об элементе набора данных. Это то же самое, что и поля в `grid`поле зрения.

### [](#dataset)Набор данных

Этот `<dataset>`элемент используется для определения набора данных.

*   `type`\- тип набора данных ( `jpql`, `sql`или `rpc`)

*   `limit`\- ограничение результата запроса (в случае `jpql`и `sql`)


### [](#template)Шаблон

Этот `<template>`элемент используется для определения [шаблона angular.js](https://docs.angularjs.org/guide/templates) для визуализации данных.

Результат набора данных доступен как `data`, а первый результат данных доступен как `first`.

[](#built-in-templates)Встроенные шаблоны
-----------------------------------------

Встроены два тега шаблона:

### [](#report-box)ящик для отчетов

Этот шаблон отображает данные в виде небольшого и простого окна отчета (полезно на информационной панели).

Статические атрибуты:

*   `icon`\- Имя значка [Font Awesome](http://fortawesome.github.io/Font-Awesome/icons)

*   `label`\- метка для описания значения


Динамические выражения:

*   `value`\- числовое значение в наборе данных

*   `percent`\- процентное значение в наборе данных (отформатированное с помощью `percent`фильтра)

*   `up`\- логическое выражение для значка вверх или вниз рядом со значением процента (или без значка, если оно равно нулю)

*   `tag`\- тег для отображения в области заголовка поля.

*   `tag-css`\- Класс CSS для применения к тегу


Пример использования:

    <!-- Sample custom view definition using report-box template -->
    <custom name="report-box-sales-month" title="Sales this month">
      <dataset type="rpc">com.axelor.sale.web.SaleOrderController:reportMonthly</dataset>
      <template>
      <![CDATA[
      <report-box icon='fa-search' label='Total sales' value='first.total'
        percent='first.percent' up='first.up' tag='first.tag' tag-css='first.tagCss'/>
      ]]>
      </template>
    </custom>



    public class SaleOrderController {
    
      public void reportMonthly(ActionRequest request, ActionResponse response) {
        // ...
    
        Map<String, Object> data = new HashMap<>();
        data.put("total", total);
        data.put("percent", percent);
        data.put("up", total.compareTo(last) > 0);
        data.put("tag", I18n.get("Monthly"));
        data.put("tagCss", "label-success");
    
        // This data will be put into dataset.
        // For report-box, we send a list with a single item accessible as `first`.
        response.setData(List.of(data));
      }
    }



![Образец окна отчета](../_images/custom-view-report-box.png)

Рисунок 1. Пример окна отчета

### [](#report-table)таблица отчета

Этот шаблон отображает набор данных в виде таблицы. Он использует метаданные полей для форматирования и может использовать любые виджеты, поддерживаемые при `grid`просмотре. Он также поддерживает сортировку по столбцам.

Статические атрибуты:

*   `columns`\- список полей набора данных, разделенных запятыми, как столбцы таблицы (если не указано, используются ключи из элементов набора данных)

*   `sums`\- список полей набора данных, разделенных запятыми, для отображения сумм


Пример использования:

    <!-- Sample custom view definition using report-table template -->
    <custom name="report-table-order-lines" title="Order lines">
      <field name="name" title="Order name"/>
      <field name="statusSelect" title="Status" type="integer"
        selection="selection-order-status" widget="single-select"/>
      <field name="productName" title="Product" type="string" x-translatable="true"/>
      <field name="total" type="decimal" x-scale="2"/>
      <dataset type="jpql" limit="40">
      <![CDATA[
      SELECT self.name AS name, self.statusSelect AS statusSelect,
        item.product.name as productName, item.quantity * item.price AS total
      FROM Order self
      JOIN self.items item
      ORDER BY self.name
      ]]>
      </dataset>
      <template>
      <![CDATA[
      <report-table sums='total'/>
      ]]>
      </template>
    </custom>



![Пример таблицы отчета](../_images/custom-view-report-table.png)

Рисунок 2. Пример таблицы отчета