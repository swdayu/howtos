
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
local coroutine = coroutine

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

--@[skynet.timeout]创建计时器和一个对应协程，并将计时器消息session号与协程进行关联
--传入参数：integer ti, lua_function func
function skynet.timeout(ti, func)
  local session = c.intcommand("TIMEOUT", ti)  --创建ti超时的计时器，时间ti超时后会向服务消息队列发送一条消息
  assert(session)                              --该函数会返回消息session号，session号不能为空
  local co = co_create(func)                   --使用超时处理函数创建一个新协程co
  assert(session_id_coroutine[session] == nil) --对应的session号必须没有关联其他协程
  session_id_coroutine[session] = co           --将session号和新协程进行关联
end

--@[skynet.sleep]创建sleep计时器然后yield当前协程，并清除当前协程关联的sleep消息session号
--传入参数：integer ti
--返回结果：如果yield成功则返回nil，否则返回"BREAK"或抛出异常
function skynet.sleep(ti)
  local session = c.intcommand("TIMEOUT", ti)         --创建ti超时的计时器，时间ti超时后会向服务消息队列发送一条消息
  assert(session)                                     --该函数会返回消息session号，session号不能为空
  local succ, ret = coroutine_yield("SLEEP", session) --yield当前协程
  sleep_session[coroutine.running()] = nil            --将当前运行协程对应的sleep消息session号设为nil
  if succ then                                        --如果yield成功则直接返回
    return
  end                                                 --否则yield失败，再判断：
  if ret == "BREAK" then                              --返回的第2个参数ret是否为"BREAK"
    return "BREAK"                                    --是则返回"BREAK"
  else                                                --否则抛出异常
    error(ret)
  end
end

--@[skynet.yield]超时为0会直接发送消息到服务消息队列，然后yield当前协程并清除当前协程关联的sleep消息session号
--传入参数：无
--返回结果：如果yield成功则返回nil，否则返回"BREAK"或抛出异常
function skynet.yield()
  return skynet.sleep(0)
end
```
