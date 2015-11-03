
# References
- https://help.github.com/articles/which-remote-url-should-i-use/
- http://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes

# Access GitHub via SSH

These URLs provide access to a Git repository via SSH, which is a secure protocol. 
To use these URLs, you must have [an SSH keypair][] generated on your computer, and attached to your GitHub account.

The GitHub desktop clients automatically configure SSH keys for you, if you don't want to muck around on the command line.

Tip: SSH URLs can be used locally, or as a secure way of deploying your code to production servers. 
You can also use [SSH agent forwarding][] with your deploy script to avoid managing keys on the server.

[an SSH keypair]: https://help.github.com/articles/generating-ssh-keys/
[SSH agent forwarding]: https://developer.github.com/guides/using-ssh-agent-forwarding/

SSH URLs提供一种用SSH访问Git库的方法，SSH是一种安全协议。
使用这种URLs，需要在本地配置SSH密钥，并将它设置到GitHub账户中。
GitHub桌面客户端能自动配置好SSH密钥，如果你不想去鼓捣命令行。

提示：SSH URLs可以用在本地，或作为一种安全方式将代码发布到产品服务器。
还可以在发布脚本中使用SSH代理转发功能避免在服务器上维护密钥。

## Generating SSH keys

SSH keys are a way to identify trusted computers, without involving passwords. 
The steps below will walk you through generating an SSH key and adding the public key to your GitHub account.
We recommend that you regularly [review your SSH keys list][] and revoke any that haven't been used in a while.

[review your SSH keys list]: https://help.github.com/articles/keeping-your-ssh-keys-and-application-access-tokens-safe/

SSH密钥用来识别信任的机器，而不需要使用密码。
下面的步骤介绍如何产生SSH密钥并将其添加到GitHub账户中。
建议定期检查SSH密钥列表，将一段时间没用的密钥删除掉。

### Step 1: Check for SSH keys

First, we need to check for existing SSH keys on your computer. Open the command line and enter:
```
$ ls -al ~/.ssh
# Lists the files in your .ssh directory, if they exist
```
Check the directory listing to see if you already have a public SSH key.
By default, the filenames of the public keys are one of the following:
- id_dsa.pub
- id_ecdsa.pub
- id_ed25519.pub
- id_rsa.pub

使用上面的命令查看机器上是否已经存在SSH密钥。
其中SSH公钥文件的默认名称是上面所列名称中的一个。

If you see an existing public and private key pair listed (for example `id_rsa.pub` and `id_rsa`) 
that you would like to use to connect to GitHub, you can skip **Step2** and go straight to **Step 3**.

Tip: if you receive an error that `~/.ssh` doesn't exist, don't worry! We'll create it in **Step 2**.

如果公钥和私钥对已经存在（例如`id_rsa.pub`和`id_rsa`）并用它们来连接GitHub，可以直接跳转见步骤3。
注意：如果提示错误`~/.ssh`不存在，不要担心，步骤2会创建它。

### Step 2: Generate a new SSH key

1. With the command line still open, copy and paste the text below. 
   Make sure you substitute in your GitHub email address.

        $ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
        # Creates a new ssh key, using the provided email as a label
        Generating public/private rsa key pair.

   上面的命令创建rsa密钥对，注意使用你的GitHub邮箱地址。

2. We strongly suggest keeping the default settings as they are, 
   so when you're prompted to "Enter a file in which to save the key", just press `Enter` to continue.

        Enter file in which to save the key (/Users/you/.ssh/id_rsa): [Press enter]

   建议保持默认设置，当显示“输入保存密钥的文件”时，直接输入`Enter`继续。
   
3. You'll be asked to enter a passphrase.

        Enter passphrase (empty for no passphrase): [Type a passphrase]
        Enter same passphrase again: [Type passphrase again]
   
   Tip: We strongly recommend a very good, secure passphrase. 
   For more information, see "[Working with SSH key passphrases][]".

   然后会提示输入一个密码短语。建议使用好的安全密码短语，详细的说明见上面的链接。

4. After you enter a passphrase, you'll be given the fingerprint, or id, of your SSH key. 
   It will look something like this:

        Your identification has been saved in /Users/you/.ssh/id_rsa.
        Your public key has been saved in /Users/you/.ssh/id_rsa.pub.
        The key fingerprint is:
        01:0f:f4:3b:ca:85:d6:17:a1:7d:f0:68:9d:f0:a2:db your_email@example.com

   之后，SSH密钥的指纹或id会产生出来，如上。

[Working with SSH key passphrases]: https://help.github.com/articles/working-with-ssh-key-passphrases/

### Step 3: Add your key to the ssh-agent

To configure the [ssh-agent][] program to use your SSH key:

1. Ensure ssh-agent is enabled:

        # start the ssh-agent in the background
        $ eval "$(ssh-agent -s)"
        Agent pid 59566

   使用上面的命令开启`ssh-agent`。

2. Add your SSH key to the ssh-agent:

        $ ssh-add ~/.ssh/id_rsa

   然后将SSH密钥添加到`ssh-agent`。

Tip: If you didn't generate a new SSH key in Step 2, and used an existing SSH key instead, 
you will need to replace `id_rsa` in the above command with the name of your existing private key file.

如果不是新产生的SSH密钥，而是已经存在的，请使用实际的私钥文件名称。

