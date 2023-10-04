Панель мониторинга используется для предоставления обзоров. Представление информационной панели состоит из дашлетов.

    <dashboard name="welcome.dashboard" title="Welcome!">
      <dashlet action="chart:chart.sales.per.month"/>
      <dashlet action="chart:chart.sales.per.month.pie"/>
      <dashlet colSpan="12" action="sale.orders"/>
    </dashboard>



Дашлеты — это не что иное, как встроенные представления. Поддерживаются следующие типы представлений: `grid`, `chart`, `custom`, `cards`, `kanban`, `calendar`, `tree`, `html`.

Дашлет `action`может быть:

*   . `action-view`\_ Первое представление этого представления действия будет использоваться в дашлете.

*   `<view-type>:<view-name>`значение, где `<view-type>`— один из поддерживаемых типов представления и `<view-name>`имя представления.


Рекомендуемый способ — использовать `action-view`вместо `<view-type>:<view-name>`. Он предоставляет больше элементов управления и настройки отображаемого содержимого.