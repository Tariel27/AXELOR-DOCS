В представлении формы отображается одна запись в макете формы. Это основной вид для просмотра записи с подробными сведениями.

Просмотр формы имеет два режима:

*   `readonly`\- режим показывает значения полей в виде текста HTML

*   `editable`\- режим показывает редакторы полей со значениями


Представление формы определяется следующим образом:

    <form name="contact-form"
          title="Contact"
          model="com.axelor.contact.db.Contact"> (1)
      <panel name="overviewPanel" title="Overview"> (2)
        <field name="fullName" readonly="false"> (3)
          <editor> (4)
            <field name="title" colSpan="3"/>
            <field name="firstName" colSpan="4"/>
            <field name="lastName" colSpan="5"/>
          </editor>
        </field>
        <field name="dateOfBirth" />
        <field name="email">
          <viewer><![CDATA[ (5)
          <a href="mailto:{{record.email}}">{{record.email}}</a>
          ]]></viewer>
        </field>
        <field name="phone">
          <viewer><![CDATA[
          <a href="tel:{{record.phone}}">{{record.phone}}</a>
          ]]></viewer>
        </field>
      </panel>
      <panel name="aboutMePanel" title="About me">
          <field name="notes" showTitle="false" colSpan="12"/>
      </panel>
      <panel-related name="addressesPanel" field="addresses"> (6)
          <field name="street"/>
          <field name="area"/>
          <field name="city"/>
          <field name="state"/>
          <field name="zip"/>
          <field name="country"/>
      </panel-related>
      <panel name="sidebarPanel" sidebar="true"> (7)
        <field name="createdOn"/>
        <field name="createdBy"/>
        <field name="updatedOn"/>
        <field name="updatedBy"/>
      </panel-side>
    </form>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

представление формы для данной доменной модели

**2**

панель для группировки соответствующих полей

**3**

поле ввода, привязанное к данной модели

**4**

редактор можно использовать для определения пользовательского редактора для поля

**5**

средство просмотра можно использовать для определения пользовательского шаблона для отображения значения поля

**6**

панель, связанная с панелью, может использоваться для отображения полей o2m/m2m

**7**

панель для отображения на правой боковой панели

Представление формы может иметь следующие атрибуты:



Атрибут

Описание

**`name`**

имя представления, дубликаты считаются переопределяющими

**`model`**

полное имя доменной модели

**`title`**

заголовок представления формы

`id`

При переопределении какого-либо существующего идентификатора укажите уникальный идентификатор для его идентификации.

`editable`

доступна ли форма для редактирования

`readonlyIf`

