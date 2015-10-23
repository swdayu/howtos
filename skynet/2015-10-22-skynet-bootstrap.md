# References
- https://github.com/cloudwu/skynet/blob/master/skynet-src/skynet_main.c
- http://www.lua.org/manual/5.3/manual.html#4.8
- http://linux.die.net/man/3/pthread_key_create
- https://git.oschina.net/jackiesun8/skynet/

# Run Skynet
```
./skynet your_config_file
```

# skynet_main.c
```
int main(int argc, char* argv[] {
  const char* config_file = get config file name from argv[1];
  luaS_initshr(); // in luashrtbl.h: current empty 
  
  skynet_globalinit(); // in skynet_server.c: init G_NODE and set a thread-specific data THREAD_MAIN
      //G_NODE.total = 0;
      //G_NODE.monitor_exit = 0;
      //G_NODE.init = 1;
      //if (pthread_key_create(&G_NODE.handle_key, NULL)) { exit(1); }
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
             //void skynet_initthread(int m): 
             //  uintptr_t v = (uint32_t)(-m); pthread_setspecific(G_NODE.handle_key, (void*)&v);
         
  skynet_env_init(); // in skynet_env.c: alloc env and init env
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
         
  sigign(); // in skynet_main.c: ignore SIGPIPE signal
      //int sigign() { struct sigaction sa; sa.sa_handler = SIG_IGN; sigaction(SIGPIPE, &sa, 0); return 0; }
      //set the SIGPIPE signal's handler function to SIG_IGN
      //background story: if a socket is closed by client, then call write twice on this socket, 
      //  the second call will generate SIGPIPE signal, this signal terminate process by default
      
  //struct skynet_config(in skynet_imp.h):
      //int thread; int harbor;
      //daemon, module_path, bootstrap, logger, logservice: const char*;
  struct skynet_config config;
  struct lua_State* L = lua_newstate(skynet_lalloc, NULL); // create a new lua state using skynet_lalloc
  luaL_openlibs(L); // open all standard lua libraries into the given state
  
  //static const char* load_config(in skynet_main.c) = "
      //local config_name = ...; local f = assert(io.open(config_name)); local code = assert(f:read \'*a\');
      //local function getenv(name) return assert(os.getenv(name), \'os.getenv() failed: \' .. name) end
      //code = string.gsub(code, \'%$([%w_%d]+)\', getenv); => replace env variables like $PATH in config code
      //f:close(); local result = {}; 
      //assert(load(code, \'=(load)\', \'t\', result))(); => load lua string chunk as text mode and call it
      //return result"
  int err = luaL_loadstring(L, load_config); // loads a string as a lua chunk, only load not run
  assert(err == LUA_OK);
  lua_pushstring(L, config_file); // push the string of config file name get from command line onto the stack
  err = lua_pcall(L, 1, 1, 0); // run lua code with 1-arg and 1-result and no-errfunc, see `lua/lua-call.md`
  if (err) { lua_close(L); return 1; }
  _init_env(L); // save config to skynet's env
  
  // store config (if not exist in env use specified arg) to skynet config struct
  config.thread = optint("thread",8);
  config.module_path = optstring("cpath","./cservice/?.so");
  config.harbor = optint("harbor", 1);
  config.bootstrap = optstring("bootstrap","snlua bootstrap");
  config.daemon = optstring("daemon", NULL);
  config.logger = optstring("logger", NULL);
  config.logservice = optstring("logservice", "logger");

  lua_close(L); // destroys all objects in the given lua state and frees all dynamic memory used 
  skynet_start(&config);
  skynet_globalexit(); // in skynet_server.c: { pthread_key_delete(G_NODE_handle_key); }
  luaS_exitshr(); // in luashrtbl.h: current empty
  return 0;
}
```

# skynet_start.c
```
void skynet_start(struct skynet_config* config) {
  if (config->daemon) {
		if (daemon_init(config->daemon)) {
			exit(1);
		}
	}
	skynet_harbor_init(config->harbor);
	skynet_handle_init(config->harbor);
	skynet_mq_init();
	skynet_module_init(config->module_path);
	skynet_timer_init();
	skynet_socket_init();

	struct skynet_context *ctx = skynet_context_new(config->logservice, config->logger);
	if (ctx == NULL) {
		fprintf(stderr, "Can't launch %s service\n", config->logservice);
		exit(1);
	}

	bootstrap(ctx, config->bootstrap);

	start(config->thread);

	// harbor_exit may call socket send, so it should exit before socket_free
	skynet_harbor_exit();
	skynet_socket_free();
	if (config->daemon) {
		daemon_exit(config->daemon);
	}
}
```

# Todo
- skynet_malloc, skynet_lalloc
- lua_next

