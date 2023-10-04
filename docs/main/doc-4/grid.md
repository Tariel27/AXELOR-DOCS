В представлении сетки данные отображаются в виде списка с несколькими столбцами.

Поскольку представления сетки выбирают множество записей для отображения в виде списка, важно отображать только важную информацию.

Представление сетки можно определить следующим образом:

    <grid name="contact-grid" title="Contacts"
      model="com.axelor.contact.db.Contact"> (1)
      <field name="fullName" /> (2)
      <field name="email" />
      <field name="phone" />
      <field name="dateOfBirth" />
    </grid>



**1**

определить вид сетки для данной модели предметной области

**2**

определить столбец, привязанный к полю модели предметной области

Теги `<field>`можно использовать для определения столбцов, которые привязываются к полям модели.

Представление сетки имеет следующие атрибуты:



Атрибут

Описание

**`name`**

имя представления, повторяющееся имя считается переопределяющим

**`model`**

полное имя модели домена, к которой принадлежит это представление

**`title`**

заголовок сетки

`id`

если вы переопределяете какой-либо существующий идентификатор, укажите уникальный идентификатор для его идентификации.

`editable`

доступна ли сетка для редактирования в режиме онлайн

`orderBy`

список имен полей, разделенный запятыми, для сортировки записей

`groupBy`

список имен полей, разделенный запятыми, для группировки записей

`edit-icon`

показывать ли значок редактирования в первом столбце (по умолчанию true)

`customSearch`

включен ли расширенный пользовательский поиск

`freeSearch`

укажите режим свободного поиска: «все» (по умолчанию), «нет» или список имен полей, разделенных запятыми.

`canNew`

разрешить ли создание новых записей

`canEdit`

разрешить ли редактирование записей

`canDelete`

разрешить ли удаление записей

`canSave`

разрешить ли сохранять записи

`canMove`

разрешить ли изменение порядка строк с помощью перетаскивания

`canArchive`

разрешить ли архивацию/разархивацию записей

`x-no-fetch`

следует ли получать начальные записи

`x-selector`

укажите элемент управления выбором строки ( `checkbox`чтобы отобразить выбор флажка)

The object should have a numeric field named `sequence` to allow re-ordering with drag & drop.

The grid view has the following child items:

*   `field` - define a column bound to the model fields

*   `button` - define a button to execute an action

*   `toolbar` - define custom toolbar buttons

*   `menubar` - define custom menubar

*   `hilite` - define rules to highlight rows/cells


Let’s see them in details:

