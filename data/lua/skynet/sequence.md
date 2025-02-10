
## sequence

```c
lua:Lua        // lua layer
mdl:MiddleLua  // lua c interface - lua layer
mdc:MiddleC    // lua c interface - c layer
ccc:C          // c layer

lua:skynet.start(start_func)
    mdl:callback(skynet.dispatch_message)
        mdc:lcallback(L) lstack: dispatch_message
            mdc:L.RegistryTable[_cb]=dispatch_message
            mdc:gL=L.RegistryTable[MAINTHREAD]
            ccc:skynet_callback(ctx, gL, _cb)
                ccc:ctx->cb=_cb, ctx->cb_ud=gL
    lua:skynet.timeout(0, cofunc=function()skynet.init_service(start_func)end) @ref(lua:skynet.init_service)
        mdl:session_str=intcommand("TIMEOUT", 0)
            mdc:lintcommand(L) lstack: "TIMEOUT", 0
                mdc:session_str=skynet_command(ctx, "TIMEOUT", "0")
                    mdc:cmd_timeout(ctx, "0")
                        ccc:session=skynet_context_newsession(ctx) return ++ctx->session_id and if 0 return 1
                        ccc:skynet_timeout(ctx->handle, 0, session) queueu the message to ctx->queue
                            ccc:skynet_context_push(handle, message[source=0,session=session,data=0,sz=hbyte PTYPE_RESPONSE(1)])
                        ccc:return ctx->result=sprintf session as string
        lua:co=co_create(cofunc)
        lua:session_id_coroutine[session_str]=co
```
