# References
- https://github.com/cloudwu/skynet/blob/master/skynet-src/skynet_main.c
- https://git.oschina.net/jackiesun8/skynet/blob/master/skynet-src/skynet_main.c?dir=0&filepath=skynet-src%2Fskynet_main.c&oid=29b9ed2080db4a0f4a02f5653b97e82ffdfc7871&sha=5792bc2bd40f2a40fceab409ddc961de1b6f6450

# Run Skynet
```
./skynet ./your/config
```

# skynet_main.c
```
int main(int argc, char* argv[] {
  const char* config_file = get config file name from argv[1];
  luaS_initshr(); // 
  skynet_globalinit(); // global init
  skynet_env_init(); // environment init
  sigign(); // SIGPIPE signal handle
  
  struct skynet_config config;
  struct lua_State* L = lua_newstate(skynet_lalloc, NULL);
  luaL_openlibs(L);
  
  int err = luaL_loadstring(L, load_config);
  assert(err == LUA_OK);
  lua_pushstring(L, config_file);
  
}
```


