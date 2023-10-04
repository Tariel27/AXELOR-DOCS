Представления формы и сетки можно изменить, определив новое представление с таким же `name`, уникальным `id`определением и `extension="true"`. Такой вид представления называется _представлением расширения_ .

[](#example)Пример
------------------

    <form name="contact-form" title="Contact" model="com.axelor.contact.db.Contact"
      id="sale-contact-form" extension="true">
    
      <!-- Insert a dashlet after Contacts panel. -->
      <extend target="panel[@title='Contacts']">
        <insert position="after">
          <panel-dashlet action="action-view-orders-by-contact" title="Orders"/>
        </insert>
      </extend>
    
      <!-- Replace fullName field by firstName and lastName fields. -->
      <extend target="//field[@name='fullName']">
        <replace>
          <field name="firstName"/>
          <field name="lastName"/>
        </replace>
      </extend>
    
      <!-- Move Extra panel before first sidebar panel. -->
      <extend target="panel[@sidebar='true']">
        <move position="before" source="panel[@title='Extra']"/>
      </extend>
    
      <!-- Change widget attribute on notes field. -->
      <extend target="//field[@name='notes']">
        <attribute name="widget" value="html"/>
      </extend>
    
      <!-- Change attributes on the root element. -->
      <extend target="/">
        <attribute name="canAttach" value="false"/>
        <attribute name="width" value="large"/>
      </extend>
    
    </form>



Определение расширенных представлений приводит к созданию вычисляемых представлений (представлений с `computed="true"`) с приоритетом выше, чем у исходных представлений. Эти вычисленные представления создаются повторно при каждом обновлении представлений расширения или исходных представлений.

[](#tags)Теги
-------------

### [](#extend)продлевать

Представления расширений имеют один или несколько `<extend>`тегов, определяющих расширения:

    <extend target="<XPath expression>" if-feature="<feature name>" if-module="<module name>">
      <!-- One or more extension operations -->
    </extend>





Атрибут

Описание

`target`

[Выражение XPath](https://www.w3.org/TR/1999/REC-xpath-19991116/) для выбора целевого элемента операции расширения (операция расширения выполняется только при первом совпадении)

`if-feature`

название функции и применять это расширение только в том случае, если эта функция включена _(необязательно)._

`if-module`

имя модуля и применяйте это расширение только в том случае, если этот модуль установлен _(необязательно)_

Атрибут `if-feature`работает с расширением класса `com.axelor.app.AppConfig`и указанным `application.config-provider`конфигурацией в `axelor-config.properties`файле:

    import com.axelor.app.AppConfig;
    
    public class AppService implements AppConfig {
    
      @Override
      public boolean hasFeature(String featureName) {
        // Return whether the feature is enabled.
      }
    }



Тег `<extend>`состоит из одной или нескольких операций расширения, среди которых `insert`, `replace`, `move`и `attribute`.

### [](#insert)вставлять

Вставьте указанные элементы в позицию относительно целевого элемента.

    <insert position="before|after|inside">
      <!-- Elements to insert -->
    </insert>





Атрибут

Описание

`position`

позиция, куда вставлять эти элементы, относительно целевого элемента: `before`, `after`или`inside`

### [](#replace)заменять

Замените целевой элемент указанными элементами. `replace`К одному целевому элементу можно применить только одну операцию.

    <replace>
      <!-- Elements to replace the target element with -->
    </replace>



Если элементы не указаны, целевой элемент удаляется.

### [](#move)двигаться

Переместите указанный исходный элемент в положение относительно целевого элемента.

    <move position="before|after|inside" source="<XPath expression>"/>





Атрибут

Описание

`position`

позиция, куда переместить этот исходный элемент относительно целевого элемента: `before`, `after`или`inside`

`source`

[Выражение XPath](https://www.w3.org/TR/1999/REC-xpath-19991116/) для выбора исходного элемента `move`операции

### [](#attribute)атрибут

Измените указанный атрибут целевого элемента.

    <attribute name="<attribute name>" value="<attribute value>"/>





Атрибут

Описание

`name`

имя атрибута, который нужно изменить

`value`

новое значение атрибута

Если значение пустое, атрибут удаляется из элемента.

[](#positioning)Позиционирование
--------------------------------

Обычно `before`это означает перед целевым элементом и `after`означает после целевого элемента.

Однако, когда целевой элемент `"/"`(корневой элемент представления), значение изменяется: `before`означает перед первым дочерним элементом и `after`означает после последнего дочернего элемента: рассматриваются особые случаи, когда рассматриваются некоторые элементы, такие как `<toolbar>`и `<menubar>`, которые должны оставаться сверху. автоматически:

    <!-- Insert a dashlet as first element inside the view. -->
    <!-- If a toolbar and/or a menubar already exist, -->
    <!-- the dashlet is inserted after those. -->
    <extend target="/">
      <insert position="before">
        <panel-dashlet action="action-view-orders-by-contact" title="Orders"/>
      </insert>
    </extend>

