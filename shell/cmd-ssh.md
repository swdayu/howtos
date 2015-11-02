
# References
- http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/slogin.1?query=ssh&sec=1

# SSH

Synopsis
```
ssh [-12346AaCfGgKkMNnqsTtVvXxYy]
    [-b bind_address]
    [-c cipher_spec]
    [-D [bind_address:]port]
    [-E log_file][-e escape_char]
    [-F configfile]
    [-I pkcsll][-i identity_file]
    [-L address][-l login_name]
    [-m mac_spec]
    [-O ctl_cmd][-o option]
    [-p port]
    [-Q query_option]
    [-R address]
    [-S ctl_path]
    [-W host:port][-w local_tun[:remote_tun]]
    [user@]hostname
    [command]
```

Logging into a remote machine
```
$ ssh [user@]remote.com [-p port] 
# logging into remote.com with a optional user name and port
# if the port is not given then use the default ssh server port 22
```

**ssh** (SSH client) is a program for logging into a remote machine 
and for executing commands on a remote machine.
It is intended to replace rlogin and rsh, and provide secure encrypted communications 
between two untrusted hosts over an insecure network.
X11 connections, arbitrary TCP ports and UNIX-domain sockets can also be forwarded over the secure channel.

**ssh** connects and logs into the specified *hostname* (with optional *user* name).
The user must prove his/her identity to the remote machine using one of several methods 
depending on the protocol version used (see below).

If *command* is specified, it is executed on the remote host instead of a login shell.

The options are as follows:

- **-D** [bind_address:]port

    Specifies a local "dynamic" application-level port forwarding.
    This works by allocating a socket to listen to *port* on the local side,
    optionally bound to the specified *bind_address*.
    Whenever a connection is made to this port, the connection is forward over the secure channel,
    and the application protocol is then used to determine where to connect to from the remote machine.
    Currently the SOCKS4 and SOCKS5 protocols are supported, and **ssh** will act as a SOCKS server.
    Only root can forward privileged ports.
    Dynamic port forwardings can also be specified in the configureation file.
    
    [1] IPv6 address can be specified by enclosing the address in square brackets.
    Only the superuser can forward privileged ports.
    By default, the local port is bound in accordance with the **GatewayPorts** setting.
    However, an explicit *bind_address* may be used to bind the connection to a specific address.
    The *bind_address* of "localhost" indicates that the listening port be bound for local use only,
    while an empty address or '*' indicates that the port should be available from all interfaces.
    
        ssh [-qTfnN] -D 7070 user@remote.com
        Firefox | Advanced | Network | Connection Settings | Manual proxy configuration:
        SOCKS Host: [127.0.0.1]    Port: [7070]    [*]SOCKS v5
        
- **-q**

    Quiet mode. Causes most warning and diagnostic messages to be suppressed.
    
- **-T**

    Disable pseudo-terminal allocation.
    
- **-t**

    Force pseudo-terminal allocation.
    This can be used to execute arbitrary screen-based programs on a remote machine,
    which can be very useful, e.g. when implementing menu services.
    Multiple **-t** options force tty allocation, even if **ssh** has no local tty.
    
- **-F** configfile

    Specifies an alternative per-user configuration file.
    If a configuration file is given on the command line, 
    the system-wide configuration file (`/etc/ssh/ssh_config`) will be ignored.
    The default for the per-user configuration file is `~/.ssh/config`.
    
- **-f**

    Requests **ssh** to go to background just before command execution.
    This is useful if **ssh** is going to ask for passwords or passphrases, 
    but the user wants it in the background.
    This implies **-n**. The recommended way to start X11 programs at a remote site is with something like
    `ssh -f host xterm`.
    
- **-N**

    Do not execute a remote command.
    This is useful for just forwarding ports (protocol version 2 only).

- **-n**

    Redirects stdin from `/dev/null` (actually, prevents reading from stdin).
    This must be used when **ssh** is run in the background.
    A common trick is to use this to run X11 programs on a remote machine.
    For example, `ssh -n shadows.cs.hut.fi emacs &` will start an emacs on shadows.cs.hut.fi,
    and the X11 connection will be automatically forwarded over an encrypted channel.
    The **ssh** program will be put in the background.
    (This does not work if **ssh** needs to ask for a password or passphrase; see also the **-f** option.)
  
- **-p** port

    Port to connect to on the remote host.
    This can be specified on a per-host basis in the configureation file.

- **-E** log_file
  
    Append debug logs to *log_file* instead of standard error.

