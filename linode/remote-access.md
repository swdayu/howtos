
# SSH

Communicating with your Linode is usually done using the secure shell (SSH) protocol.
SSH encrypts all of the data transferred between the SSH client application on your computer and the Linode,
including passwords and other sensitive information.
There are SSH clients available for every operating system.

与Linode远程通信通常使用SSH协议，这样你本地SSH客户端与Linode服务器之间传输的所有数据都会被加密，包括密码及其他敏感信息。

- **Windows:** There is no native SSH client but you can use a free, open source application called PuTTY.
  PuTTY provides easy connectivity to any server running an SSH daemon (usually provided by OpenSSH).
  With this software, you can work as if you were logged into a console session on the remote system.
  
  Windows上没有原生的SSH客户端，但你可以使用免费开源软件[PuTTY][1].
  它可以与任何启动了SSH后台程序的服务器进行通信。
  使用这个软件，就像是登录到了远程系统的控制台程序上一样。
  
  To use PuTTY, simply download and save the program to your desktop and double-click it.
  Enter the hostname or IP address of the system you'd like to log into and click "Open" to start an SSH session.
  The default port for SSH is 22. If the SSH daemon is running on a different port, 
  you'll need to specify it after the hostname on the "Session" screen. See the picture below: 
  ![Putty Session Image][2]
  
  使用PuTTY，只要下载好可执行程序然后双击启动它，然后输入你想登录的主机名或IP地址，点击Open就可以开始一个SSH会话。
  SSH的默认端口是22，如果服务器上的SSH后台程序运行在不同的端口，你需要在PuTTY中特别指定这个端口。

[1]: http://www.chiark.greenend.org.uk/~sgtatham/putty/
[2]: ./assets/putty-session.png

  If you haven't logged into this system with PuTTY before, you will receive a warning.
  In this case, PuTTY is asking you to verify that the server you're logging into is who it says it is.
  This is due to the possibility that someone could be eavesdroppong on your connection, posing as the server you are trying to log into.
  You need some "out of band" method of comparing the key fingerprint presented to PuTTY 
  with the fingerprint of the public key on the server you wish to log into.
  You may do so by logging into you Linode via the AJAX console (see the "Remote Access" tab in the Linode Manager)
  and executing the following command: `ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub`.
  
  如果你是第一次登录，PuTTY会弹出一个警告，要你去验证现在登录的服务器是否是你想要登录的那个。
  这是因为有可能非法监听者窃听到你的连接，伪装成你想访问的服务器。
  你需要在带外(out of band)去比较PuTTY显示的公钥指纹与你想登录的服务器的是否一致。
  
  [[draft]] Linode上可以通过AJAX console登录运行命令`ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub`做这件事。
  AJAX console的位置在：Linode Manager | Remote Access | Console Access | Lish via Ajaxterm 。
  
  The key fingerprints should match; click “Yes” to accept the warning and cache this host key in the registry. 
  You won’t receive further warnings unless the key presented to PuTTY changes for some reason; 
  typically, this should only happen if you reinstall the remote server’s operating system. 
  If you should receive this warning again from a system you already have the host key cached on, 
  you should not trust the connection and investigate matters further.
  
  确认后，在PuTTY的警告窗口中单击Yes，此时PuTTY会把公钥保存起来，后面访问不会再有警告。
  除非服务器重装了系统，否则后续警告都应认为被窃听了，不应该信任这个连接。
  
- **Linux:** For Linux and Mac OS X, you can use terminal window or application to log in.
  For logging in the first time, follow below instructions:
  
  Enter the command of `ssh root@your.ip.address.here`. Then you'll see the authenticity warning like below.
  This is because your SSH client has never encountered the server's key fingerprint before.
  Type `yes` and press `ENTER` to continue connenting.
  ```
  The authenticity of host '123.456.78.90 (123.456.78.90)' can't be established.
  RSA key fingerprint is 11:eb:57:f3:a5:c3:e0:77:47:c4:15:3a:3c:df:6c:d2.
  Are you sure you want to continue connecting (yes/no)? 
  ```
  
  Linux和Mac可以在终端上使用ssh命令登录远程服务器，第一次登陆输入命令`ssh root@your.ip.address.here`后，
  会出现验证警告提示，这是因为你的SSH客户端程序还没有与这个服务器建立过连接，先选择yes继续。
  
  The login prompt appears for you to enter the password. Then the SSH client initiates the connection.
  You'll know you're logged in when the following prompt appears:
  ```
  Warning: Permanently added '123.456.78.90' (RSA) to the list of known hosts.
  root@li123-456:~#
  ```
  
  接下来输入密码，SSH建立连接然后登录成功。此时SSH会将服务器的公钥保存起来，后面连接不会再有警告。
  如果你重建了Linode，服务器上的公钥发生了变化，可能你会想把本地存储的无效公钥删除掉，可以用下面的方法：
  对于Linux和Mac执行`ssh-keygen -R your.ip.address.here`；
  对于Windows上的PuTTY你可以手动移除这个注册项的内容`HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\SshHostKeys`。

  



