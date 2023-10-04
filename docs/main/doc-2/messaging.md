Открытая платформа Axelor предоставляет интегрированные функции обмена сообщениями и потоковой передачи:

*   отслеживание изменений

*   обсуждение документов

*   групповые обсуждения

*   интеграция электронной почты


[](#change-tracking)Отслеживание изменений
------------------------------------------

Функцию отслеживания изменений можно использовать для записи контрольного журнала в виде потока сообщений при изменении документа/записи.

Чтобы включить отслеживание изменений объекта, в определении объекта должны быть указаны сведения об отслеживании.

Вот пример:

    <entity name="SaleOrder">
      <string name="name" ... />
      ...
      ...
    
      <track>
        <field name="name" />
        <field name="createDate" on="CREATE" />
        <field name="customer" />
        <field name="confirmDate" on="UPDATE" if="status == 'confirmed'" />
        <field name="totalAmount" />
        <message if="true" on="CREATE">Order created.</message>
        <message if="status == 'confirmed'" on="UPDATE">Order confirmed.</message>
        <message if="status == 'draft'" tag="important">Draft</message>
        <message if="status == 'confirmed'" tag="success" fields="status">Confirmed</message>
      </track>
    
    </entity>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Сообщения `track`генерируются `on`следующими операциями:

*   `CREATE`\- генерировать при создании записи

*   `UPDATE`\- генерировать при обновлении записи

*   `ALWAYS`\- генерировать во всех случаях


Другие `track`атрибуты:

*   `files`\- указать, следует ли отслеживать прикрепленные файлы

*   `subscribe`\- указать, следует ли автоматически подписываться на уведомления об изменениях

*   `replace`\- указать, следует ли заменять исходную конфигурацию трека изменений


Информация `track`предоставляется:

*   `<field>`\- указать какое поле отслеживать

    *   **`name`**\- имя поля для отслеживания

    *   `on`\- по какому событию должно отслеживаться это поле

    *   `if`— логическое выражение для проверки перед отслеживанием поля (JEL)


*   `<message>`\- указать сообщения для отображения

    *   `if`\- логическое выражение для проверки перед использованием сообщения

    *   `on`\- при каком событии следует использовать эти сообщения

    *   `tag`\- указать предопределенный класс тега, если это сообщение является тегом

    *   `fields`\- используйте это сообщение в качестве тега только в том случае, если какое-либо из данных полей изменено.



Если `<message>`предполагается, что a будет использоваться как a `tag`, следует использовать следующие предопределенные имена классов CSS:

*   `important`\- важный стиль (красный)

*   `success`\- стиль успеха (зеленый)

*   `warning`\- стиль предупреждения (желтый)

*   `info`\- информационный стиль (синий)


Выражения `if`представляют собой простые логические выражения JEL, вычисляемые по текущим значениям записи.

По умолчанию `<field>`отслеживаются, только если его значение изменено и данное `if` выражение имеет значение `true`. Поля O2M/M2M/двоичного типа не поддерживаются.

Корневое сообщение создается при создании записи. Все последующие сообщения считаются ответами на это корневое сообщение. Это сделано для того, чтобы сообщения об отслеживании изменений сохранялись в виде цепочки.

[](#streams-discussions)Стримы и обсуждения
-------------------------------------------

Потоки отслеживания изменений можно отображать в любых представлениях форм со следующей разметкой:

    <form name="sale-order-form" title="Sale Order" ....>
      ...
      ...
      <panel-mail>
        <mail-messages limit="4" />
        <mail-followers />
      </panel-mail>
    </form>

xml![копировать значок](../../../../_/img/octicons-16.svg#view-clippy)Скопировано!

Его `<panel-mail>`можно использовать для отображения потоков отслеживания изменений или сообщений обсуждений в виде цепочки.

*   `<mail-messages>`\- показывает сообщения в виде цепочки

*   `<mail-followers>`\- показывает список подписчиков/фолловеров


Сообщения отображаются в соответствии с заданным значением, `limit`которое `<mail-messages>`по умолчанию составляет 30 сообщений.

Первыми отображаются самые последние сообщения. Дополнительные сообщения можно загрузить с помощью ссылки, расположенной в конце списка сообщений (если сообщений больше).

[](#discussion-groups)Дискуссионные группы
------------------------------------------

Группы обсуждений можно использовать для создания групп обмена сообщениями, где пользователи могут подписываться и публиковать сообщения.

[](#messaging-menu)Меню сообщений
---------------------------------

Меню сообщений содержит быстрые ссылки для просмотра сообщений.

*   _Сообщения → Входящие_ — показывает все неархивированные сообщения.

*   _Сообщения → Важные_ — отображаются все сообщения, помеченные как важные.

*   _Сообщения → В архиве_ — показывает все заархивированные сообщения.

*   _Сообщения → Группы → Все группы_ — показать все доступные группы.


Помимо этого, когда пользователь подписывается на группу обмена сообщениями, добавляется личное меню _Сообщения → Группы → Имя группы._

[](#email-integration)Интеграция электронной почты
--------------------------------------------------

Функцию обмена сообщениями и потоковой передачи можно настроить для отправки/получения сообщений электронной почты с серверов SMTP/IMAP.

Реализация по умолчанию будет настраивать отправителя почты и получать данные из настроек конфигурации приложения:

    # Quartz Scheduler
    # ~~~~~
    # quartz job scheduler
    
    # Specify whether to enable quartz scheduler
    quartz.enable = true
    
    # SMPT configuration
    # ~~~~~
    # SMTP server configuration
    #mail.smtp.host = smtp.gmail.com
    #mail.smtp.port = 587
    #mail.smtp.channel = starttls
    #mail.smtp.user = user@gmail.com
    #mail.smtp.password = secret
    
    # timeout settings
    #mail.smtp.timeout = 60000
    #mail.smtp.connection-timeout = 60000
    
    # IMAP configuration
    # ~~~~~
    # IMAP server configuration
    # (quartz scheduler should be enabled for fetching stream replies)
    #mail.imap.host = imap.gmail.com
    #mail.imap.port = 993
    #mail.imap.channel = ssl
    #mail.imap.user = user@gmail.com
    #mail.imap.password = secret
    
    # timeout settings
    #mail.imap.timeout = 60000
    #mail.imap.connection-timeout = 60000



Планировщик `quartz`должен быть включен для получения входящих сообщений с настроенного `IMAP`сервера.

Реализация по умолчанию отправляет уведомления по электронной почте подписчикам записи/документа.

Почтовый сервис можно расширить, предоставив альтернативную реализацию API почтового сервиса:

    public interface MailService {
    
      void send(MailMessage message) throws MailException; (1)
    
      void fetch() throws MailException; (2)
    
      Model resolve(String email); (3)
    
      List<InternetAddress> findEmails(String matching, List<String> selected, int maxResults); (4)
    }



**1**

отправить электронное письмо для данного сообщения

**2**

получать сообщения электронной почты

**3**

преобразовать данный адрес электронной почты в связанную с ним запись

**4**

найти адреса электронной почты для соответствующей строки

API предназначен для работы с любыми моделями контактов. Реализация должна обеспечивать возможность составить список адресов электронной почты и сопоставить адрес электронной почты с связанной с ним записью.

Реализация по умолчанию предоставляет адреса электронной почты пользователей и разрешает адреса электронной почты только для записей пользователей.

Реализация по умолчанию `MailServiceImpl`предоставляет некоторые дополнительные переопределяемые методы для настройки реализации по умолчанию.

Например:

    public class MyMailService extends MailServiceImpl {
    
      public Model resolve(String email) {
        // find contact by the email
        // if not found, find another contact like object (depends on your requirements)
        // if not found, find with default implementation
      }
    
      public List<InternetAddress> findEmails(String matching, List<String> selected, int maxResults) {
        // search all contacts matching the given email pattern
        // prepare list of InternetAddress and return
      }
    }



См. javadocs для других переопределяемых методов реализации по умолчанию.