# References
- https://github.com/cloudwu/skynet
- https://github.com/cloudwu/skynet/wiki
- http://forthxu.com/blog/skynet.html

[[draft]]

# Skynet Start
- skynet is a lightwise server framework writen by c and lua
- skynet default start _timer, _socket, _monitor threads when it startup
- and user can configure to run multiple _worker threads to do their work
- c service: service written by c, it can be registered into skynet and run in it
- skynet主要负责服务注册以及协调服务之间的通讯和调用
- snlua is a special skynet module, it can be used to load and run services written by lua
- message external source: socket

# Skynet Folers
- lualib: lua libraries
- lualib-src: c libraries for lua
- service: lua services
- service-src: c services
- skynet-src: skynet main files
- client-src: client side tests

# Skynet Bootstrap
Bootstrap steps:
- input startup command `./skynet ./examples/config`
- skynet_main.c read the config file, setting up environment variables, and call skynet_start.c
- skynet_start.c startup _timer, _socket, _monitor threads and configured _worker threads and start to work

# Skynet Service
- each service has a callback function and a message queue
- _worker thread get a service's message queue from global queue, and get one message from this queue and call the service's callback function to handle it
- the server usually start one socket service and let gate.so to manage it
- the socket service can receive external messages and deliver them to inner services to handle

# Sknet Important Files
- skynet_server.c: to manage services
- skynet_handle.c: allocate services' unique handle
- skynet_module.c: to start so moudel written by c
- skynet_monitor.c: monitor dead loop in services
- skynet_mq.c: message queue management
- skynet_timer.c: timer management
- skynet_socket.c: socket module
- skynet_master.c: service name management for different skynet nodes
- skynet_harbor.c: responsible for communications between skynet nodes

# Skynet Important Services or Modules
- gate.so: provide socket function
- snlua.so: load and start lua service
- launcher.lua: start services in lua

# Sknet Library
- skynet.lua: lua common functions
- skynet.so: skynet functions for lua
- 

