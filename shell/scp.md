

# SCP

**Secure copy (remote file copy program)**

**scp** copies files between hosts on a network.
It uses ssh for data transfer, and uses the same authentication
and provides the same security as ssh.
File names may contain a user and host specification to indicate
that the file is to be copied to/from that host.
Local file names can be made explicit using absolute or relative pathnames 
to avoid scp treating file names containing `:` as host specifiers.
Copies between two remote hosts are also permitted.

**scp**在网络两台主机之间拷贝文件。它使用**ssh**进行数据传输，使用了与**ssh**相同的安全验证机制。
文件名可以包含用户名和主机名（例如`[user@]example.com:~/file`）表示文件来源于/拷贝到哪个主机。
本地文件名则使用绝对或相对路径名，以避免**scp**对包含`:`字符的文件名进行主机解析。
在两个远程主机之间拷贝文件也是允许的。

The options are as follows:

- **-1/2**: Forces **scp** to use protocol 1 or 2.

    选择第1版本协议或第2版本协议（ssh的协议版本）。

- **-4/6**: Forces **scp** to use IPv4 or IPv6 addresses only.

    指定使用IPv4或IPv6协议。

- **-3**: Copies between two remote hosts are transferred through the local host.
    Without this option the data is copied directly between the two remote hosts.

    通过本地主机在两个远程主机间拷贝文件。如果没有这个选项，文件会直接在两个远程主机间拷贝。

- **-B**: Selects batch mode (prevents asking for passwords or passphrases).

    批处理模式，避免输入密码或密码短语。

- **-C**: Compression enable. Passes the `-C` flag to ssh to enable compression.

    会将这个选项传给**ssh**来启动压缩模式。

- **-P port**: Specifies the port to connect to on the remote host.

    指定远程主机上ssh服务的端口号。

- **-r**: Recursively copy entire directories. 
    Note that **scp** follows symbolic links encountered in the tree traversal.

- **-v**: Verbose mode. Causes **scp** and ssh to print debugging messages about their progress.
    This is helpful in debugging connection, authentication, and configuration problems.

## Examples

```
# copy remote docs under `docs` folder to local current directory
$ scp -r -v root@example.com:~/docs/ .

# copy local file to remote folder
$ scp /home/a.mp3 root@example.com:/home/root/music/

# copy local file to remote and rename
$ scp /home/a.mp3 root@example.com:/home/root/music/001.mp3
```


