Используется `<action-condition>`для проверки правильности поля и отображения сообщения под полем.

    <action-condition name="check-order-dates">
      <check field="orderDate"/>
      <check field="createDate"/>
      <check field="createDate" if="orderDate &gt; createDate"
        error="Order creation date is in the future."/>
    </action-condition>



Для действия условия требуются следующие элементы:

*   `<check>`\- определить чек

    *   `field`\- название поля

    *   `error`\- сообщение об ошибке

    *   `if`\- логическое выражение для текущего контекста



Если `if`не указано, проверяется, является ли поле нулевым.

Если `error`не указано, отображается сообщение по умолчанию.