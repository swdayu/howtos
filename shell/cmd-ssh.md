
# References
- http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/slogin.1?query=ssh&sec=1

# ssh

ssh - OpenSSH SSH client (remote login program)
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

**ssh** (SSH client) is a program for logging into a remote machine and for executing commands on a remote machine.
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
    
    IPv6 address can be specified by enclosing the address in square brackets.
    Only the superuser can forward privileged ports.
    By default, the local port is bound in accordance with the **GatewayPorts** setting.
    However, an explicit *bind_address* may be used to bind the connection to a specific address.
    The *bind_address* of "localhost" indicates that the listening port be bound for local use only,
    while an empty address or '*' indicates that the port should be available from all interfaces.
    
        ssh [-qTfnN] -D 7070 user@remote.com
        Firefox | Advanced | Network | Connection Settings | Manual proxy configuration:
        SOCKS Host: [127.0.0.1]    Port: [7070]    [*]SOCKS v5
        
- **-E** log_file
  
    Append debug logs to *log_file* instead of standard error.

- **-e** escape_char

    Sets the escape character for sessions with a pty (default: '~').
    The escape character is only recognized at the beginning of a line.
    The escape character followed by a dot ('.') closes the connection;
    followed by control-Z suspends the connection;
    and followed by itself sends the escape character once.
    Setting the character to "none" disables any escapes and makes the session fully transparent.
    
- **-F** configfile

    Specifies an alternative per-user configuration file.
    If a configuration file is given on the command line, 
    the system-wide configuration file (`/etc/ssh/ssh_config`) will be ignored.
    The default for the per-user configuration file is `~/.ssh/config`.
    
- **-f**

    Requests **ssh** to go to background just before command execution.
    This is useful if **ssh** is going to ask for passwords or passphrases, but the user wants it in the background.
    This implies **-n**. The recommended way to start X11 programs at a remote site is with something like
    `ssh -f host xterm`.
    
- **-G**

    Causes **ssh** to print its configuration after evaluating **Host** and **Match** blocks and exit.
    
- **-g**

    Allow remote hosts to connect to local forwarded ports.
    If used on a multiplexed connection, then this option must be specified on the master process.

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
    
- **-q**

    Quiet mode. Causes most warning and diagnostic messages to be suppressed.
    
- **-T**

    Disable pseudo-terminal allocation.
    
- **-t**

    Force pseudo-terminal allocation.
    This can be used to execute arbitrary screen-based programs on a remote machine,
    which can be very useful, e.g. when implementing menu services.
    Multiple **-t** options force tty allocation, even if **ssh** has no local tty.
    
**ssh** may additionally obtain configuration data from a per-user configuration file 
and a system-wide configuration file.
The file format and configuration options are described in ssh_config(5).

    

