Представление карточек можно использовать для отображения связанных данных, таких как фотография, текст и ссылка на отдельный предмет, в виде карточек.

    <cards name="contact-cards" title="Contacts" model="com.axelor.contact.db.Contact" orderBy="fullName">
      <field name="fullName" />
      <field name="phone" />
      <field name="email" />
      <field name="address" />
      <field name="hasImage" />
      <template><![CDATA[
      <div class="span4 card-image">
        <img ng-if="hasImage" ng-src="{{$image(null, 'image')}}">
        <img ng-if="!hasImage" src="img/user.png">
        <strong>{{fullName}}</strong>
      </div>
      <div class="span8">
        <address>
          <strong>{{address.street}} {{address.area}}</strong><br>
          {{address.city}}<span ng-if="address.state">, {{address.state}}</span><span ng-if="address.zip"> - {{address.zip}}</span><br>
          {{address.country.name}}<br>
          <abbr ng-if="phone" title="Phone">P:</abbr> {{phone}}<br>
          <abbr ng-if="email" title="Email">E:</abbr> {{email}}<br>
        </address>
      </div>
      ]]></template>
    </cards>



Атрибуты представления карточек:



Атрибут

Описание

**`name`**

название представления

**`model`**

полное имя доменной модели

`orderBy`

поле для заказа карточек

`cardWidth`

указать виджет карточки (по умолчанию 33,33%)

Вы можете использовать `ui-action-click`директиву в шаблоне для выполнения любого действия при событии клика.

Например:

    <template><![CDATA[
    <button type="button" class="btn" ui-action-click="some.action" />
    ]]>
    </template>



[](#template)Шаблон
-------------------

Его `<template>`следует использовать для предоставления шаблона angular.js для подготовки контекста карточек. Он может использовать только определенные `<field>`значения.

`$image(field, image)`Для размещения изображения можно использовать вспомогательную функцию шаблона .

    <!-- if image is binary field -->
    <img ng-src="{{$image(null, 'image')}}">
    
    <!-- if image is m2o to MetaFile -->
    <img ng-src="{{$image('image', 'content')}}">
    
    <!-- show binary field image of custom in sale order card -->
    <img ng-src="{{$image('customer', 'image')}}">



Поле должно быть включено в определение представления карточки с `<field>`тегом.

Предоставляются следующие помощники

*   `$image(field, image)`\- показать изображение для данного поля

*   `$fmt(field)`\- показать форматированное значение данного поля