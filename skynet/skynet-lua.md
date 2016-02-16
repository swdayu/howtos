

local c = require "skynet.core"
local profile = require "profile"
local coroutine_resume = profile.resume
local coroutine_yield = profile.yield
local proto = {}

local skynet = {
  -- read skynet.h
  PTYPE_TEXT = 0,
  PTYPE_RESPONSE = 1,
  PTYPE_MULTICAST = 2,
  PTYPE_CLIENT = 3,
  PTYPE_SYSTEM = 4,
  PTYPE_HARBOR = 5,
  PTYPE_SOCKET = 6,
  PTYPE_ERROR = 7,
  PTYPE_QUEUE = 8,	-- used in deprecated mqueue, use skynet.queue instead
  PTYPE_DEBUG = 9,
  PTYPE_LUA = 10,
  PTYPE_SNAX = 11,
}
skynet.cache = require "skynet.codecache"

function skynet.register_protocol(class)
  local name = class.name
  local id = class.id
  assert(proto[name] == nil) --字符串名字class.name必须没有注册过，数字class.id必须在范围[0, 255]内
  assert(type(name) == "string" and type(id) == "number" and id >=0 and id <=255)
  proto[name] = class        --使用class.name可以访问到class这个对象
  proto[id] = class          --使用class.id也可以访问到class这个对象
end

--@[string_to_handle]例如将":10"转换成"0x10"再转换成16
local function string_to_handle(str)
  return tonumber("0x" .. string.sub(str, 2))
end
```
