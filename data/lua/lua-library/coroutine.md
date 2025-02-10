
## Coroutine Manipulation

This library comprises the operations to manipulate coroutines, which come inside the table `coroutine`. 
See §2.6 for a general description of coroutines.

协程库定义协程相关的操作，函数都导出在`coroutine`全局表中供使用。
参考2.6部分对协程的描述。

### coroutine.create
```lua
create(f)
-- return a new coroutine with the function `f`
```

Creates a new coroutine, with body `f`. `f` must be a function. 
Returns this new coroutine, an object with type "thread".

创建一个新的协程，`f`必须是一个函数。
返回这个创建的新协程，它的类型是`"thread"`。

### coroutine.isyieldable 
```lua
isyieldable()
```

Returns true when the running coroutine can yield.
A running coroutine is yieldable if it is not the main thread and 
it is not inside a non-yieldable C function.

当运行协程能够Yield则返回`true`。
只有当运行协程不是主线程并且不在不可Yield的C函数内部，则它是可Yield的。

### coroutine.resume 
```lua
resume(co [, val1, ···])
```

Starts or continues the execution of coroutine `co`. 
The first time you resume a coroutine, it starts running its body. 
The values `val1`, ... are passed as the arguments to the body function. 
If the coroutine has yielded, `resume` restarts it; 
the values `val1`, ... are passed as the results from the yield.

开始或继续协程的运行。当第一次`resume`一个协程时，
对应的函数体会开始执行，参数`val1`、...是传给函数的参数。
如果协程是可Yield的，`resume`会重新启动它，？？？。

If the coroutine runs without any errors, 
`resume` returns true plus any values passed to yield (when the coroutine yields) 
or any values returned by the body function (when the coroutine terminates). 
If there is any error, `resume` returns false plus the error message.

### coroutine.running 
```lua
running()
```

Returns the running coroutine plus a boolean, 
`true` when the running coroutine is the main one.

返回正在运行的协程已经一个布尔值表示这个协程不是不主线程。

### coroutine.status 
```lua
status(co)
```

Returns the status of coroutine `co`, as a string: 
"running", if the coroutine is running (that is, it called `status`); 
"suspended", if the coroutine is suspended in a call to `yield`, or if it has not started running yet; 
"normal" if the coroutine is active but not running (that is, it has resumed another coroutine); 
and "dead" if the coroutine has finished its body function, or if it has stopped with an error.

返回协程字符串形式的状态信息：
`"running"`表示协程正在运行中（即调用`status`函数的协程）；
`"suspended"`表示协程已经调用`yield`函数挂起了，或还没有开始执行;
`"normal"`表示协程处于活动状态但没有运行（即它`resume`了另一个协程）;
`"dead"`表示协程已经执行完了，或者因为错误停止了执行。

### coroutine.wrap 
```lua
wrap(f)
```

Creates a new coroutine, with body `f`. `f` must be a function. 
Returns a function that resumes the coroutine each time it is called. 
Any arguments passed to the function behave as the extra arguments to `resume`. 
Returns the same values returned by `resume`, except the first boolean. 
In case of error, propagates the error.

创建一个新的协程，`f`必须是一个函数。。。。

### coroutine.yield 
```lua
yield(···)
```

Suspends the execution of the calling coroutine. 
Any arguments to yield are passed as extra results to `resume`. 

挂起当前调用协程的运行。
任何传入`yield`的参数都会作为`resume`的额外结果。