логическое выражение [angular.js](https://docs.angularjs.org/guide/expression) , позволяющее сделать форму доступной только для чтения

`onNew`

действие, которое будет вызвано при создании новой записи

`onLoad`

действие, которое будет вызвано при загрузке записи

`onSave`

действие, которое будет вызвано при сохранении этой формы

`canNew`

логическое выражение [angular.js](https://docs.angularjs.org/guide/expression) для кнопки «Создать»

`canEdit`

логическое выражение [angular.js](https://docs.angularjs.org/guide/expression) для кнопки «Редактировать»

`canDelete`

логическое выражение [angular.js](https://docs.angularjs.org/guide/expression) для кнопки «Удалить»

`canCopy`

логическое выражение [angular.js](https://docs.angularjs.org/guide/expression) для кнопки «Копировать»

`canSave`

логическое выражение [angular.js](https://docs.angularjs.org/guide/expression) для кнопки «Сохранить»

`canAttach`

логическое выражение [angular.js](https://docs.angularjs.org/guide/expression) для кнопки «Вложение»

`width`

Предпочитаемый стиль ширины представления: `mini`, `mid`или `large`.

В форме используется адаптивный макет, который настраивается в соответствии с доступным размером экрана. Форма разделена на 12 столбцов. Первые 8 столбцов используются для размещения основных панелей, а остальные 4 столбца используются для размещения боковых панелей. Если боковые панели не предусмотрены, обычные панели будут занимать все 12 столбцов.

[](#panels)Панели
-----------------

Давайте рассмотрим каждый тип панели.

*   `panel`\- панель с 12 столбцами, обычно используемая для размещения простых полей

*   `panel-tabs`\- содержит другие панели, которые отображаются в виде вкладок блокнота.

*   `panel-stack`\- содержит другие панели, которые прикреплены

*   `panel-related`\- панель для размещения полей o2m/m2m

*   `panel-include`\- включить еще одну форму панели

*   `panel-dashlet`\- Панель дашлета можно использовать для встраивания других представлений


### [](#panel)Панель

A `panel`может иметь следующие атрибуты:



Атрибут

Описание

**`title`**

название панели

`name`

название панели

`colSpan`

количество столбцов, занимаемых виджетом

`itemSpan`

диапазон по умолчанию для дочерних элементов

`hidden`

скрывать ли виджет

`hideIf`

логическое выражение angular.js [,](https://docs.angularjs.org/guide/expression) чтобы скрыть панель

`readonly`

следует ли считать виджет доступным только для чтения

`readonlyIf`

логическое выражение angular.js [,](https://docs.angularjs.org/guide/expression) чтобы пометить панель только для чтения

`showIf`

логическое выражение angular.js для отображения [панели](https://docs.angularjs.org/guide/expression)

`onTabSelect`

действие, выполняемое при выборе вкладки панели (если оно находится на верхнем уровне в вкладках панели)

`showFrame`

показывать ли рамку вокруг панели

`showTitle`

показывать ли заголовок панели

`sidebar`

показывать ли эту панель на боковой панели

`attached`

прикреплять ли панель к предыдущей

`stacked`

являются ли элементы панели стека

`if-module`

использовать виджет, если данный модуль установлен

`canCollapse`

укажите, является ли панель разборной

`collapseIf`

укажите логическое выражение, чтобы свернуть/развернуть эту панель

`help`

Текст справки, отображаемый при наведении курсора мыши — _новое в версии 5.4._

    <panel title="Overview">
      <!-- widgets -->
    </panel-tabs>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

### [](#panel-tabs)Вкладки панели

A `panel-tabs`содержит другие панели, которые отображаются в виде вкладок блокнота. Он включает в себя все `panel`атрибуты, кроме `itemSpan`, `title`и `showTitle`.

    <panel-tabs>
      <panel-related field="relatedField"/>
      <panel title="Notes">
        <!-- widgets -->
      </panel>
    </panel-tabs>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

### [](#panel-stack)Стек панелей

A `panel-stack`содержит другие панели. Это стопка панелей, и дочерние панели размещаются одна за другой.

Он включает все `panel`атрибуты, кроме `itemSpan`, `title`и `showTitle`.

    <panel-stack showIf="color">
      <panel title="Page 1" showIf="color == 'black'"/>
      <panel title="Page 2" showIf="color == 'white'"/>
      <panel title="Page 3" showIf="color == 'gray'"/>
    </panel-stack>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

### [](#panel-related)Связанные с панелью

A `panel-related`используется для размещения полей o2m/m2m. Ниже обычных панелей отображается отдельная панель с виджетом сетки, внутри которого определены поля.

Он включает в себя все атрибуты `panel`и, `relational`кроме `itemSpan`. А `panel-related`включает в себя следующие атрибуты:



Атрибут

Описание

**`field`**

название панели

`editable`

доступна ли сетка для редактирования в режиме онлайн

`orderBy`

список имен полей, разделенный запятыми, для сортировки записей

`onNew`

действие, которое будет вызвано при создании новой записи

`onChange`

действие, которое будет вызываться при изменении значения поля

`canMove`

разрешить ли изменение порядка строк с помощью перетаскивания

`height`

количество строк (не высота в пикселях)

`x-selector`

укажите элемент управления выбором строки ( `checkbox`чтобы отобразить выбор флажка)

`edit-window`

режим отображения окна редактирования реляционных полей. Может быть `self`, `blank`или `popup`(значение по умолчанию).

Объект должен иметь числовое поле с именем, `sequence`позволяющим изменять порядок с помощью перетаскивания.

    <panel-related field="addresses">
      <!-- grid widgets -->
    </panel-related>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

### [](#panel-include)Панель включает

A `panel-include`включает в себя еще одну форму панели.

A `panel-include`может иметь следующие атрибуты:



Атрибут

Описание

**`view`**

Имя существующего представления

`from`

Имя модуля, из которого должно быть включено представление

`if-module`

использовать виджет, если данный модуль установлен

    <panel-include view="product-from" from="axelor-sale"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

### [](#panel-dashlet)Панель Дашлет

A `panel-dashlet`можно использовать для встраивания других представлений, таких как диаграмма, портлет, iframe…

A `panel-dashlet`может иметь следующие атрибуты:



Атрибут

Описание

**`action`**

`name`

название панели

`title`

название панели

`canSearch`

включить заголовок поиска (для представлений в виде сетки) или поле поиска (для представлений в виде карточек)

`height`

высота, которую занимает виджет

`colSpan`

количество столбцов, занимаемых виджетом

`hidden`

скрывать ли виджет

`hideIf`

логическое выражение angular.js [,](https://docs.angularjs.org/guide/expression) чтобы скрыть панель

`readonly`

следует ли считать виджет доступным только для чтения

`readonlyIf`

логическое выражение angular.js [,](https://docs.angularjs.org/guide/expression) чтобы пометить панель только для чтения

`showIf`

логическое выражение angular.js для отображения [панели](https://docs.angularjs.org/guide/expression)

`showTitle`

показывать ли заголовок панели

`if-module`

использовать виджет, если данный модуль установлен

    <panel-dashlet action="chart:chart.sales.per.month"/>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

[](#panel-widgets)Виджеты панели
--------------------------------

Можно `panel`использовать следующие виджеты:

*   `menu`\- определить пользовательское меню для панели

*   `field`\- привязывает поле модели, автоматически выбирает соответствующий виджет

*   `spacer`\- можно использовать для пропуска ячейки

*   `separator`\- может использоваться для определения границы

*   `label`\- можно использовать для установки статической метки (предпочтительно `static`)

*   `static`\- может использоваться для отображения статического текста (предпочтительнее `label`)

*   `help`\- может использоваться для отображения статической справочной информации

*   `button`\- виджет кнопки, выполняющий какое-то действие

*   `button-group`\- группа кнопок

*   `panel`\- встроенная панель

*   `panel-dashlet`\- встроенная панель-дашлет

*   `panel-include`\- встроенная панель-включение

*   `panel-related`\- встроенная панель, связанная с


Поле имеет несколько свойств, но наиболее распространенными из них являются:

*   `name`\- название виджета

*   `hidden`\- скрыт ли виджет

*   `readonly`\- доступен ли виджет только для чтения

*   `required`\- обязательно ли поле


[](#dummy-fields)Фиктивные поля
-------------------------------

Представление формы может иметь фиктивные поля. Эти поля не привязаны ни к одному из полей модели, но используются для предоставления дополнительного контекста.

Фиктивные поля могут быть указаны следующим образом:

    <!-- string field if type is not specified -->
    <field name="some" />
    <!-- integer field, prefixed with $ to avoid dirty flag -->
    <field name="$another" type="integer" min="1" max="100" />
    
    <!-- relational fields -->
    <field name="some" type="many-to-one"
      x-target="com.axelor.contact.db.Contact"
      x-target-name="fullName" />

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Имена фиктивных полей могут иметь префикс `$`, чтобы избежать появления грязного флага в форме при обновлении этого поля. Контекст по-прежнему получает значение без `$`префикса.

[](#field-editor)Редактор полей
-------------------------------

Мы можем определить собственный редактор для полей, используя `<editor>`дочерний элемент поля.

    <!-- editor for a computed field -->
    <field name="fullName">
      <editor>
        <field name="title" />
        <field name="firstName" />
        <field name="lastName" />
      </editor>
    </field>
    
    <!-- editor for a many-to-one field -->
    <field name="customer">
      <editor x-viewer="true">
        <field name="firstName" />
        <field name="lastName" />
        <field name="email" />
      </editor>
    </field>
    
    <!-- editor for a one-to-many field -->
    <field name="emails">
      <editor layout="table" onNew="compute-default-email">
        <field name="email" />
        <field name="primary" widget="toggle" x-icon="fa-star-o" x-icon-active="fa-star" x-exclusive="true" />
        <field name="optOut" widget="toggle" x-icon="fa-ban" />
        <field name="invalid" widget="toggle" x-icon="fa-exclamation-circle" />
      </editor>
    </field>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Они `editor`могут иметь следующие свойства:

*   `layout`\- альтернативный макет ( `panel`(по умолчанию) или `table`)

*   `onNew`\- действие, вызываемое при создании новой записи (только для редакторов «один-ко-многим»)

*   `x-viewer`\- можно использовать для рассмотрения редактора как зрителя

*   `x-show-titles`\- показывать ли заголовки в полях редактора

*   `x-show-on-new`\- показывать ли редактор при создании новой записи


Виджет `toggle`специально создан для редакторов «один-ко-многим», позволяющих устанавливать логические флаги для записи. Виджет `toggle`имеет следующие атрибуты:

*   `x-icon`\- значок, который отображается, когда значение поля не установлено или`false`

*   `x-icon-ative`\- значок, показывающий, когда значение поля равно`true`

*   `x-exclusive`\- если `true`поле только этой строки списка o2m может быть`true`


Можно `editor`использовать следующие виджеты:

*   `field`\- привязывает поле модели, автоматически выбирает соответствующий виджет

*   `button`\- виджет кнопки, выполняющий какое-то действие

*   `spacer`\- можно использовать для пропуска ячейки

*   `separator`\- может использоваться для определения границы - _новое в версии 5.4._

*   `label`\- можно использовать для установки статической метки

*   `panel`\- встроенная панель


[](#field-viewer)Просмотрщик полей
----------------------------------

Мы можем определить собственный просмотрщик полей, используя `<viewer>`дочерний элемент поля.

    <!-- custom viewer on a normal field -->
    <field name="customer">
      <viewer><![CDATA[
      <strong>{{record.fullName|upper}}</strong>
      ]]></viewer>
    </field>
    
    <!-- custom viewer on a many-to-one field -->
    <field name="customer">
      <viewer depends="fullName,email"><![CDATA[
      <a href="mailto:{{record.customer.email}}">{{record.customer.email}}</a>
      ]]></viewer>
    </field>
    
    <!-- customer viewer on a one-to-many field -->
    <field name="emails">
      <viewer><![CDATA[
      <a href="mailto:{{record.email}}">{{record.email}}</a>
      ]]></viewer>
    </field>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Средство просмотра использует [шаблон angular.js](https://docs.angularjs.org/guide/templates) для отображения значений. Шаблон может получить доступ к текущей записи с помощью `record`переменной.

Если средство просмотра использует поля, отсутствующие в текущем представлении формы, они должны быть перечислены в виде списка полей с `depends=""`атрибутом, разделенных запятыми.

Шаблон средства просмотра может иметь следующие вспомогательные функции для отображения значений:

*   `$get(name)`\- получить вложенное значение

*   `$moment(date)`\- скрытое значение даты для `moment.js`экземпляра

*   `$number(value)`\- преобразовать текстовое значение в число

*   `$image(fieldName)`\- получить URL-адрес изображения для данного поля изображения

*   `$fmt(fieldName)`\- получить форматированное значение данного поля


[](#field-tooltip)Подсказка поля
--------------------------------

_Новое в версии 5.4_

Мы можем определить шаблон сведений в поле, чтобы отображать дополнительную информацию о ячейке при наведении курсора мыши.

    <field name="customer">
      <tooltip depends="fullName">
      <![CDATA[
      <strong>Name: </strong><span>{{record.fullName}}</span>
      ]]>
      </tooltip>
    </field>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!