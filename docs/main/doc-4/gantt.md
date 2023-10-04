В представлении Ганта данные отображаются в виде диаграммы Ганта:

    <gantt name="project-task-gantt" title="Task Planning" model="com.axelor.project.db.ProjectTask"
      mode="year"
      taskStart="plannedStartDate"
      taskDuration="plannedDuration"
      taskParent="parentTask"
      taskSequence="sequence"
      taskProgress="plannedProgress"
      x-finish-to-start="finishToStartTaskSet"
      x-start-to-start="startToStartTaskSet"
      x-finish-to-finish="finishToFinishTaskSet"
      x-start-to-finish="startToFinishaskSet">
      <field name="name" />
      <field name="project" />
      <field name="user" />
    </gantt>



Атрибуты представления Ганта:



Атрибут

Описание

`name`

название представления Ганта

`title`

название представления Ганта

`model`

полное имя доменной модели

`mode`

режим просмотра, между `year`, `month`, `week`или `day`(по умолчанию `month`)

`taskStart`

имя поля типа дата/дата-время, которое будет использоваться в качестве времени начала

`taskDuration`

имя поля длительности

`taskEnd`

имя поля типа дата/дата-время, которое будет использоваться в качестве времени окончания

`taskParent`

имя родительского поля

`taskProgress`

имя поля прогресса

`taskSequence`

имя поля для упорядочения задач

`taskUser`

имя пользовательского поля, связанного с задачей

`x-finish-to-start`

имя поля M2M, содержащего задачи, которые необходимо завершить перед запуском текущей задачи

`x-start-to-start`

имя поля M2M, содержащего задачи, которые необходимо запустить перед запуском текущей задачи

`x-finish-to-finish`

имя поля M2M, содержащего задачи, которые необходимо выполнить перед завершением текущей задачи

`x-start-to-finish`

имя поля M2M, содержащего задачи, которые необходимо запустить перед завершением текущей задачи