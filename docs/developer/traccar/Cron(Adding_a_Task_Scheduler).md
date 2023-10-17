# Получение информации о пломбе с Traccar с заданной периодичностью

#### Оглавление

1. [Описание задачи](#1-описание-задачи)
2. [Предварительные условия](#2-предварительные-условия)
3. [Установка](#3-установка)
4. [Реализация](#4-реализация)
5. [Конфигурация](#5-конфигурация)

## 1. Описание задачи

Получение информации о пломбе с Traccar с заданной периодичность. То есть нужно стучатся к Траккару и получать данные с заданной периодичностью (каждые 5 минут например).

## 2. Предварительные условия

У Axelor есть Job Management который управляет с периодичными работами (например backup). Я создал новый Job  и реализовал этот метод. Он с заданной периодичностью вызывает мои методы. Периодичность можно настроить через Axelor.

## 3. Установка

1. Axelor v7.0.0
2. JDK 11

## 4. Реализация

Я создал новый класс TraccarDataJob и наследовался от класса ThreadedBaseJob. Теперь мне нужно переопределить его метод `executeInThread`. Внутри этого метода я могу вызвать все нужные методы и они будут исполнятся с заданной периодичностью. Сначало я импортировал свой котроллер и по очереди вызываю его методы.

```java
@Override
public void executeInThread(JobExecutionContext context) {
    try {
        traccarController.getAndSaveSealInformation();
        traccarController.getAndSavePositionInformation();
        traccarController.getAndSetGeofences();
        tripService.checkDistanceAndSetStatus();
    } catch (Exception e) {
        e.printStackTrace();
    }
}
```
Чтобы его можно было настраивать через Axelor нужно добавить выборку и указать эту работу.

```java
!-- Для контролирование периодичности обращение к Traccar -->
<selection name="meta.schedule.job.select" id="ens.meta.schedule.job.select">
    <option value="com.axelor.apps.ens.job.TraccarDataJob">com.axelor.apps.ens.job.TraccarDataJob</option>
</selection>
```
## 5. Конфигурация

Заходим в нужную нам директорию: **Administration** -> **Job management** - > **All schedules**. 
Нужно создать новую работу. Выбираем нужную нам работу. Указываем периодичность.

![Job management](https://github.com/Tariel27/AXELOR-DOCS/blob/main/docs/developer/img/cron.png)
![Setup via Axelor](https://github.com/Tariel27/AXELOR-DOCS/blob/main/docs/developer/img/setupCron.png)

