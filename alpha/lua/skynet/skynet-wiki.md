
虽然 skynet 的核心是由 C 语言编写，但如果只是简单使用 skynet ，并不要求 C 语言基础。
但你需要理解 Actor 模式的工作方式，把你的业务拆分成多个服务来协同工作。
Lua 是必要的开发语言，你只需要懂得 Lua 就可以使用 LuaAPI 来完成服务间的通讯协作。
另外，Snax 可能会是更简单的方式。关于服务间共享数据，除了用消息传递的方式外，还可以参考 ShareData 。

当然只有这些仅仅可以让 skynet 内部的服务相互协作。要做到给客户端提供服务，还需要使用 Socket API ，
或者使用已经编写好的 GateServer 模板解决大量客户端接入的问题。或许你还需要为 C/S 通讯制订一套通讯协议，
skynet 并没有规定这个协议，可以自由选择。当然你也可以看看 Sproto 。

通过这套 Socket API以及更方便的 SocketChannel（更容易实现 socket 池和断开重连），
可以让 skynet 异步调度外部 socket 事件。对外部独立服务的访问，最好都通过这套 API 的封装。
如果外部库直接调用系统的 socket ，很可能阻塞住 skynet 的工作线程，发挥不出性能。
目前 redis 和 MongoDB 都有内置的封装好的 driver 可供使用。

skynet 由一个或多个进程构成，每个进程被称为一个 skynet 节点。skynet 节点通过运行 skynet 主程序启动，
必须在启动命令行传入一个 Config 文件名作为启动参数。skynet 会读取这个 config 文件获得启动需要的参数。

第一个启动的服务是 logger ，它负责记录之后的服务中的 log 输出。logger 是一个简单的 C 服务，
skynet_error 这个 C API 会把字符串发送给它。在 config 文件中，logger 配置项可以配置 log 输出的文件名，
默认是 nil ，表示输出到标准输出。

bootstrap 这个配置项关系着 skynet 运行的第二个服务。通常通过这个服务把整个系统启动起来。
默认的 bootstrap 配置项为 "snlua bootstrap" ，这意味着，skynet 会启动 snlua 这个服务，
并将 bootstrap 作为参数传给它。snlua 是 lua 沙盒服务，bootstrap 会根据配置的 luaservice 匹配到最终的 lua 脚本。
如果按默认配置，这个脚本应该是 service/bootstrap.lua 。

最后，它从 config 中读取 start 这个配置项，作为用户定义的服务启动入口脚本运行。成功后，把自己退出。
这个 start 配置项，才是用户定义的启动脚本，默认值为 "main" 。examples 目录下有很多这样的例子。


