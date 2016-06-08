
```lua
http.sockethelper --> lualib/http/sockethelper.lua
http.url          --> lualib/http/url.lua
http.internal     --> lualib/http/internal.lua
dns               --> lualib/dns.lua

local httpc = {}

--@[httpc.dns]设置一个异步查询的DNS服务器
--如果没有调用这个函数，DNS查询将是同步的，可以严重阻塞整个SKYNET的网络消息处理
local async_dns
function httpc.dns(server, port)
  async_dns = true
  dns.server(server, port)
end

--@[httpc.request]发起一个HTTP请求
--method可以是"GET"和"POST"
--host表示目标主机的地址
--url是请求的url路径
--recvheader可以是nil或空表，用于接收对方响应的http头部
--header是http请求头部
--content是http请求内容
function httpc.request(method, host, url, recvheader, header, content)
  local hostname, port = host:match"([^:]+):?(%d*)$" --> 获取目标主机的IP地址（或域名），以及端口号
  if port == "" then                                 --> 如果端口号为空，则
    port = 80                                        --> 使用默认端口号80
  else                                               --> 否则
    port = tonumber(port)                            --> 获取字符串表示的整型端口号
  end
  if async_dns and not hostname:match(".*%d+$") then --> 如果设置了异步DNS服务器，并且传入的是目标主机域名
    hostname = dns.resolve(hostname)                 --> 则异步的将域名解析成对应的IP地址
  end
  local fd = helper.connect(hostname, port)          --> 连接目标主机
  local ok, status, body = pcall(request, fd, method, host, url, recvheader, header, content)
  helper.clese(fd)
  if ok then
    return status, body
  else
    error(status)
  end
end
```
