# Получение информации о пломбе с Traccar с заданной периодичностью

#### Оглавление

1. [Описание задачи](#1-описание-задачи)
2. [Предварительные условия](#2-предварительные-условия)
3. [Установка](#3-установка)
4. [Реализация](#4-реализация)
5. [Конфигурация](#5-конфигурация)

## 1. Описание задачи

Получение информации о пломбе с Traccar с заданной периодичностью. Иными словами, необходимо обращаться к Traccar и получать данные с заданной регулярностью, например, каждые 5 минут.
## 2. Предварительные условия

В Axelor существует инструмент управления заданиями (`Job Management`), который позволяет управлять периодическими задачами, такими как, например, *резервное копирование*. Я создал новое задание (`Job`) и реализовал метод, который выполняется с определенной периодичностью, которую можно настраивать через `Axelor`.

## 3. Установка

1. Axelor v7.0.0
2. JDK 11

## 4. Реализация

Я создал новый класс `TraccarDataJob`, который наследуется от класса `ThreadedBaseJob`. Теперь мне нужно переопределить его метод `executeInThread`. Внутри этого метода я могу вызывать все необходимые методы, и они будут выполняться с заданной периодичностью. Сначала я импортировал свой `контроллер` и поочередно вызываю его методы.

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
Чтобы сделать его настраиваемым через `Axelor`, необходимо создать *выборку* и указать эту операцию.
```java
!-- Для контролирование периодичности обращение к Traccar -->
<selection name="meta.schedule.job.select" id="ens.meta.schedule.job.select">
    <option value="com.axelor.apps.ens.job.TraccarDataJob">com.axelor.apps.ens.job.TraccarDataJob</option>
</selection>
```
## 5. Конфигурация

Для настройки данного процесса заходим в соответствующий раздел: **Administration** -> **Job management** - > **All schedules**.
Здесь мы создаем новое задание, выбираем требуемую операцию и указываем периодичность.

![Job management](https://github.com/Tariel27/AXELOR-DOCS/blob/main/docs/developer/img/cron.png)
![Setup via Axelor](https://github.com/Tariel27/AXELOR-DOCS/blob/main/docs/developer/img/setupCron.png)

