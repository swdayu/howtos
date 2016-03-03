
```lua
local c = require "skynet.core"

--@[string_to_handle]将字符串形式的句柄转换成数值
--例如将":10"转换成"0x10"再转换成16
local function string_to_handle(str)
  return tonumber("0x" .. string.sub(str, 2))
end

local skynet = {
  -- read skynet.h
  PTYPE_TEXT = 0, PTYPE_RESPONSE = 1, PTYPE_MULTICAST = 2, PTYPE_CLIENT = 3, 
  PTYPE_SYSTEM = 4, PTYPE_HARBOR = 5, PTYPE_SOCKET = 6, PTYPE_ERROR = 7,
  PTYPE_QUEUE = 8, -- used in deprecated mqueue, use skynet.queue instead
  PTYPE_DEBUG = 9, PTYPE_LUA = 10, PTYPE_SNAX = 11,
}
skynet.cache = require "skynet.codecache"

--@[skynet.register_protocol]注册对象到proto表中
local proto = {}
function skynet.register_protocol(class)
  local name = class.name
  local id = class.id
  assert(proto[name] == nil) --字符串名字class.name必须没有注册过，数字class.id必须在范围[0, 255]内
  assert(type(name) == "string" and type(id) == "number" and id >=0 and id <=255)
  proto[name] = class        --注册后可以通过proto[name]访问注册的对象
  proto[id] = class          --也可以通过proto[id]访问注册的对象
end


local profile = require "profile"
local coroutine_resume = profile.resume
local coroutine_yield = profile.yield

--@[co_create]如果协程池中有协程则取出最末尾一个resume并返回该协程，否则创建一个新协程返回
local coroutine_pool = {}
local function co_create(f)
  local co = table.remove(coroutine_pool)        --获取并移除协程池中的最后一个协程
  if co == nil then                              --如果获取的协程为空
    co = coroutine.create(function(...)          --新创建一个Lua标准协程，协程主函数会做以下事情：
      f(...)                                     --1. 执行用户传入的函数f
      while true do                              --2. 死循环一直执行以下操作：TODO
        f = nil                                  --   将f置为nil TODO
        coroutine_pool[#coroutine_pool+1] = co   --   将新创建的Lua协程放入协程池末尾
        f = coroutine_yield "EXIT"               --   调用profile.yield("EXIT")挂起协程，将返回的结果赋值给f   TODO
        f(coroutine_yield())                     --   调用profile.yield()挂起协程，然后使用其返回的参数调用f    TODO
      end                                        --返回第2步继续执行
    end)
  else                                           --否则获取的协程不为空
    coroutine_resume(co, f)                      --调用profile.resume(co, f)恢复协程co
  end
  return co                                      --最后将协程返回
end

function skynet.timeout(ti, func)
	local session = c.intcommand("TIMEOUT",ti)
	assert(session)
	local co = co_create(func)
	assert(session_id_coroutine[session] == nil)
	session_id_coroutine[session] = co
end

function skynet.sleep(ti)
  local session = c.intcommand("TIMEOUT",ti)
  assert(session)
  local succ, ret = coroutine_yield("SLEEP", session)
  sleep_session[coroutine.running()] = nil
  if succ then
    return
  end
  if ret == "BREAK" then
    return "BREAK"
  else
    error(ret)
  end
end

function skynet.yield()
  return skynet.sleep(0)
end
```