- **-e** escape_char

    Sets the escape character for sessions with a pty (default: '~').
    The escape character is only recognized at the beginning of a line.
    The escape character followed by a dot ('.') closes the connection;
    followed by control-Z suspends the connection;
    and followed by itself sends the escape character once.
    Setting the character to "none" disables any escapes and makes the session fully transparent.
    
- **-L** [bind_address:]port:host:hostport
- **-L** [bind_address:]port:remote_socket
- **-L** local_socket:host:hostport
- **-L** local_socket:remote_socket

    Specifies that connections to the given TCP port or Unix socket on the local (client) host are to be
    forwarded to the given host and port, or Unix socket, on the remote side.
    This works by allocating a socket to listen to either a TCP *port* on the local side,
    optionally bound to the specified *bind_address*, or to a Unix socket.
    Whenever a connection is made to the local port or socket, 
    the connection is forwarded over the secure channel, 
    and a connection is made to either *host* port *hostport*,, or the Unix socket *remote_socket*, 
    from the remote machine.
    
    Port forwadings can also be specified in the configuration file.
    Remaining content is as same as **-D** [1].
    
- **-R** [bind_address:]port:host:hostport
- **-R** [bind_address:]port:local_socket
- **-R** remote_socket:host:hostport
- **-R** remote_socket:local_socket

    Specifies that connections to the given TCP port or Unix socket on the remote (server) host
    are to be forwarded to the given host and port, or Unix Socket, on the local side.
    This works by allocating a socket to listen to either an TCP *port* or to a Unix socket on the remote side.
    Whenever a connection is made to this port or Unix socket,
    the connection is forwarded over the secure channel, 
    and a connection is made to either *host* port *hostport*,
    or *local_socket*, from the local machine.
    
    Port forwardings can also be specified in the configuration file.
    Privileged ports can be forwarded only when logging in as root on the remote machine.
    IPv6 addresses can be specified by enclosing the address in square brackets.
    
    By default, TCP listening sockets on the server will be bound to the loopback interface only.
    This may be overridden by specifying a *bind_address*.
    An empty *bind_address*, or the address '*', indicates that the remote socket should listen on all interfaces.
    Specifying a remote *bind_address* will only succeed if the server's **GatewayPorts** optain is enabled
    ([see sshd_config(5)][]).
    
    If the *port* argument is '0', the listen port will be dynamically allocated on the server
    and reported to the client at run time.
    When used together with **-O forward** the allocated port will be printed to the standard output.
    
**ssh** may additionally obtain configuration data from a per-user configuration file 
and a system-wide configuration file.
The file format and configuration options are described in [ssh_config(5)][].

[see sshd_config(5)]: http://www.openbsd.org/cgi-bin/man.cgi?query=sshd_config&sec=5
[ssh_config(5)]: http://www.openbsd.org/cgi-bin/man.cgi?query=ssh_config&sec=5

## Authentication

The OpenSSH SSH client supports SSH protocols 1 and 2. 
The default is to use protocol 2 only, though this can be changed via the **Protocol** option 
in [ssh_config(5)][] or the **-1** and **-2** options (see above). 
Both protocols support similar authentication methods, but protocol 2 is the default 
since it provides additional mechanisms for confidentiality 
(the traffic is encrypted using AES, 3DES, Blowfish, CAST128, or Arcfour) and integrity 
(hmac-md5, hmac-sha1, hmac-sha2-256, hmac-sha2-512, umac-64, umac-128, hmac-ripemd160). 
Protocol 1 lacks a strong mechanism for ensuring the integrity of the connection.

The methods available for authentication are: GSSAPI-based authentication, host-based authentication, public key authentication, challenge-response authentication, and password authentication. Authentication methods are tried in the order specified above, though protocol 2 has a configuration option to change the default order: **PreferredAuthentications**.

Host-based authentication works as follows: If the machine the user logs in from is listed in /etc/hosts.equiv or /etc/shosts.equiv on the remote machine, and the user names are the same on both sides, or if the files ~/.rhosts or ~/.shosts exist in the user's home directory on the remote machine and contain a line containing the name of the client machine and the name of the user on that machine, the user is considered for login. Additionally, the server must be able to verify the client's host key (see the description of /etc/ssh/ssh_known_hosts and ~/.ssh/known_hosts, below) for login to be permitted. This authentication method closes security holes due to IP spoofing, DNS spoofing, and routing spoofing. [Note to the administrator: /etc/hosts.equiv, ~/.rhosts, and the rlogin/rsh protocol in general, are inherently insecure and should be disabled if security is desired.]

