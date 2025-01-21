
```lua
-- ## lualib/http/httpc.lua

local helper = require "http.sockethelper" --> lualib/http/sockethelper.lua
local url = require "http.url"             --> lualib/http/url.lua
local internal = require "http.internal"   --> lualib/http/internal.lua
local dns = require "dns"                  --> lualib/dns.lua

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
  helper.close(fd)                                   --> 保护调用（可以捕获函数调用错误）Lua函数request；然后关闭连接描述符
  if ok then                                         --> 如果调用成功，则
    return status, body                              --> 返回该http请求返回的status和body
  else                                               --> 否则
    error(status)                                    --> 抛出错误
  end
end

local function request(fd, method, host, url, recvheader, header, content)
  local read = helper.readfunc(fd)
  local write = helper.writefunc(fd)
  local header_content = ""
  if header then
    if not header.host then
      header.host = host
    end
    for k,v in pairs(header) do
      header_content = string.format("%s%s:%s\r\n", header_content, k, v)
    end
  else
    header_content = string.format("host:%s\r\n",host)
  end
  if content then
    local data = string.format("%s %s HTTP/1.1\r\n%scontent-length:%d\r\n\r\n", method, url, header_content, #content)
    write(data)
    write(content)
  else
  local request_header = string.format("%s %s HTTP/1.1\r\n%scontent-length:0\r\n\r\n", method, url, header_content)
    write(request_header)
  end
  local tmpline = {}
  local body = internal.recvheader(read, tmpline, "")
  if not body then
    error(socket.socket_error)
  end
  local statusline = tmpline[1]
  local code, info = statusline:match "HTTP/[%d%.]+%s+([%d]+)%s+(.*)$"
  code = assert(tonumber(code))
  local header = internal.parseheader(tmpline,2,recvheader or {})
  if not header then
    error("Invalid HTTP response header")
  end
  local length = header["content-length"]
  if length then
    length = tonumber(length)
  end
  local mode = header["transfer-encoding"]
  if mode then
    if mode ~= "identity" and mode ~= "chunked" then
      error ("Unsupport transfer-encoding")
    end
  end
  if mode == "chunked" then
    body, header = internal.recvchunkedbody(read, nil, header, body)
    if not body then
      error("Invalid response body")
    end
  else
    -- identity mode
    if length then
      if #body >= length then
        body = body:sub(1,length)
      else
        local padding = read(length - #body)
        body = body .. padding
      end
    else
      -- no content-length, read all
      body = body .. socket.readall(fd)
    end
  end
  return code, body
end
```
