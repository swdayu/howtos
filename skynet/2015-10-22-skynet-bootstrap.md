# References
- https://github.com/cloudwu/skynet/blob/master/skynet-src/skynet_main.c
- http://www.lua.org/manual/5.3/manual.html#4.8
- http://linux.die.net/man/3/pthread_key_create

# Run Skynet
```
./skynet ./your/config
```

# skynet_main.c
```
int main(int argc, char* argv[] {
  const char* config_file = get config file name from argv[1];
  luaS_initshr(); // in luashrtbl.h: current empty 
  
  skynet_globalinit(); // in skynet_server.c: init G_NODE and set thread-specific data of handle_key to THREAD_MAIN
    //G_NODE.total = 0;
	  //G_NODE.monitor_exit = 0;
	  //G_NODE.init = 1;
	  //if (pthread_key_create(&G_NODE.handle_key, NULL)) { fprintf(stderr, "pthread_key_create failed"); exit(1); }
	  //skynet_initthread(THREAD_MAIN); // set mainthread's key
	     //G_NODE(in skynet_server.c)//
	       //struct skynet_node {
	       //  int total; int init;
	       //  uint32_t monitor_exit;
	       //  pthread_key_t handle_key; };
         //static struct skynet_node G_NODE;
       //pthread_key_create(in pthread.h)//
         //int (pthread_key_t* key, void (*dtor)(void*)):
         //  create a thread-specific data key visible to all threads in the process
         //  a destroy function can be set to do clear work at thread exit
         //  "thread specific data" is data all threads can access but each thread has its own copy
         //  use `int pthread_setspecific(pthread_key_t key, const void* value)` to set specific data
         //  use `void* pthread_getspecific(pthread_key_t key)` to get specific data
       //skynet_initthread(in skynet_server.c)//
         //THREAD_MAIN(in skynet_imp.h): 1
         //void(int m): uintptr_t v = (uint32_t)(-m); pthread_setspecific(G_NODE.handle_key, (void*)&v);
         
  skynet_env_init(); // in skynet_env.c: environment initialise
    //E = skynet_malloc(sizeof(*E));
	  //SPIN_INIT(E)
	  //E->L = luaL_newstate(); //create a new lua state to E
       //E(in skynet_env.c)//
         //struct skynet_env {struct spinlock lock; lua_State* L;};
         //static struct skynet_env* E = NULL;
       //SPIN_INIT(in spinlock.h)//
         //struct spinlock { int lock; || pthread_mutex_t lock; };
         //#define SPIN_INIT(q) spinlock_init(&(q)->lock);
         //static inline void spinlock_init(struct spinlock* lock) { lock->lock = 0; }
         
  sigign(); // SIGPIPE signal handle
  
  //struct skynet_config(in skynet_imp.h)//
    //int thread; int harbor;
    //daemon, module_path, bootstrap, logger, logservice: const char*;
  struct skynet_config config;
  struct lua_State* L = lua_newstate(skynet_lalloc, NULL); // create a new lua state using skynet_lalloc
  luaL_openlibs(L); // open all standard lua libraries into the given state
  
  //static const char* load_config(in skynet_main.c): "
    //local config_name = ...; local f = assert(io.open(config_name)); local code = assert(f:read \'*a\');
    //local function getenv(name) return assert(os.getenv(name), \'os.getenv() failed: \' .. name) end
    //code = string.gsub(code, \'%$([%w_%d]+)\', getenv); f:close();
    //local result = {}; assert(load(code, \'=(load)\', \'t\', result))(); return result"
  int err = luaL_loadstring(L, load_config); // loads a string as a lua chunk, only load not run
  assert(err == LUA_OK);
  lua_pushstring(L, config_file); // push the string of config file name get from command line onto the stack
  
  err = lua_pcall(L, 1, 1, 0);
  if (err) { lua_close(L); return 1; }
  _init_env(L);
  
  config.thread =  optint("thread",8);
	config.module_path = optstring("cpath","./cservice/?.so");
	config.harbor = optint("harbor", 1);
	config.bootstrap = optstring("bootstrap","snlua bootstrap");
	config.daemon = optstring("daemon", NULL);
	config.logger = optstring("logger", NULL);
	config.logservice = optstring("logservice", "logger");

	lua_close(L);
	skynet_start(&config);
	skynet_globalexit();
	luaS_exitshr();
	return 0;
}
```

# Todo
- skynet_malloc, skynet_lalloc
- 

