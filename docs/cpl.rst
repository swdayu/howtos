
嵌套字符串
----------

字符串起始括号与结束括号不同，可以让字符串自然嵌套而无需转义。例如 m4 语法： ::

    define(`a', `a')
    ifelse(a, `a', `a==a', a, `b', `a==b', `a==?')

    define(`my_if_else', `ifelse(`$1', `a', `a==a', `$1', `b', `a==b', `a==?')')
    my_if_else(a)   /* a==a */
    my_if_else(b)   /* a==b */

如果使用区别明显的括号比如尖括号，可以更清晰看到括号的嵌套： ::

    define(«my_if_else», «ifelse(«$1», «a», «a==a», «$1», «b», «a==b», «a==?»)»)
