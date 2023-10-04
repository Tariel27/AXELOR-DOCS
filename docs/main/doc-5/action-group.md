Может `<action-group>`использоваться для сбора действий.

    <action-group name="action-validate-invoice">
      <action name="act1"/>
      <action name="act2"/>
      <action name="act3" if="invoiceDate"/>
    </action-group>


Таблица 1. Атрибуты

Имя

Описание

**имя**

название действия

Для группового действия требуются следующие элементы:

*   `<action>`\- определить действие

    *   `name`\- название действия

    *   `if`\- логическое выражение для текущего контекста