В представлении «Основные сведения» представления сетки и формы отображаются рядом друг с другом как единое представление. Его можно определить с `action-view`помощью параметра представления `details-view`.

    <action-view name="team.tasks.all" model="com.axelor.team.db.TeamTask" title="Tasks">
      <view name="team-task-grid" type="grid" /> (1)
      <view name="team-task-form" type="form" /> (2)
      <view-param name="details-view" value="true" /> (3)
    </action-view>



**1**

вид сетки, используемый этим действием

**2**

представление формы, используемое этим действием

**3**

`details-view`params настраивает вид сетки для отображения подробностей справа

Мы также можем предоставить альтернативное представление формы, указав имя представления в качестве `details-view`значения параметра, например `<view-param name="details-view" value="another-form-view" />`.