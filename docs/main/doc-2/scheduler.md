Открытая платформа Axelor объединяет многофункциональную библиотеку [кварцевого планировщика](https://quartz-scheduler.org/) для планирования заданий.

Задания выполняются отдельным процессом, запущенным в сеансе администратора. Выполняемые услуги могут быть транзакционными. Все операции с базой данных будут выполняться с использованием прав администратора.

[](#configuration)Конфигурация
------------------------------

По умолчанию планировщик отключен. Его можно включить с помощью следующей конфигурации.

    # Quartz Scheduler
    # ~~~~~
    # quartz job scheduler
    
    # Specify whether to enable quartz scheduler
    quartz.enable = false
    
    # total number of threads in quartz thread pool
    # the number of jobs that can run simultaneously
    quartz.thread-count = 5


[](#jobs)Вакансии
-----------------

Запланированные задания можно настроить из `Administration → Jobs → Schedules`меню. Данные конфигурации расписания требуют:

*   `name`\- название работы

*   `job``org.quartz.Job`\- интерфейс реализации класса задания

*   `cron`\- строка [cron](https://www.quartz-scheduler.org/documentation/quartz-2.3.0/tutorials/crontrigger.html) для планирования задания

*   `active`\- включено ли задание


Кроме того, конфигурация задания может иметь значения параметров (список пар ключ → значение).

Вот пример реализации задания:

    package com.axelor.contact.jobs;
    
    import org.quartz.Job;
    import org.quartz.JobDataMap;
    import org.quartz.JobDetail;
    import org.quartz.JobExecutionContext;
    import org.quartz.JobExecutionException;
    
    public class HelloJob implements Job {
    
      @Override
      public void execute(JobExecutionContext context) throws JobExecutionException {
        JobDetail detail = context.getJobDetail();
        JobDataMap data = context.getJobDetail().getJobDataMap();
    
        String name = detail.getKey().getName();
        String desc = detail.getDescription();
    
        System.err.println("Job fired: " + name + " (" + desc + ")");
        if (data != null && data.size() > 0) {
          for (String key : data.keySet()) {
            System.err.println("    " + key + " = " + data.getString(key));
          }
        }
      }
    }

