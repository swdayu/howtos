Lua

```
基本概念
* LUA 的关键字包括 true false nil and or not function local return if else elseif then end while repeat until for in do break goto
* 另外还应该避免使用以下划线开始后跟一个或多个大写字母的名字，例如 _VERSION
* LUA 使用的操作符号包括　+ - * / % ^ # & ~ | << >> // == ~= <= >= < > = ( ) { } [ ] :: ; : , . .. ...
* 特殊字符包括 "\a"（bell）、"\b"（backspace）、"\f"（form feed）、"\n"（newline）、"\r"（carriage return）
* "\t"（horizontal tab）、"\v"（vertical tab）、"\\"（backslash）、"\""（double quote）、"\'"（single quote）
* "\z" 可用于忽略后续包括换行符在内的空白字符，它在书写无换行的长字符串时特别有用；另外反斜杠跟随换行符可用于续行，其本身在字符串中表示一个换行
* "\xXX" 插入一个十六进制字节字符；另外可以使用 "\u{uuuu...}" 来插入一个 UTF8　字符，其中 uuuu... 是该字符的 UNICODE 代码点
* LUA 的短字符串包含在双引号或单引号内，而长字符串的表示形式为 [[string]]、[=[string]=]、[==[string]==]、...
* 长字符串不解析任何转义字符，可以跨多行书写，其中的换行、回车、换行加回车、回车加换行被转换成换行，但如果第一个字符就是换行的话会被忽略
* LUA 的短注释以 -- 开始直到行结尾，长注释的形式为 --[[comment]]、--[=[comment]=]、--[==[comment]==]、...
* Lua 基本类型包括 nil，boolean，number，string，function，userdata，thread，table，没有赋初始值的变量的值为 nil
* 变量类型可以通过 type(var) 判断，它返回对应类型名称的字符串；所有类型值只有 nil 和 false 为假，其他值都为真
* nil、boolean、number、string、light userdata 是值类型，function、full userdata、thread、table 是引用类型
* 自动类型转换：位操作会将浮点转换成整数，幂操作和浮点除法会将整数转换成浮点，其他算术运算如果包含浮点和整数会将整数转换成浮点
* 字符串连接操作符可以连接数字和字符串，如果需要数字的地方传递了字符串，Lua 也会尝试将字符串转换成数字
* 整数自动转换成浮点会使用最接近的浮点表示，当浮点自动转换成整数时，如果浮点整数部分在整数表示范围内则成功，否则失败
* 当字符串自动转换成数字时，首先根据实际的字符串转换成整数或浮点（字符串前后可以有空格），然后根据上下文需要可能继续转换成整数
* 关系操作符包括：等于（==），不等于（~=），小于（<），小于等于（<=），大于（>），大于等于（>=）
* 相等操作先比较两个操作数的类型，如果类型不同则不相等，否则值类型进行值比较，引用类型比较引用（table 和 userdata 可通过元函数改变相等操作的行为)
* 大小关系运算可以比较两个数字或两个字符串，其他类型会尝试调用元函数 lt 或 le；根据 IEEE 754标准，特殊值 NaN 不大于、不小于、不等于任何值（包括它自身）
* load 函数加载 LUA 代码时会在全局环境中编译对应的代码块，这是它与真实函数调用的区别，例如：
* i = 32; local i = 0; f = load("i = i + 1; print(i)"); g = function() i = i + 1; print(i) end f() --[[33]] g() --[[1]]
* LUA 通过 error 抛出异常，通过 pcall 调用函数来捕获函数中的异常，当异常发生时栈会展开异常沿栈向上抛出直到 pcall 捕获
* 当 pcall 捕获异常返回错误时，栈现场已经破坏了，如果想获取异常时的栈信息需要使用 xpcall，它提供额外回调函数可在异常发生时使用debug库保存栈信息
模块
* 全局函数 require(modname) 用于加载模块、执行模块代码、获取模块返回值，并在加载模块之前根据名称查找模块，一般查找流程如下：
* 首先看模块是否已经加载（通过查看 package.loaded），是则直接返回其中的值，否则使用 package.searches 中保存的查询函数进行查询
* 通过修改 packages.searches 可以改变模块的查找方式，它默认有4个查询函数，require 会使用模块名依次调用这些函数查询
* 第1个函数调用 package.preload[modname] 加载模块（如果存在），第2个函数查找 package.path 中的 Lua 模块，第3个函数查找 package.cpath 中的 C 模块
* 第4个函数会在 package.cpath 中查找模块的 root 名称对应的模块，例如 a.b.c （在第3个函数失败后）会查找模块 a，再执行其中的加载函数 luaopen_a_b_c，该功能允许多个 C 模块打包在一个库中
* Lua 模块的加载是直接执行文件中的代码，而 C 模块会先进行动态链接，然后调用其中的加载函数（luaopen_xxx），例如模块 a.b.c-v2.1 的加载函数是 luaopen_a_b_c（不包含后缀）
* 文件或动态库的查找是通过 package.searchpath(name, path[, sep[, rep]]) 完成的，它在指定路径中查找对应名称的文件，名称中的分割符 sep（默认是点号）首先会替换成 rep（默认是斜杠）
* 例如在 package.path 中查找时如果路径是 ./?.lua;/usr/local/?/init.lua，则查找 a.b.c 会依次尝试 ./a/b/c.lua;/usr/local/a/b/c/init.lua
* 而在 package.cpath 中查找时如果路径是 ./?.so;./?.dll;/usr/local/?/init.so，则查找 a.b.c 会依次尝试 ./a/b/c.so;./a/b/c.dll;/usr/local/a/b/c/init.so
执行环境
* Lua 执行环境涉及　_ENV 和　_G 两个变量，_ENV　表示当前执行环境，而 _G 表示全局执行环境，全局环境是唯一的，它保存了 Lua 定义的所有全局符号（例如 print）
* 实际上，名称 _G 只是全局环境（一个 table）中保存的一个变量，这个变量引用全局环境本身，当前环境 _ENV 一般情况下指向全局环境
* 没有使用 local 定义的且不是函数参数的变量是全局变量，全局变量会保存在当前环境 _ENV 中，如果 _ENV 指向全局环境，实际上会保存在全局环境中，如果不指向则不会
* 全局变量可以通过 _ENV.name、_ENV[expr]、_G.name、_G[expr] 显式访问，实际上 Lua 会将自由变量如 x 转换为 _ENV.x
* _ENV 是一个局部变量，Lua 在编译代码块（chunk，Lua 的编译单元）时会首先定义这个变量，例如对代码 local z = 10; x = y + z 的编译结果为：
* local _ENV = <the global environment>; return function(...) local z = 10; _ENV.x = _ENV.y + z end
* 由于全局变量的定义不需要显式声明，在代码中很容易出错（例如将局部变量的名字不小心写错），可以通过元表对全局变量的使用做一些限制
* _ENV 是一个普通的变量，遵循 Lua 的作用域规则，也可以随意修改 _ENV，对 _ENV 的引用总是引用当前作用域中可见的 _ENV
* 但修改 _ENV 时需要注意它指向的全局环境中保存有 Lua 的全局符号，为 _ENV 赋新值会导致这些符号（如 print）不可用，但也可实现对全局符号的访问限制
* 例如：local print = print; _ENV = nil; print(13); print(math.sin(13)) -- error, math is not defined
* 使用 _ENV 或 _G 可访问到被局部变量覆盖的全局变量：a = 13; local a = 12; print(a); print(_ENV.a); print(_G.a)
* 修改 _ENV 改变当前环境，例如赋予 _ENV 一个新的 table，代码块中的全局变量将会保存到这个新的环境中，而不会污染全局环境
* 但为了访问 Lua 的全局符号，可先将全局环境或部分用到的全局符号保存到 table 中，例如：_ENV = {g = _G}; a = 1; g.print(a)
* load() 和 loadfile() 在一般情况下将 _ENV 初始化为 _G，但是它们提供了额外的参数用于给 _ENV 赋值，例如：
* width = 200; height = 300; --[[ file 'config.lua' ]] local env = {}; loadfile("config.lua", "t", env)()
* 此时外部文件中的代码就像在沙盒（env）中运行一样不会影响代码的其他部分，也会隔离代码错误或恶意代码的侵害
* 另一种情况是让同一段代码执行多次，每次在不同的环境中运行，一种方法是使用 debug.setupvalue()：local f = load("b = 10; return a");
* local env = {a = 20}; debug.setupvalue(f, 1, env); --[[ the chunk have only 1 upvalue]] print(f(), env.b); -- 20  10
* 该方法唯一的缺点是使用了 debug 库，该库会打破 Lua 的一些语言规则，例如违反 Lua 变量的可见性规则，这个规则保证局部变量仅在其作用域中可见
* 另一方法是添加额外代码将参数赋给 _ENV，例如：local f = loadEx("_ENV = ...", io.lines(filename, "*L")); f(env1); f(env2)
* Lua 解释器可以执行一段代码 lua -e "code"，也可以执行保存在文件中的代码 lua file.lua arg
协程和线程
* 协程的创建仅需传入协程的主函数 local co = coroutine.create(luafunc)
* 协程有四种不同的状态：suspended，running，normal，dead
* 新创建的协程初始状态为suspended，协程状态可以通过函数coroutine.status(co)获取
* 调用函数coroutine.resume(co)可以恢复suspended协程的执行，使其进入running状态，只有suspended状态的协程才能resume
* 恢复运行的协程要么从主函数返回，要么再次suspended，从主函数返回的协程会进入dead状态，表示协程完全运行完了不能再次resume
* resume函数像pcall函数一样在保护模式执行，不会抛出错误只会返回错误码
* 如果运行中的协程resume另外一个协程运行，它自己的状态将变成normal，normal状态也是不能resume的，因为实际上它正在运行中
* 传给resume的参数会被主函数当做参数（第一次resume时），或被yield接收作为yield函数的返回值
* resume函数的第一个返回是表示是否调用成功的状态值，之后的返回值从主函数或yield函数接收而来
* status, value, value2, ... = coroutine.resume(co)
* 当resume的协程从主函数返回时，主函数的返回值将作为resume的返回值返回
* 当resume的协程suspended而返回时，传入yield的参数将作为resume的返回值返回
* 生产者消费者模型，下面是一个消费者驱动的例子（调用消费者函数驱动生产者生产产品）
* local producer = coroutine.create(function()
*   while true do
*     local x = io.read() -- produce a new value
*     coroutine.yield(x)  -- send it to customer
*   end
* end)
* local consumer = function(prod)
*   while true do
*     local _, x = coroutine.resume(prod) -- receive value from producer
*     io.write(x, "\n")                   -- consume it
*   end
* end
* 不仅如此，在生产者和消费者之间还能实现一个产品过滤层，只将符合条件的产品才提交给消费者
* local prodfilter = function(prod)
*   return coroutine.create(function()
*     while true do
*       local _, x = coroutine.resume(prod) -- receive value from producer
*       if x fulfil the condition then      -- but only the value that meet the condition
*         coroutine.yield(x)                -- is send to customer
*       end
*     end
*   end)
* end
* consumer(producer)               -- get all the products
* consumer(prodfilter(producer))   -- get products only meet the condition
* 协程有4种状态：suspended，running，normal，和 dead；可以通过 coroutine.status(co) 获取协程状态；协程的魔法来自于能在函数中调用 yield
* 例如 local co = coroutine.create(function() for i = 1, 2 do print(i); coroutine.yield() end end)
* coroutine.resume(co) --[[1]] coroutine.resume(co) --[[2]] coroutine.resume(co) -- print nothing
* 注意 resume 运行在保护模式中（像 pcall），协程中的错误不会被抛出，而是以 resume 的返回值返回
* 当协程去 resume 另一个协程时，另一协程会进入 running 状态，而当前协程状态会变成 normal，当 resume 返回后当前协程再次变成 running
* Lua 协程的一个有用的特性是 resume-yield 可以相互传递数据，例如 local co = coroutine.create(function(a,b) --[[see below]] end)
* print(a,b); a, b = coroutine.yield(a, a+b); print(a,b); return 0, 1
* 第一次 resume 例如 local a, b = coroutine.resume(co, 1, 2) 会打印 1 和 2，并且 resume 的返回值是 1 和 3
* 第二次 resume 例如 local a, b = coroutine.resume(co, "a", "b") 会打印 "a" 和 "b"，并且 resume 的返回值是 0 和 1
* 协程的应用场景一是生产者-消费者模式：function producer() while true do send(io.read()) end end
* function consumer() while true do io.write(receive(), "\n") end end
* producer = coroutine.create(producer); function send(x) coroutine.yield(x) end
* function receive() local status, value = coroutine.resume(producer); return value end
* 协程应用场景二是用于迭代遍历：function find(a) for i = 1, 10 do if a[i] > 0 then coroutine.yield(a[i]) end end
* function iter(a) return function() local _, res = resume(create(function() find(a) end)); return res end
* 然后可以在 for 循环中使用上面的遍历函数 iter 进行遍历，例如：for v in iter(a) do print(v) end
构建并发模型
* 任务（task）由一段代码（对应一个 coroutine）和一个句柄标识，一个任务可以给任何任务发送消息，包括其他进程中的任务
* 一个任务应该编写得与线程无关（可以由任何线程执行），一个任务需要处理的工作包括：
* 1. 执行自己的核心业务，当核心业务等待时检查自己的消息队列处理消息（计时器超时也会发送消息到队列中）
* 2. 如果核心业务在等待且所有的消息已处理完，则挂起当前执行线程（为防止其他任务饥饿，可以考虑一些策略在某些情况下提前挂起）
* 有一个特殊的任务是 main task，它负责检查全局消息队列中是否有消息，有则分配线程执行对应任务去处理消息（在该线程上运行的任务会执行上面的步骤1和2）
* 主任务还需要监控计时器超时，如果超时则发送一条消息到对应任务的消息队列；如果下一超时时间还较长（或都超时了）且消息处理完毕则等待操作系统事件一段时间（如socket)
* 如果所有线程都处于忙状态且还有对应的工作需要处理，且该工作对应的任务没有在任何线程内运行，主任务可以帮助先处理该工作，另外主任务还需要负责 log 输出
* 属于一个任务的两项工作不能同时在不同的线程中运行，但是多个任务可以在同一个线程中运行（因为一个任务对应一个协程）
* 操作系统的线程资源是有限的，而客服的请求相对与线程数量来说可以说是无限的
* 因此一个线程必须同时处理多项客户请求任务，任务的分配会根据当时各个工作线程的负载情况进行分配
* 一个任务分配给特定的线程后，一般自始至终都在这个线程中完成，不再线程之间来回切换
* 线程只是基础设施，而任务是各式各样的，不同的任务需要处理的事务可能大不相同
* 为了简化基础设施处理流程，也为了增强基础设施的适用性，可以将任务处理事务的流程标准化
* 基础设施在接收到任务时，只需按照该任务指定的事务流程处理即可
---
* LUA 协程是一种非抢占协作线程，每个协程都拥有自己独立的栈内存，LUA 协程与操作系统线程是两个不同的概念
* 操作系统级线程是抢占式的（优先级高的抢占），多个线程共享当前进程内存，需要同步机制解决内存访问不一致问题
* 在 LUA 的 C API 层面可以认为协程相当于一个栈，它保存着协程挂起的调用信息以及每个调用的参数和局部变量信息，即协程栈保存了其继续执行需要的所有信息
* LUA 的 C API 都需要在一个特定的栈来进行操作，它会使用哪个协程的栈呢？这里的魔法是每个 C API 函数的第一个参数都是 lua_State 指针
* lua_State 表示的不仅仅是 LUA 状态，还表示一个协程，在 LUA 程序开始执行时会创建一个 LUA 状态和主协程
* 对于不关心多协程的程序，其所有代码都在主协程中运行，要创建多个协程需要使用函数 lua_newthread，例如 lua_State* L1 = lua_newthread(L)
* 此时我们拥有了两个协程 L1 和 L，每个协程拥有自己独立的协程栈，但 LUA 状态是共享的，都指向程序开始运行时创建的 LUA 状态
* 新协程 L1 创建后其栈中没有保存任何元素，而协程 L 栈顶保存了一个指向 L1 的引用，这是为了防止 L1 被回收
* 在 C 中使用新协程时，必须注意确保将新协程的引用保存到了已保存的协程的栈中、LUA 注册表中、或 LUA 变量中，否则新线程有被回收的危险
* 注意保存到 C 变量中没有作用，另外当 LUA 对象被置为可回收后对任何 LUA API 的调用都可能引发回收动作，即使通过这个协程进行调用
* 例如 lua_State* L1 = lua_newthread(L); lua_pop(L, 1); /* L1 now is garbage for Lua */
* 上面调用 lua_pop 后保存在 LUA 中该协程的唯一引用也删除了，该协程变成可回收垃圾，注意 LUA 不可能跟踪到 C 语言变量 L1 对该对象的引用
* 之后使用这个新协程都是错误的，例如 lua_pushstring(L1, "hello"); /* 可能导致 L1 被回收，然后程序崩溃 */
* 当拥有新协程后，就可以像主协程那样来使用，例如在它的栈中添加移除元素，通过它调用 LUA 函数等，但这都没必要创建新协程
* 创建新协程的意义是可以多个协程之间进行协作，开启协程的运行需要调用 int lua_resume(lua_State* L, lua_State* from, int narg)
* 首先需要将一个函数入栈，然后是函数的参数（narg是参数个数），最后调用 lua_resume，其中 L 是启动的新协程，from 是当前调用 lua_resume 的协程
* lua_resume 的调用非常类似 lua_pcall，只有3点不同，一是它没有参数指定想要的返回结果个数，它会返回所有结果
* 二是它没有参数来提供错误消息的处理，一个错误不会导致栈展开（即不会沿栈向上抛出异常），因此在错误发生后有机会检查错误发生时的栈现场
* 三是如果调用的函数被挂起（yield），lua_resume 会返回 LUA_YIELD，后面可以再次调用 lua_resume 从该挂起点继续执行该函数
* 当函数挂起返回时，协程栈中保存的返回值是 yield 函数中传入的所有参数，如果要将协程中的参数移到另一个协程中，可以使用函数 lua_xmove
* 再次调用 lua_resume 会继续执行挂起协程，栈中的参数将作为 yield 函数的返回结果，如果不对栈做操作 yield 函数得到的返回结果将是自己的参数
* 可以直接调用 LUA 函数作为协程函数，该 LUA 函数可以在内部挂起，或在其调用的函数中挂起，另外 C 函数也可以作为协程函数执行
* 当 C 函数作为协程函数执行时，C 函数可以调用 LUA 函数，使用 continuations 机制允许在这些 LUA 函数中进行挂起
* 一个 C 函数也可以挂起，但需要提供一个 continuation 函数在 lua_resume 中使用，要使 C 函数挂起时需要调用以下函数：
* int lua_yieldk(lua_State* L, int nresults, int context, lua_CFunction k);
* 而且必须总是在 return 语句中调用该函数，例如 int mycfunc(lua_State* L) { /* ... */ return lua_yieldk(L, nresults, ctx, k); }
* 其中 nresults 是当前栈中指定的作为 yield 函数的参数个数，这些参数会在协程挂起后作为 resume 函数的返回结果
* 而 k 是 continuation 函数，context 会作为参数传给函数 k，当协程挂起后再次启动时会调用函数 k 继续执行其中的代码
* 因此初始协程 C 函数不能做更多的事情，当它被挂起后，之后的代码必须放在 continuation 函数 k 中实现，因为再次启动协程时只会调用函数 k
* 下面是一个使用 C 函数作为协程主体的例子，它读取数据并在数据不可用时挂起：
* int prim_read(lua_State* L) { return readK(L, 0, 0); }
* int readK(lua_State* L, int status, lua_KContext ctx) { (void)status; (void)ctx; /* see below */ }
* if (something_to_read()) { lua_pushstring(L, read_some_data()); return i; } return lua_yieldk(L, 0, 0, &readK);
* 当 C 函数挂起后再次执行时没有事情要做了，可以不指定 k 函数来调用 lua_yieldk 或使用 lua_yield(L, nres)，当下次 resume 时会从函数返回 
* 在相同的 lua_State 中调用 lua_newthread 产生的协程都共享同一个 LUA 状态，只是每个协程会拥有自己独立的栈
* 而调用 luaL_newstate 或 lua_newstate 会创建不同的 LUA 状态，新的 LUA 状态会是完全独立的不共享任何数据
* 这意味着不同的 LUA 状态不能直接进行通信，必须借助 C 代码，也意味着只有那些能用 C 表示的数据才能直接传递（如字符串和数字），其他数据如表必须先序列化
* 在提供多线程的系统中，一个有趣的设计是为每个线程创建一个独立的 LUA 状态，这样每个线程相互独立且可拥有多个协程
加载运行LUA代码
* the unit of compilation of lua is called a chunk, syntactically, a chunk is simply a block.
* lua handles a chunk as the body of an anonymous function with a variable number of arguments
* as such, chunks can define local variables, receive arguments, and return values
* moreover, such anonymous function is compiled as in the scope of an external local variable called _ENV
* the resulting function always has _ENV as its only upvalue, even if it does not use that variable
* a chunk can be stored in a file or in a string inside the host program
* to execute a chunk, lua first loads it, precompiling the chunk's code into instructions for a virtual machine
* and then lua executes the compiled code with an interpreter for the virtual machine
* chunks can also be precompiled into binary form; see program luac and function string.dump for details
* programs in source and compiled forms are interchangeable, lua automatically detects the file type and acts accordingly
---
int lua_load(lua_State* L, lua_Reader reader, void* data, const char* chunkname, const char* mode);
* loads a lua chunk without running it, if there are no errors, lua_load pushes the compiled chunk as
* a lua function on top of the stack. otherwise, it pushes an error message.
* the return value: LUA_OK - no errors, LUA_ERRSYNTAX, LUA_ERRMEM, LUA_ERRGCMM - error while running a __gc metamethod
* the lua_load function uses a user-supplied reader function to read the chunk,
* the data argument is an opaque value passed to the reader function
* the chunkname argument gives a name to the chunk, which is used for error messages and in debug information
* lua_load automatically detects whether the chunk is text or binary and loads it accordingly
* the string mode works as in function load, with the addition that a NULL value is equivalent to the string "bt"
* lua_load uses the stack internally, so the reader function must always leave the stack unmodified when returning
* if the resulting function has upvalues, its first upvalue is set to the value of the global environment LUA_RIDX_GLOBALS
* when loading main chunks, this upvalue will be the _ENV variable. other upvalues are initialized with nil
---
typedef const char* (*lua_Reader)(lua_State* L, void* data, size_t* size);
* the reader function used by lua_load, every time it needs another piece of the chunk,
* lua_load calls the reader, passing along its data parameter
* the reader must return a pointer to a block of memory with a new piece of the chunk and set size to the block size
* the block must exist until the reader function is called again
* to signal the end of the chunk, the reader must return NULL or set size to zero
* the reader function may return pieces of any size greater than zero
---
int luaL_loadbuffer(lua_State* L, const char* buff, size_t sz, const char* name);
* equivalent to luaL_loadbufferx with mode equal to NULL
---
int luaL_loadbufferx(lua_State* L, const char* buff, size_t sz, const char* name, const char* mode);
* loads a buffer as a lua chunk, this function uses lua_load to load the chunk in the buffer pointed to by buff with the size
* this function returns the same results as lua_load. the chunk name is used for debug formation and error message.
* the string mode works as in function lua_load.
---
int luaL_loadfile(lua_State* L, const char* filename);
* equivalent to luaL_loadfilex with mode equal to NULL
int luaL_loadfilex(lua_State* L, const char* filename, const char* mode);
* loads a file as a lua chunk, this function uses lua_load to load the chunk in the file named filename
* if filename is NULL, then it loads from the standard input. the first line in the file is ignored if it starts with a #.
* the string mode works as in function lua_load. this function returns the same results as lua_load,
* but it has an extra error code LUA_ERRFILE for file-related errors
* as lua_load, this function only loads the chunk; it does not run it
---
int luaL_loadstring(lua_State* L, const char* s);
* loads a string as a lua chunk, this function uses lua_load to load the chunk in the zero-terminated string.
* this function returns the same results as lua_load, as lua_load, it only loads the chunk, doesn't run it.
---
int lua_dump(lua_State* L, lua_Writer writer, void* data, int strip);  # dump function to binary chunk
* dumps a function as a binary chunk. receives a lua function on the top of the stack and produces a binary chunk that,
* if loaded again, results in a function equivalent to the one dumped. as it produces parts of the chunk,
* lua_dump calls function writer with the given data to write them.
* if strip is true, the binary representation may not include all debug infromation about the function, to save space
* the value returned is the error code returned by the last call to the writer; 0 means no errors.
* this function does not pop the lua function from the stack.
---
string.dump(function [, strip])
* returns a string containing a binary representation (a binary chunk) of the given function
* so that a later load on this string returns a copy of the function (but with new upvalues)
* if strip is a true value, the binary representation may not include all debug information about the function to save space
* functions with upvalues have only their number of upvalues saved
* when (re)loaded, those upvalues receive fresh instances containing nil
* you can use the debug library to serialize and reload the upvalues of a function in a way adequate to your needs 
---
typedef int (*lua_Writer)(lua_State* L, const void* p, size_t sz, void* ud);
* the type of writer function used by lua_dump. every time it produces another piece of chunk,
* lua_dump calls the writer, passing along the buffer to be written, its size, and the data parameter supplied to lua_dump
* the writer returns an error code; 0 means no errors; any other value means an error and stops lua_dump from calling the writer again
---
int luaL_dostring(lua_String* L, const char* str);
* loads and runs the given string. it is defined as the following macro:
* (luaL_loadstring(L, str) || lua_pcall(L, 0, LUA_MULTRET, 0))
* it returns false if there are no errors or true in case of errors
---
int luaL_dofile(lua_State* L, const char* filename);
* loads and runs the given file, it is defined as the following macro:
* (luaL_loadfile(L, filename) || lua_pcall(L, 0, LUA_MULTRET, 0))
* it returns false if there are no errors or true in case of errors.
---
void lua_call(lua_State* L, int nargs, int nresults);
* calls a function. to call a function you must use the following protocol: first, the function to be called
* is pushed onto the stack; then, the arguments to the function are pushed in direct order; that is, the first
* argument is pushed first. finally you call lua_call; nargs is the number of arguments that you pushed onto the stack
* all arguments and function value are poped from the stack when the function is called
* the function results are pushed onto the stack when the function returns
* the number of results is adjusted to nresults, unless nresults is LUA_MULTRET
* in this case, all results from the function are pushed; lua takes care that the returned values fit into the stack space
* but it does not ensure any extra space in the stack
* the function results are pushed onto the stack in direct order (the first result is pushed first)
* so that after the call the last result is on the top of the stack
* any error inside the called function is propagated upwards (with a longjmp)
---
int lua_pcall(lua_State* L, int nargs, int nresults, int msgh);
* calls a function in protected mode. both nargs and nresults have the same meaning as in lua_call.
* if there are no errors during the call, lua_pcall behaves exactly like lua_call
* however, if ther is any error, lua_pcall catches it, pushes a single value on the stack (the error object),
* and returns an error code. like lua_call, lua_pcall always removes the function and its arguments form the stack.
* if msgh is 0, then the error object returned on the stack is exactly the original error object
* otherwise, msgh is the stack index of a message handler (this index cannot be a pseudo-index)
* in case of runtime errors, this function will be called with the error object and
* its return value will be the object returned on the stack by lua_pcall
* typically, the message handler is used to add more debug information to the error object, such as a stack traceback
* such information cannot be gathered after the return of lua_pcall, since by then the stack has unwound
* the lua_pcall function returns: LUA_OK(0) - success, LUA_ERRRUN, LUA_ERRMEM, LUA_ERRERR - error whild running the msgh, LUA_ERRGCMM
使C代码能够在LUA中调用
void lua_register(lua_State* L, const char* name, lua_CFunction f);
* sets the C function as the new value of global name. it is defined as a macro:
* #define lua_register(L, n, f) (lua_pushcfunction(L, f), lua_setglobal(L, n))
---
const char* lua_pushstring(lua_State* L, const char* s);
const char* lua_pushliteral(lua_State* L, const char* s);
* pushes the zero-terminated string onto the stack
* lua makes (or reuses) an internal of the given string
* so the memory at s can be freed or reused immediately after the function returns
* returns a pointer to the internal copy of the string
* if s is NULL, pushes nil and returns NULL
---
const char* lua_pushlstring(lua_State* L, const char* s, size_t len);
* pushes the string onto the stack
* lua makes (or reuses) an internal copy of the given string,
* so the memory at s can be freed or reused immediately after the function returns
* the string can contain any binary data, including embedded zeros
* returns a pointer to the internal copy of the string
---
const char* lua_pushfstring(lua_State* L, const char* fmt, ...);
const char* lua_pushvfstring(lua_State* L, const char* fmt, va_list argp);
* pushes onto the stack a formatted string and returns a pointer to this string
* it is similar to the ISO C function sprintf, but has some important differences:
* you do not have to allocate space for the result, the result is a lua string and lua takes core of memory allocation
* the conversion specifiers are quite restricted. there are no flags, widths, or precisions
* the conversion specifiers can only be '%%', '%s', '%f' lua_Number, '%I' lua_Integer, '%p', '%d', '%c', '%U' long int as a UTF-8 byte squence
* unlike other push functions, this function checks for the stack space it needs, including the slot for its result
---
void lua_setglobal(lua_State* L, const char* name);
* pops a value from the stack and sets it as the new value of global name
```

