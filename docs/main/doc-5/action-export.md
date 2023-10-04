Может `<action-export>`использоваться для экспорта записей.

    <action-export name="export.sale.order" output="${name}/${date}${time}">
      <export name="${name}.xml"
        template="data/ws-test/export-sale-order.tmpl"
        engine="groovy"/>
      <export name="${name}-customer-copy.xml"
        template="data/ws-test/export-sale-order.tmpl"
        engine="groovy"/>
    </action-export>


Таблица 1. Атрибуты

Имя

Описание

**имя**

название действия

выход

переопределить путь вывода по умолчанию

скачать

загружать ли экспортированные файлы

Для действия экспорта требуется одна или несколько `<export>`задач:

*   `<export>`\- указать задачу экспорта

    *   `name`\- имя выходного файла

    *   `template`\- шаблон, который будет использоваться для создания выходного файла

    *   `engine`\- используемый шаблонизатор (groovy, ST)