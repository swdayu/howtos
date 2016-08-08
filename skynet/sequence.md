
## Sequence Flow
```c
lhs:left           // left hand side
rhs:right          // right hand side
snl:skynet.lua     // skynet lua
snm:lua-skynet.lua // skynet middle

lhs:snl.start(start_func)
sn1:snm.callback(skynet.dispatch_message)
snm:snm.lcallback(L) lstack[dispatch_message]

```