LUA字符串
```
LUA初始化的字符串哈希表的大小为MINSTRTABSIZE即128
LUA字符串哈希表大小调整规则是元素个数大于等于哈希表大小时将哈希表扩大1倍（一个例外是哈希表大小已经大于等于MAX_INT/2了）
而当元素个数小于哈希表大小的1/4时，将哈希表缩小到原来的1/2
---
struct ccstringtable {
  struct ccsmplnode* slot;
  umedit_int nslot; /* prime number */
  umedit_int nelem; /* number of elements */
};
#define ccstring_newliteral(s) (ccstring_newlstr("" s, (sizeof(s)/sizeof(char))-1)
struct ccstring {
  union {
    struct ccstring* hnext; /* linked list for shrot string hash table */
    sright_int lnglen; /* long string length */
    struct cceight align; /* align for 8-byte boundary */
  } u;
  umedit_int hash;
  nauty_byte type;
  nauty_byte extra; /* long string is hashed or not, this string is reserved word or not for short string */
  nauty_byte shrlen; /* short string length */
　　nauty_char s[1]; /* the string started here */
};
---

LUA字符串哈希值的计算方法使用JSHash函数，并使用字符串长度l异或G(L)->seed作为哈希的初始值
并且不是字符串中的每个字符都用来计算哈希值，而是有一个step间隔，每隔多少个字符才取一个字符来计算哈希值
下面字符间隔的计算相当于（字符串长度/32）＋１，例如长度小于32将使用1个字符计算哈希值
长度在范围[32,64)内将将使用2个字符计算哈希值，长度在[64,96)内将使用3个字符计算哈希值，依次类推
如果长度时能是32位的整数的化，最多会使用134217727（1亿3）个字符来计算哈希值
旧版本没有使用G(L)->seed，存在Hash DoS，见http://lua-users.org/lists/lua-l/2012-01/msg00497.html
新版的G(L)->seed即保存在global_State中，这个种子的构造方法可查看函数makeseed()
---
unsigned int luaS_hash (const char *str, size_t l, unsigned int seed) {
  unsigned int h = seed ^ cast(unsigned int, l); /* 使用长度异或seed作为hash初始值 */
  size_t step = (l >> LUAI_HASHLIMIT) + 1; /* 计算取字符的间隔，LUAI_HASHLIMIT的值为5 */
  for (; l >= step; l -= step)
    h ^= ((h<<5) + (h>>2) + cast_byte(str[l - 1]));
  return h;
}
unsigned int JSHash(char *str) {
    unsigned int hash = 1315423911;
    while (*str) {
        hash ^= ((hash << 5) + (*str++) + (hash >> 2));
    }
    return (hash & 0x7FFFFFFF);
}
unsigned int BKDRHash(char *str) {
    unsigned int seed = 131; // 31 131 1313 13131 131313 etc..
    unsigned int hash = 0;
    while (*str) {
        hash = hash * seed + (*str++);
    }
    return (hash & 0x7FFFFFFF);
}
---

哈希种子的初始化方法利用了各种内存地址的随机性以及用户可配置的一个随机量来初始化这个种子
---
#if !defined(luai_makeseed)
#include <time.h>
#define luai_makeseed()　cast(unsigned int, time(NULL))
#endif
#define addbuff(b,p,e) { size_t t = cast(size_t, e); memcpy(b + p, &t, sizeof(t)); p += sizeof(t); }
unsigned int makeseed (lua_State *L) {
  char buff[4 * sizeof(size_t)];
  unsigned int h = luai_makeseed();
  int p = 0;　/* 字符串的长度 */
  addbuff(buff, p, L);  /* heap variable */
  addbuff(buff, p, &h);  /* local variable */
  addbuff(buff, p, luaO_nilobject);  /* global variable */
  addbuff(buff, p, &lua_newstate);  /* public function */
  lua_assert(p == sizeof(buff));
  return luaS_hash(buff, p, h);
}
---

短字符串是否相等只需判断类型是否是短字符串并且指针指向的是否是同一个字符串对象
而长字符串的比较，如果指向同一个字符串对象当然也想等，如果不是则需要长度相同且内容一样
---
int luaS_eqlngstr(TString* a, TString* b) {
  size_t len = a->u.lnglen;
  lua_assert(a->tt == LUA_TLNGSTR && b->tt == LUA_TLNGSTR);
  return (a == b) ||  /* same instance or... */
    ((len == b->u.lnglen) &&  /* equal length and ... */
     (memcmp(getstr(a), getstr(b), len) == 0));  /* equal contents */
}
---

创建一个以str为内容的字符串，如果这个字符串在cached中直接返回
否则调用luaS_newlstr真正去生成一个新字符串，并将新生成的字符串cache到对应slot的第一个字符串
字符串缓存以字符串的首地址为键，哈希值的计算如 str%53
---
TString* strcache[STRCACHE_N][STRCACHE_M];  /* cache for strings in API 53*2 */
TString *luaS_new (lua_State *L, const char *str) {
  unsigned int i = point2uint(str) % STRCACHE_N;  /* hash */
  int j;
  TString **p = G(L)->strcache[i];
  for (j = 0; j < STRCACHE_M; j++) {
    if (strcmp(str, getstr(p[j])) == 0)  /* hit? */
      return p[j];  /* that is it */
  }
  /* normal route */
  for (j = STRCACHE_M - 1; j > 0; j--)
    p[j] = p[j - 1];  /* move out last element */
  /* new element is first in the list */
  p[0] = luaS_newlstr(L, str, strlen(str));
  return p[0];
}
---

如果字符串的长度不超过40，则创建一个短字符串，创建短字符串时首先看哈希表中有没有这个字符串
如果有直接返回这个字符串，否则调用createstrobj实际创建一个字符串并加它加到哈希表中
哈希表的大小总是2的倍数，即(size&(size-1))一定等于0，如果确定对应哈希值的字符串该存储在哈希表的那个位置呢？
LUA的计算方法是哈希值与上(size-1)，即 (h & (size-1)),它没有使用除以一个素数取余数的方法
例如size为128，二进制数为1000,0000，则(size-1)的值为0111,1111，与上哈希值h即得到哈希值的最低7位来作为存储位置
在大多数应用场合,长字符串都是文本处理的对象,不会做比较操作，这是将字符串分为短字符串和长字符串的一个原因
注意，LUA字符串一旦创建以后，是不可修改的
---
static TString *internshrstr (lua_State *L, const char *str, size_t l) {
  TString *ts;
  global_State *g = G(L);
　　/* 计算哈希值，并找到对应哈希表的slot，然后查看这个slot中有没有这个字符串，如果有直接返回该字符串 */
  unsigned int h = luaS_hash(str, l, g->seed);
  TString **list = &g->strt.hash[lmod(h, g->strt.size)];
  lua_assert(str != NULL);  /* otherwise 'memcmp'/'memcpy' are undefined */
  for (ts = *list; ts != NULL; ts = ts->u.hnext) {
    if (l == ts->shrlen &&
        (memcmp(str, getstr(ts), l * sizeof(char)) == 0)) {
      /* found! */
      if (isdead(g, ts))  /* dead (but not collected yet)? */
        changewhite(ts);  /* resurrect it */
      return ts;
    }
  }
　　/* 实际存储的元素大于等于表的大小则先扩展表大小（注意标的大小不能找过MAX_INT，因此表大小已达到MAX_INT时不能再扩张）*/
  if (g->strt.nuse >= g->strt.size && g->strt.size <= MAX_INT/2) {
    luaS_resize(L, g->strt.size * 2);
    list = &g->strt.hash[lmod(h, g->strt.size)];  /* recompute with new size */
  }
  /* 表中没有该字符串，新创建一个字符串，并将字符串插入哈希表 */
  ts = createstrobj(L, l, LUA_TSHRSTR, h);
  memcpy(getstr(ts), str, l * sizeof(char));
  ts->shrlen = cast_byte(l);
  ts->u.hnext = *list;
  *list = ts;
  g->strt.nuse++;
  return ts;
}
---

否则超过40就创建一个长字符串，然而长度也不能过分长，如果超过一定限度会报错
创建长字符串时，先调用luaS_createlngstrobj分配空间然后将字符串拷贝到空间中
长字符串不会放进哈希表，是一个普通的可垃圾回收的LUA对象
---
TString *ts;
if (l >= (MAX_SIZE - sizeof(TString))/sizeof(char))
  luaM_toobig(L);
ts = luaS_createlngstrobj(L, l);
memcpy(getstr(ts), str, l * sizeof(char));
return ts;
---

真正用于创建字符串对象的函数是createstrobj，l是字符串的长度，tag是表示字符串的类型
如果是短字符串，tag为LUA_TSHRSTR，哈希值h为已计算出的短字符串的哈希值
如果是长字符串，tag是LUA_TLNGSTR，哈希值存储用于计算哈希值的种子G(L)->seed
---
static TString *createstrobj (lua_State *L, size_t l, int tag, unsigned int h) {
  TString *ts;
  GCObject *o;
  size_t totalsize;  /* total size of TString object */
  totalsize = sizelstring(l);
  o = luaC_newobj(L, tag, totalsize);
  ts = gco2ts(o);
  ts->hash = h;
  ts->extra = 0;
  getstr(ts)[l] = '\0';  /* ending 0 */
  return ts;
}
---
```

