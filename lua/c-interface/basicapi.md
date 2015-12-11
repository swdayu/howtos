
## Lua值

Lua的变量没有类型，所有变量都用C中的一个结构体表示：
```c
typedef struct lua_TValue {
  Value value_;
  int tt_;
} TValue;
typedef union Value {
  GCObject* gc;    // collectable object
  void* p;         // light userdata
  int b;           // boolean
  lua_CFunction f; // light C function
  lua_Integer i;   // interger number
  lua_Number n;    // float number
} Value;
typedef struct GCObject {
  struct GCObject* next;
  lu_byte tt;
  lu_byte marked;
} GCObject;
```

Lua值的类型（luaValue.tt_）
```c
[bit3-0]                   | [bit5-4]
0x00: LUA_TNIL             | 
0x01: LUA_TBOOLEAN         | 
0x02: LUA_TLIGHTUSERDATA   | 
0x03: LUA_TNUMBER          | [0: float][1: integer]
0x04: LUA_TSTRING          | [0: short string][1: long string]
0x05: LUA_TTABLE           | 
0x06: LUA_TFUNCTION        | [0: Lua closure][1: C function][2: C closure]
0x07: LUA_TUSERDATA        | 
0x08: LUA_TTHREAD          | 
0x09: LUA_TPROTO           | 
0x0A: LUA_TDEADKEY         | 
0xFF: LUA_TNONE            | 

[bit6] [0: non-collectable][1: collectable]
[bit7] N/A
```


## lua_Integer

The type of integers in Lua.
By default this type is `long long`, (usually a 64-bit two-complement integer), 
but that can be changed to `long` or `int` (usually a 32-bit two-complement integer). 
(See `LUA_INT_TYPE` in `luaconf.h`.)

Lua中的整数类型，默认是`long long`（通常是64位补码整数），但可以改成`long`或`int`（32位补码整数）。
（见`luaconf.h`中的`LUA_INT_TYPE`）。

Lua also defines the constants `LUA_MININTEGER` and `LUA_MAXINTEGER`, 
with the minimum and the maximum values that fit in this type.

Lua还定义了`LUA_MININTEGER`和`LUA_MAXINTEGER`表示这个类型能表示的最小最大值。

## lua_Unsigned

The unsigned version of `lua_Integer`.

`lua_Integer`的无符号版本。

## lua_Number

The type of floats in Lua.

By default this type is `double`, but that can be changed to a single `float` or a `long double`. 
(See `LUA_FLOAT_TYPE` in `luaconf.h`.)