[](#field)Field
---------------

The `<field>` is the most important and required item in a grid view definition. It defines a column that binds to some field of the given domain object.

It has the following attributes:



Attribute

Description

**`name`**

name of the field

`title`

title to be shown as column header, calculated if not provided

Besides these attributes, fields can also have other attributes supported by form view fields. These attributes are used by the inline editors.

[](#button)Button
-----------------

The `<button>` item can be used to put buttons at any row.



Attribute

Description

**`name`**

name of the button

`title`

title text for the button

`icon`

name of the icon to show (font-awesome icons)

`prompt`

text to show if confirmation is required when button is clicked

**`onClick`**

the name of the action to execute when button is clicked

`css`

custom CSS class to apply - _new in version 5.4_

[](#toolbar)Toolbar
-------------------

The `<toolbar>` item can be used to define custom toolbar buttons. These buttons are shown along with the top toolbar.

    <toolbar>
      <button name="btnPrint" icon="fa-print" title="Print" onClick="act1"/>
      <button name="btnExport" icon="fa-rocket" title="Export" onClick="act2"/>
    </toolbar>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

_New in version 5.4:_ In the case of grid view displayed as child of a form view or as a dashlet, first three buttons will be displayed.

[](#menubar)Menubar
-------------------

The `<menubar>` item can be used to define custom menus. These menus are also shown in the top toolbar.

    <menubar>
      <menu title="Actions" icon="img/address-book.png" showTitle="false">
        <item title="Send Greetings" action="act1"/>
        <item title="Home Page" action="act2"/>
        <divider/>
        <item title="Test" action="act3"/>
      </menu>
      ...
    </menubar>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

_New in version 5.4:_ In the case of grid view displayed as child of a form view or as a dashlet, first menu will be displayed.

[](#hilite)Hilite
-----------------

The `<hilite>` item should be applied on the grid view to highlight whole rows and on fields to highlight those specific cells.

example:

    <grid ...>
      <hilite background="warning" if="$contains(email, 'gmeil.com')"/>
      ...
    </grid>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Copied!

The attributes are:



Attribute

Description

**`if`**

an [angular.js](https://docs.angularjs.org/guide/expression) like boolean expression

`color`

name of the text color style

`background`

name of the background color style

`strong`

whether to show text in bold fonts

The following color & background styles are defined:



Style

Description

`default`

do not highlight

`primary`

highlight style to show some importance

`warning`

highlight style to show warning

`success`

highlight style to indicate success

`danger`

highlight style to show criticality

`info`

highlight style to indicate information

_New in version 5.4_:

Помимо этих стилей, также доступны следующие цвета:

*   `red`

*   `pink`

*   `purple`

*   `deeppurple`

*   `indigo`

*   `blue`

*   `lightblue`

*   `cyan`

*   `teal`

*   `green`

*   `lightgreen`

*   `lime`

*   `yellow`

*   `amber`

*   `orange`

*   `deeporange`

*   `brown`

*   `grey`

*   `bluegrey`

*   `black`

*   `white`


Если элемент `<hilite>`применяется в виде сетки, он выделяет строки. Если элемент `<hilite>`применяется к полям, он выделяет ячейки.

[](#advanced-search)Расширенный поиск
-------------------------------------

Расширенный поиск в виде сетки можно настроить для поиска по вложенным полям или полям o2m/m2m.

    <search-filters name="filter-sales" title="Filter Sale Orders" model="com.axelor.sale.db.Order">
      <!-- change title -->
      <field name="name" title="Order Ref." />
    
      <!-- include nested field -->
      <field name="customer.addresses.city" title="Customer city" />
    
      <!-- include nested field, but only if the condition is true -->
      <field name="items.product.name" title="Product Name" if="some condition" />
    
      <!-- hide the field from advanced search -->
      <field name="items" hidden="true" />
    
      <!-- optionally -->
      <filter title="Confirmed" name="confirmed">
        <domain>self.confirmed = true</domain>
      </filter>
    
    </search-filters>



Элементы `<field>`и `<filter>`не являются обязательными, но в . должен присутствовать хотя бы один элемент `<search-filters>`.

Элемент `<filter>`может иметь `name`атрибут, который будет использоваться в списке имен для файла . \- _новое в версии 5.4.2_[`default-search-filters`](../actions/action-view.html#view-action) `view-param`

Поиск по полям o2m/m2m может привести к появлению повторяющихся записей. Не существует универсального оптимального способа предотвратить это.

[](#example)Пример
------------------

Вот более полный пример:

    <grid name="contact-grid" title="Contacts" model="com.axelor.contact.db.Contact" editable="true">
      <toolbar>
        <button name="btnGreetAll" title="Greet" onClick="action.contact.greet.all"/>
      </toolbar>
      <menubar>
        <menu title="Actions">
          <item title="Action 1" action="action.some" />
          <item title="Action 2" action="action.thing" />
        </menu>
      </menubar>
      <hilite background="warning" if="$contains(email, 'gmeil.com')"/>
      <field name="fullName"/>
      <field name="firstName"/>
      <field name="lastName" onChange="com.axelor.contact.web.HelloController:guessEmail"/>
      <field name="email">
        <hilite strong="true" if="$contains(email, 'gmeil.com')"/>
      </field>
      <field name="phone"/>
      <field name="company"/>
      <field name="dateOfBirth">
        <hilite color="danger" strong="true" if="$moment().diff(dateOfBirth, 'years') &lt; 18"/>
      </field>
      <button name="btnGreet" title="Greet" onClick="action.contact.greet" />
    </grid>

