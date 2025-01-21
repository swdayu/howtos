
## Build
```shell
$ git clone git@github.com:cloudwu/skynet.git
$ cd skynet
$ git submodule update --init
$ make linux   # or macosx
# start the server
$ ./skynet examples/config
# open a new terminal and launch a client
$ ./3rd/lua/lua examples/client.lua   # and try input sth.
```

## Config
```shell
root = "./"  --> skynet root folder
luaservice = root .. "../?.lua;" .. root .. "service/?.lua;" .. root .. "test/?.lua;" .. root .. "examples/?.lua"
lualoader = root .. "lualib/loader.lua"
lua_path = root .. "../?.lua;" .. root .. "lualib/?.lua;" .. root .. "lualib/?/init.lua"
lua_cpath = root .. "luaclib/?.so"
cpath = root .. "cservice/?.so"
-- preload = root .. "examples/preload.lua"  --> run preload.lua before every lua service run
snax = root .. "examples/?.lua;" .. root .. "test/?.lua"
-- snax_interface_g = "snax_g"
-- daemon = root .. "skynet.pid"
logpath = root .. "service_msgslog/"
logger = nil  --> nil for stderr, otherwise specify a log file name
thread = 4  --> number of work threads
harbor = 0  --> range between 0 and 255, 0 is for single node network
-- standalone = "0.0.0.0:2013"  --> this is a master node
-- master = "127.0.0.1:2013"    --> master node ip and port
-- address = "127.0.0.1:2526"   --> current node ip and port
logservice = "logger"
bootstrap = "snlua bootstrap"
start = "httpd" -- "simpleweb" -- "main"

#!/bin/bash
cd skynet && pwd
echo "./skynet ../skynet.conf"
./skynet ../skynet.conf
```

```lua
-- https://github.com/cloudwu/skynet/wiki/Http
-- examples/simpleweb.lua

local skynet = require "skynet"
local socket = require "socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local table = table
local string = string

local mode = ...

if mode == "agent" then

local function response(id, ...)
  local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
  if not ok then
    -- if err == sockethelper.socket_error , that means socket closed.
    skynet.error(string.format("fd = %d, %s", id, err))
  end
end

skynet.start(function()
  skynet.dispatch("lua", function (_,_,id)
    socket.start(id)  --> start to receive socket
    --> limit request body size to 8192 (you can pass nil to unlimit)
    --> normal request usually with small data, set limit to 8K to avoid attack, this limit can be removed
    local code, url, method, httpver, header, body = httpd.read_requestx(sockethelper.readfunc(id), 8192)
    if code then
      if code ~= 200 then  --> if parse with wrong, will return a error code
        response(id, code)
      else
        --> this is a example response, rewrite your own response 
        local tmp = {}
        if method and url and httpver then
          table.insert(tmp, string.format("%s %s HTTP/%.1f", method, url, httpver))
        end
        if header.host then
          table.insert(tmp, string.format("host: %s", header.host))
        end
        local path, query = urllib.parse(url)
        table.insert(tmp, string.format("path: %s", path))
        if query then
          local q = urllib.parse_query(query)
          for k, v in pairs(q) do
            table.insert(tmp, string.format("query: %s= %s", k,v))
          end
        end
        table.insert(tmp, "-----header----")
        for k,v in pairs(header) do
          table.insert(tmp, string.format("%s = %s",k,v))
        end
        table.insert(tmp, "-----body----\n" .. body)
        response(id, code, table.concat(tmp,"\n"))
      end
    else
      --> if the throw error is socket_error, it is represented disconnected with client
      if url == sockethelper.socket_error then
        skynet.error("socket closed")
      else
        skynet.error(url)
      end
    end
    socket.close(id)
  end)
end)

else

skynet.start(function()
  local agent = {}
  for i= 1, 20 do
    --> start 20 agent server to handle http request
    skynet.error(string.format("SERVICE_NAME %s", SERVICE_NAME))
    agent[i] = skynet.newservice(SERVICE_NAME, "agent")  
  end
  local balance = 1
  --> listen to the web port
  local id = socket.listen("0.0.0.0", 8001)
  skynet.error("Listen web port 8001")
  socket.start(id , function(id, addr)  
    --> when there is a http request received, dispatch socket id to related agent to handle
    skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
    skynet.send(agent[balance], "lua", id)
    balance = balance + 1
    if balance > #agent then
        balance = 1
    end
  end)
end)

end
```
