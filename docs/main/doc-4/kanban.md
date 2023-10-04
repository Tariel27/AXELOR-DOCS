Канбан-представление — это гибкая панель мониторинга, подобная представлению.

    <kanban name="project-task-kanban" title="Project Tasks" model="com.axelor.project.db.ProjectTask"
      columnBy="state" sequenceBy="priority" onNew="project.task.kanban.on.new" limit="10">
      <field name="name"/>
      <field name="notes" />
      <field name="progress"/>
      <field name="startDate"/>
      <field name="endDate"/>
      <field name="user"/>
      <hilite color="danger" if="progress == 0" />
      <hilite color="success" if="progress == 100" />
      <hilite color="info" if="progress &gt;= 50" />
      <hilite color="warning" if="progress &gt; 0" />
      <template><![CDATA[
      <h4>{{name}}</h4>
      <img ng-if="user" src="{{$image('user', 'image')}}">
      <div class="card-body">{{notes}}</div>
      <div class="card-footer">
        <i class='fa fa-clock-o'></i> <span>{{startDate|date:'yyyy-MM-dd HH:mm:ss'}}</span>
      </div>
      ]]></template>
    </kanban>



Атрибуты представления канбана:



Атрибут

Описание

**`name`**

название представления

**`model`**

полное имя доменной модели

**`columnBy`**

поле выбора для создания столбцов

**`sequenceBy`**

поле, которое можно использовать для изменения порядка карточек (только числовые поля)

`onNew`

поле, которое будет использоваться при создании записи на лету

`onMove`

действие для вызова при перемещении карты канбан

`limit`

ограничение на количество страниц на столбец

[](#template)Шаблон
-------------------

Его `<template>`следует использовать для предоставления шаблона angular.js для подготовки контекста карточек. Он может использовать только определенные `<field>`значения.

`$image(field, image)`Для размещения изображения можно использовать вспомогательную функцию шаблона .