[ssh-agent]: https://en.wikipedia.org/wiki/Ssh-agent

### Step 4: Add your SSH key to your account

To configure your GitHub account to use your SSH key:

1. In your favorite text editor, open the `~/.ssh/id_rsa.pub` file.
2. Select the entire contents of the file and copy it to your clipboard. Do not add any newlines or whitespace.

Warning: It's important to copy the key exactly without adding newlines or whitespace.

要把SSH密钥设置到GitHub账户中，首先将`～/.ssh/id_rsa.pub`文件内容拷贝到粘贴板。
重要的是在拷贝过程中，不要添加任何换行和空白。

Add the copied key to GitHub:

1. Settings icon in the user bar in the top right corner of any page, 
   click your profile photo, then click **Settings**.
2. In the user settings sidebar, click **SSH keys**.
3. Click **Add SSH key**.
4. In the Title field, add a descriptive label for the new key. 
   For example, if you're using a personal Mac, you might call this key "Personal MacBook Air".
5. Paste your key into the "Key" field.
6. Click **Add key**.
7. Confirm the action by entering your GitHub password.

然后按步骤将密钥添加到GitHub：Settings | SSH keys | Add SSH key。
添加密钥时，会添加新密钥的描述信息，例如你使用的是私人Mac电脑，可以将描述信息写成“Personal MacBook Air”。
最后，点击`Add key`，然后输入GitHub密码进行确认。

### Step 5: Test the connection

To make sure everything is working, you'll now try to SSH into GitHub. 
When you do this, you will be asked to authenticate this action using your password, 
which is the SSH key passphrase you created earlier.

为了确保能连接，尝试一下SSH是否能连接到GitHub。
连接时，首先会要求用原来创建的密码短语进行验证。

1. Open the command line and enter:

        $ ssh -T git@github.com
        # Attempts to ssh to GitHub

   输入命令使用ssh连接GitHub。

2. You may see this warning:

        The authenticity of host 'github.com (207.97.227.239)' can't be established.
        RSA key fingerprint is 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
        Are you sure you want to continue connecting (yes/no)?

   Verify the fingerprint in the message you see matches the following message, then type `yes`:

        Hi username! You've successfully authenticated, but GitHub does not
        provide shell access.

   可能会出现上面的警告信息，你需要对比这里显示的密钥指纹跟原来产生的密钥指纹是否一致，
   如果是，输入`yes`继续。

3. If the username in the message is yours, you've successfully set up your SSH key!
   If you receive a message about "access denied," you can [read these instructions for diagnosing the issue][].
   If you're switching from HTTPS to SSH, you'll now need to update your remote repository URLs. 
   For more information, see [Changing a remote's URL][].

   最后，如果显示出了你的`username`，则表明SSH密钥已经添加成功。
   如果收到“访问拒绝”的信息，参考上面的链接诊断问题。
   如果是从HTTPs切换到使用SSH，需要首先把GitHub库的URL改成SSH形式的URL，更多的信息见上面的链接。

[read these instructions for diagnosing the issue]: https://help.github.com/articles/error-permission-denied-publickey
[Changing a remote's URL]: https://help.github.com/articles/changing-a-remote-s-url

# SSH key passphrases

This section will walk you through the process of securing your SSH keys and configuring 
an authentication agent so that you won't have to re-enter your passphrase every time you use your keys.

## Why do I need a passphrase?

Passwords aren't very secure. If you use one that's easy to remember, 
it's also easier to guess or brute-force (try many options until one works). 
If you use one that's random, it's hard to remember, and thus you're more inclined to write it down. 
Both of these are Very Bad Things.

This is why you're using SSH keys. Of course, using a key without a passphrase is basically 
the same as writing down a random password: anyone who gains access to your computer 
has gained access to every system you use that key with. This is also a Very Bad Thing. 
The solution is to add a passphrase to the SSH key for an extra layer of security.

**But I don't want to enter a long passphrase every time I use the key!**

Neither do I! Thankfully, there's a nifty little tool called ssh-agent that can securely save your passphrase, 
so you don't have to re-enter it. If you're on OS X Leopard or later your keys can be saved 
in the system's keychain to make your life even easier. 
Most Linux installations will automatically start ssh-agent for you when you log in.

## Adding or changing a passphrase

You can change the passphrase for an existing private key without regenerating the keypair. 
Just type the following command:
```
$ ssh-keygen -p
# Start the SSH key creation process
Enter file in which the key is (/Users/you/.ssh/id_rsa): [Hit enter]
Key has comment '/Users/you/.ssh/id_rsa'
Enter new passphrase (empty for no passphrase): [Type new passphrase]
Enter same passphrase again: [One more time for luck]
Your identification has been saved with the new passphrase.
```

If your key already has a passphrase, 
you will be prompted to enter it before you can change to a new passphrase.

# Using SSH over HTTPS port
Sometimes, firewalls refuse to allow SSH connections entirely.
If using HTTPS cloning with credential caching is not an option,
you can attempt to clone using an SSH connection made over the HTTPS port.

To test if SSH over the HTTPS port is possible, run following SSH command.
If that worked, great! If not, you may need to follow troubleshooting guide.
```
$ ssh -T -p 443 git@ssh.github.com
```