Lua中的浮点类型，默认是`double`类型，但可以改成`float或者`long double`（见`luaconf.h`中的`LUA_FLOAT_TYPE`）。

## lua_typename [-0, +0, –]
```c
const char *lua_typename (lua_State *L, int tp);
```

Returns the name of the type encoded by the value `tp`, which must be one the values returned by `lua_type`.

返回类型`tp`的字符串表示，类型必须是`lua_type`的返回值之一。包括`LUA_TNIL`、`LUA_TNUMBER`、`LUA_TBOOLEAN`、
`LUA_TSTRING`、 `LUA_TTABLE`、 `LUA_TFUNCTION`、`LUA_TUSERDATA`、`LUA_TTHREAD`、`LUA_TLIGHTUSERDATA`。
这些常量定义在`lua.h`中。

## lua_version [-0, +0, v]
```c
const lua_Number *lua_version (lua_State *L);
```

Returns the address of the version number stored in the Lua core. 
When called with a valid `lua_State`, returns the address of the version used to create that state. 
When called with NULL, returns the address of the version running the call.

返回Lua版本值的地址。如果用有效的Lua State调用，返回创建这个State的版本地址。
如果是NULL，返回运行这个函数的Lua版本地址。

## lua_atpanic [-0, +0, –]
```c
lua_CFunction lua_atpanic (lua_State *L, lua_CFunction panicf);
```

Sets a new panic function and returns the old one (see §4.6).

设置一个新的Panic函数，并返回原来的Panic函数。

## lua_error [-1, +0, v]
```c
int lua_error (lua_State *L);
```

Generates a Lua error, using the value at the top of the stack as the error object. 
This function does a long jump, and therefore never returns (see `luaL_error`).

使用栈顶的错误对象产生一个Lua异常。这个函数使用`longjmp`，因此永远不会返回（见`luaL_error`）。

## lua_Alloc
```c
typedef void* (*lua_Alloc)(void* ud, void* ptr, size_t osize, size_t nsize);
```
The type of the memory-allocation function used by Lua states. 
The allocator function must provide a functionality similar to `realloc`, but not exactly the same. 
Its arguments are `ud`, an opaque pointer passed to `lua_newstate`; 
`ptr`, a pointer to the block being allocated/reallocated/freed; 
`osize`, the original size of the block or some code about what is being allocated; 
and `nsize`, the new size of the block.

Lua State使用的内存分配函数的类型。分配函数应提供`realloc`相似的功能，但并不完全一样。
参数`ud`是`lua_newstate`中传人的抽象指针；`ptr`指向要操作的内存块；`osize`表示旧大小；`nsize`表示新大小。

When `ptr` is not NULL, `osize` is the size of the block pointed by `ptr`, 
that is, the size given when it was allocated or reallocated.

When `ptr` is NULL, `osize` encodes the kind of object that Lua is allocating. 
`osize` is any of `LUA_TSTRING`, `LUA_TTABLE`, `LUA_TFUNCTION`, `LUA_TUSERDATA`, or `LUA_TTHREAD` 
when (and only when) Lua is creating a new object of that type. 
When `osize` is some other value, Lua is allocating memory for something else.

如果`ptr`不为空，`osize`表示`ptr`指向的内存块的大小，及这个内存块分配或重新分配时的大小。
如果`ptr`为空，`osize`表示Lua对象类型。
只有当Lua正在创建相应类型时，`osize`才会是这些值`LUA_TSTRING`、
`LUA_TTABLE`、`LUA_TFUNCTION`、`LUA_TUSERDATA`或`LUA_TTHREAD`。
如果`osize`是其他值表示Lua在分配其他内存。

Lua assumes the following behavior from the allocator function:
- When `nsize` is zero, the allocator must behave like free and return NULL.
- When `nsize` is not zero, the allocator must behave like `realloc`. 
  The allocator returns NULL if and only if it cannot fulfill the request. 
  Lua assumes that the allocator never fails when `osize >= nsize`.

Lua假设分配函数有如下行为：如果`nsize`是0分配其必须释放内存并返回NULL；
如果`nsize`不是0则必须实现与`realloc`相同；
分配函数只有在不能满足分配请求时才返回NULL，
Lua假设当`osize>=nsize`时，分配函数不会失败。

Here is a simple implementation for the allocator function. 
It is used in the auxiliary library by `luaL_newstate`.
```c
static void *l_alloc (void *ud, void *ptr, size_t osize, size_t nsize) {
  (void)ud;  (void)osize;  /* not used */
  if (nsize == 0) {
    free(ptr);
    return NULL;
  }
  else
    return realloc(ptr, nsize);
}
```

Note that Standard C ensures that `free(NULL)` has no effect 
and that `realloc(NULL,size)` is equivalent to `malloc(size)`. 
This code assumes that `realloc` does not fail when shrinking a block. 
(Although Standard C does not ensure this behavior, it seems to be a safe assumption.)

上面是分配函数的一个简单实现，它用在辅助函数`luaL_newstate`中。
注意标准C保证`free(NULL)`没有任何效果， `realloc(NULL,size)`相当于`malloc(size)`。
上面的代码假设`realloc`当缩减大小时不会失败（尽管标准C没有明确保证这个行为，但这应该是一个安全的假设）。

## lua_getallocf [-0, +0, –]
```c
lua_Alloc lua_getallocf (lua_State *L, void **ud);
```

Returns the memory-allocation function of a given state. 
If `ud` is not NULL, Lua stores in `*ud` the opaque pointer given when the memory-allocator function was set.

返回给定Lua State的分配函数。如果`ud`不为空，Lua将原来设置分配函数时指定的抽象指针保存到`*ud`中。

## lua_gc [-0, +0, e]
```c
int lua_gc (lua_State *L, int what, int data);
```

Controls the garbage collector.
This function performs several tasks, according to the value of the parameter `what`:
- LUA_GCSTOP: stops the garbage collector.
- LUA_GCRESTART: restarts the garbage collector.
- LUA_GCCOLLECT: performs a full garbage-collection cycle.
- LUA_GCCOUNT: returns the current amount of memory (in Kbytes) in use by Lua.
- LUA_GCCOUNTB: returns the remainder of dividing the current amount of bytes of memory in use by Lua by 1024.
- LUA_GCSTEP: performs an incremental step of garbage collection.
- LUA_GCSETPAUSE: sets data as the new value for the pause of the collector (see §2.5) 
  and returns the previous value of the pause.
- LUA_GCSETSTEPMUL: sets data as the new value for the step multiplier of the collector (see §2.5) 
  and returns the previous value of the step multiplier.
- LUA_GCISRUNNING: returns a boolean that tells whether the collector is running (i.e., not stopped).

For more details about these options, see `collectgarbage`.

该函数用于控制垃圾收集器。根据传人的`what`值函数可以执行不同的操作，这些值如上所示。
更多的细节请参考`collectgarbage`。