网络套接字
```
* socket (socket.lua) => socketdriver (lua-socket.c) => skynet_socket.c => skynet_server.c
* httplisten.lua: fd = socket.listen(ip, port)
* socket.start(fd, function(fd, addr) { send msg to agent[i++]; })
* socket.start(fd) socket.read() socket.write()
* skynet套接字核心循环 main() => skynet_start(&config) => start(n) => thread_socket() => skynet_socket_poll() => socket_server_poll()
* skynet简单HTTP服务器流程:
readfunc(sock) return function (bytes) --[[socketreadfunc]] socket.read(sock, bytes) end end
writefunc(sock) return function (content) --[[socketwritefunc]] socket.write(sock, content) end end
-- read flow
httpd.read_requestx(readfunc(sock), bodybyteslimit)
pcall(readallx, socketreadfunc, bodybyteslimit)
readallx(socketreadfunc, bodybyteslimit)
  local headers = {}
  local body = recvheader(socketreadfunc, headers, "")
  if not body then return 413 --[[request entitiy too large]] end
  local method, url, httpver = get the first line information
  -- parse all headers out from received headers
  local header = parseheader(headers, 2, {})
  -- receive remaining content
  if mode == "chunked" then body, header = recvchunkedbody(socketreadfunc, bodybyteslimit, header, body)
  else body = body .. socketreadfunc(length - #body) end
end
-- socket.lua/lua-socket.c --
socket.read(sock, size)
-- write flow
response(sock, statuscode, bodyorfunc, tableofheaders) -- 
local ok, nerr = httpd.write_response(writefunc(sock), statuscode, bodyorfunc, tableofheaders)
pcall(writeall, sockwritefunc, statuscode, bodyorfunc, tableofheaders)
writeall(sockwritefunc, statuscode, bodyfunc, tableofheaders)
  local statusline = "HTTP/1.1 statuscode statusmsg\r\n"
  socket.write(sock, statusline) -- socketwritefunc(statusline)
  socket.write(sock, headers in the table)
  if bodyorfunc is a string then
    socket.write(sock, "content-length: bodylength\r\n\r\n")
    socket.write(sock, bodyorfunc)
  elseif bodyor func is a function then
    socket.write(sock, "transfer-encoding: chunked\r\n")
    socket.write(sock, "\r\n{ %x | #s }\r\n{ %s | s }") -- s = bodyfunc() until s is nil, then:
    socket.write(sock, "\r\n0\r\n\r\n")
  else
    socket.write(sock, "\r\n")
  end
end
-- socket.lua/lua-socket.c --
socket.write(sock, content)
socketdriver.send => lsend(lua_State* L) {
  skynet_context* ctx = the first upvalue;
  int sock = luaL_checkinteger(L, 1); // get the first argument
  int size = 0; // get the 2nd argument using get_buffer, it will auto get 
  void* buff = get_buffer(L, 2, &size); // the content according to the value type
  int err = skynet_socket_send(ctx, sock, buff, size);
  lua_pushboolean(L, !err);
  return 1; // return the result status
}
-- skynet_socket.c --
skynet_socket_send(ctx, sock, buff, size)
socket_server_send(SOCKET_SERVER, sock, buff, size)
  struct request_package request;
  request.u.send.id = sock
  request.u.send.sz = size
  request.u.send.buffer = (char*)buffer
  send_request(SOCKET_SERVER, &request, 'D', sizeof(request.u.send))
end
send_request(socket_server* ss, request_package* r, char type, int len)
  request->header[6] = (uint8_t)type;
  request->header[7] = (uint8_t)len;
  int n = write(ss->sendctrl_fd, &request->header[6], len+2);
  // continue to write until n <= 0 then return
end
```
