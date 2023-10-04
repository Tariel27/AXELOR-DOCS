Открытая платформа Axelor объединяет мощные [отчеты BIRT](http://eclipse.org/birt/) для отчетности.

[](#configuration)Конфигурация
------------------------------

Следующие параметры конфигурации должны быть предоставлены через `axelor-config.properties`.

    # The external report design directory
    # ~~~~~
    # this directory is searched for the rptdesign files
    # (fallbacks to designs provided by modules)
    reports.design-dir = {user.home}/axelor/reports



*   `reports.design-dir`\- внешний каталог файлов дизайна и связанных ресурсов.


[](#directory-structure)Структура каталогов
-------------------------------------------

Структура каталогов отчетов должна быть следующей:

*   `reports`\- содержит файлы дизайна ( `.rptdesign`)

*   `reports/lib`\- содержит файлы библиотеки ( `.rptlibrary`)

*   `reports/img`\- содержит изображения

*   `reports/css`\- содержит таблицы стилей


Отчеты также могут быть предоставлены из самих модулей из `src/main/resources/reports` каталога, имеющего ту же структуру.

Если `reports.design-dir`задана конфигурация, локатор ресурсов сначала ищет файлы проекта и связанные ресурсы в этом каталоге и возвращается к ресурсам, предоставленным модулем.

[](#report-data-source)Источник данных отчета
---------------------------------------------

Отчеты следует использовать только `JDBC Data Source`для создания наборов данных для отчета.

Приложения Axelor Open Platform используют внутреннее спящее соединение для настройки источников данных отчетов.

[](#action-report)Отчет о действиях
-----------------------------------

Отчеты можно выполнять с помощью специального действия xml `action-report`.

Используется `<action-report>`для определения отчетов о действиях.

Таблица 1. Атрибуты

Имя

Описание

**`name`**

название действия

**`design`**

имя файла дизайна (файл .rptdesign)

**`output`**

имя выходного файла (можно использовать `${name}`, `${date}`, `${time}`для предоставления динамического имени)

`format`

формат вывода (pdf, doc, xsl, ps, html)

`attachment`

логическое значение, прикреплять ли сгенерированный отчет к текущему объекту

Отчет о действиях может содержать следующие элементы:

*   `<param>`\- параметр отчета

    *   `name`\- имя параметра

    *   `expr`\- выражение для предоставления значения параметра

    *   `if`\- условие, которое необходимо проверить перед подготовкой значения



пример:

    <action-report name="action-report-invoice"
        design="invoice.rptdesign"
        output="invoice-${date}${time}"
        format="pdf">
        <param name="some" expr="eval: expression" if="confirmed"/>
        <param name="thing" expr="constant" />
    </action-report>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Это `action-report`должно быть последнее действие в группе действий. Например:

    <button ... onClick="action-report-invoice" /> (1)
    <button ... onClick="save,action-some,action-report-invoice" /> (2)
    <button ... onClick="save,action-some,action-report-invoice,action-another" /> (3)

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

**1**

действительно, только одно действие

**2**

действительно, отчет о действии является последним действием

**3**

неверно, отчет о действии не является последним действием

[](#integration)Интеграция
--------------------------

Открытая платформа Axelor предоставляет простой в использовании API для создания отчетов.

*   `com.axelor.report.ReportGenerator`\- предоставляет методы для создания отчетов

*   `com.axelor.report.ReportEngineProvider`\- предоставляет предварительно настроенный экземпляр Singleton`IReportEngine`


Вы можете генерировать отчеты из своего кода следующим образом:

    public class PrintService {
    
        @Inject private ReportGenerator generator;
    
        public void print(String design, Map<String, Object> params) throws IOException {
    
            OutputStream output = new FileOutputStream(...);
            try {
                generator.generate(output, design, params, Locale.getDefault());
            } finally {
                output.close();
            }
        }
    }



Вы также можете работать с `IReportEngine`экземпляром напрямую (хотя это не рекомендуется) следующим образом:

    public class PrintService {
    
        @Inject private IReportEngine engine;
    
        public void print(String design, Map<String, Object> params) throws IOException {
    
            IResourceLocator locator = engine.getConfig().getResourceLocator();
            URL found = locator.findResource(null, design, IResourceLocator.OTHERS);
    
            if (found == null) {
                return;
            }
    
            // TODO: open the design
            // TODO: create render tasks
            // TODO: provide task options
            // TODO: run the task
        }
    }

