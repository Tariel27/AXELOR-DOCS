Может `<action-method>`использоваться для вызова метода контроллера.

    <action-method name="act.hello">
      <call class="com.axelor.contact.web.HelloController" method="say"/>
    </action-method>



Таблица 1. Атрибуты

Имя

Описание

**имя**

название действия

Для действия метода требуются следующие элементы:

*   `<call>`\- определить вызов

    *   `class`\- полное имя целевого класса

    *   `method`\- имя метода



`action-method`также может быть вызван из любых объектов с произвольными аргументами. Результат метода можно присвоить любому полю.

Предположим, что следующий контроллер:

    import com.axelor.meta.CallMethod;
    
    public class Hello {
    
      @CallMethod
      public String say(String what) {
        return "About: " + what;
      }
    }



Мы можем вызвать этот метод с помощью метода действия следующим образом:

    <action-method name="act.hello">
      <call class="com.axelor.contact.web.HelloController" method="say(fullName)"/>
    </action-method>

