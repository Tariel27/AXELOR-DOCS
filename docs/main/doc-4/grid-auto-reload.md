# Автоматическое обновление списка grid в Axelor

**Данная документация была написана и протестирована на Axelor версии 6.1.3.**

В самом Axelor нет возможности через xml организовать автоматическое (периодическое) обновление данных в таблице grid.
В связи с этим, придумали использовать код на Java Script, который создает time interval для периодического вызова команды обновления списка.

Далее представлен пример такого кода:

```
let gridRefreshTimer = null;

window.addEventListener("hashchange",function (){
        console.log("Grid Refresh: started");
        let gridHash = "#/ds/sample.action/list/1"
        let hash = this.location.hash;
        if(hash === gridHash){
            console.log("Grid Refresh: condition is true");
            startTimer();
        }
        else{
            console.log("Grid Refresh: timer stopped");
            clearInterval(gridRefreshTimer);
        }
    })

function startTimer(){
    console.log("Grid Refresh: starting timer");
    gridRefreshTimer = setInterval(
                            () => {
                                console.log("Grid Refresh: from inside the timer");
                                $("[ng-controller=GridViewCtrl]").scope().onRefresh();
                            },
                            120000);
}
```

Здесь строка `let gridHash = "#/ds/sample.action/list/1"` определяет тот URL, при загрузке которого должен запуститься интервальный таймер.
Данный код нужно читать так: если текущий адрес (URL) совпадает с заданным в переменной `gridHash`, то запустить интервальный таймер.

**Самая главная строка в коде:** `$("[ng-controller=GridViewCtrl]").scope().onRefresh();` это и есть команда обновления содержимого таблицы grid.

Данный скрипт запускает обновление содержимого таблицы grid каждые 2 минуты (120 000 миллисекунд).

## Где расположить Java Script код для автоматического обновления?

Код указанный выше необходимо записать в файл с расширением .js и расположить его в папке `module-name/src/main/webapp`.
При необходимости, в этой папке можно также создать поддиректории и положить файл с кодом туда.

## Регистрация созданного Java Script файла в модуле

Созданный Java Script файл необходимо зарегистрировать в модуле.
Для этого нужно реализовать интерфейс `StaticResourceProvider` и имплементировать его метод `register`.

Вот пример кода регистрации созданного скрипта:

```
package com.axelor.apps.sur.web;

import com.axelor.web.StaticResourceProvider;

import java.util.List;

public class MyStaticResource implements StaticResourceProvider {
    @Override
    public void register(List<String> resources) {
        resources.add("gridRefresh/gridRefresh.js");
    }
}
```

В данном примере наш Java Script код записан в файле `gridRefresh.js`, который расположен по следующему адресу: `module-name/src/main/webapp/gridRefresh/`.