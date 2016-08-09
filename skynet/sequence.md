
## Sequence Flow
```c
lhs:left           // left hand side
rhs:right          // right hand side
snl:skynet.lua     // skynet lua
snm:lua-skynet.lua // skynet middle

lhs:snl.start(start_func)
- sn1:snl.callback(skynet.dispatch_message)
  - snl:snm.lcallback(L) #1[dispatch_message]
    - snm:snm.L.RegistryTable[_cb] = dispatch_message
    - snm:snm.gL=L.RegistryTable[MAINTHREAD]
    - snm:snc.skynet_callback(ctx, gL, _cb)
      - snc:snc.ctx->cb=_cb ctx->cb_ud=gL
- sn1:sn1.timeout(0, cofunc = function() skynet.init_service(start_func) end)
  - snl:snl.session_str=intcommand("TIMEOUT", 0)
    - snl:snm.lintcommand(L) #2["TIMEOUT", 0]
    - snm:snc.session_str=skynet_command(ctx, "TIMEOUT", "0")
      - snc:snc.cmd_timeout(ctx, "0")
        - snc:snc.session=skynet_context_newsession(ctx) ++ctx->session_id, if 0 return 1
        - snc:snc.skynet_timeout(ctx->handle, 0, session) queueu the message to ctx->queue
          - snc:snc.skynet_context_push(handle, message[source=0,session=session,data=0,sz=hbyte PTYPE_RESPONSE(1)])
        - snc:snc.ctx->result=sprintf("%d", session) return as session_str
  - snl:snl.co=co_create(cofunc)
    - ......
  - sn1:sn1.session_id_coroutine[session_str]=co
```
