Его `<action-import>`можно использовать для импорта данных из потока данных XML.

    <action-import name="data.import.1" config="ws-data/xml-config.xml">
      <import file="ws-data.xml" provider="ws.1" name="titles" />
    </action-import>



Таблица 1. Атрибуты

Имя

Описание

**имя**

название действия

**конфигурация**

путь к конфигурации импорта данных

Для действия импорта требуется одна или несколько `<import>`задач:

*   `<import>`\- указать задачу импорта

    *   `file`\- имя входного файла, указанное в файле конфигурации.

    *   `provider`\- поставщик потока (ссылка на файл `action-ws`)

    *   `name`\- поместите данные как заданное имя в карту результатов