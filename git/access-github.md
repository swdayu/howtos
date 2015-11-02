
# References
- https://help.github.com/articles/which-remote-url-should-i-use/
- http://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes

# Clone using HTTPS (recommended)
The `https://` clone URLs are available on all repositories, public and private.
They are smart, so they will provide you with either read-only or read/write access,
depending on your permissions to the repository.
These URLs work everywhere - even if you are behind a firewell or proxy.
In certain cases, if you'd rather use SSH, you might be able to use SSH over the HTTPS port.

When you `git fetch`, `git pull`, or `git push` to the remote repository using HTTPS,
you'll be asked for your GitHub username and password. You can use a *credential helper* 
so Git will remember your GitHub username and password every time it talks to GitHub.
The *credential helper* can tell Git to remember your GitHub username and password every time it talks to GitHub.
You need Git 1.7.10 or newer to use the credential helper.

Git will save your password in memory for some time when *credential helper* is turn on.
By default, Git will cache your password for 15 minutes. 
You can set to use cache and to change the default password cache timeout.
```
$ git config --global credential.helper cache # set to use memory cache
$ git config --global credential.helper 'cache --timeout=3600' # set timeout to 3600s
```

If you have two-factor authentication enabled, 
you must create a personal access token to use instead of your GitHub password.

# Clone using SSH

These URLs provide access to a Git repository via SSH, which is a secure protocol. 
To use these URLs, you must have [an SSH keypair][] generated on your computer, and attached to your GitHub account.

The GitHub desktop clients automatically configure SSH keys for you, if you don't want to muck around on the command line.

Tip: SSH URLs can be used locally, or as a secure way of deploying your code to production servers. 
You can also use [SSH agent forwarding][] with your deploy script to avoid managing keys on the server.

[an SSH keypair]: https://help.github.com/articles/generating-ssh-keys/
[SSH agent forwarding]: https://developer.github.com/guides/using-ssh-agent-forwarding/

## Generating SSH keys

SSH keys are a way to identify trusted computers, without involving passwords. 
The steps below will walk you through generating an SSH key and adding the public key to your GitHub account.
We recommend that you regularly [review your SSH keys list][] and revoke any that haven't been used in a while.

[review your SSH keys list]: https://help.github.com/articles/keeping-your-ssh-keys-and-application-access-tokens-safe/

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

If you see an existing public and private key pair listed (for example id_rsa.pub and id_rsa) 
that you would like to use to connect to GitHub, you can skip **Step2** and go straight to **Step 3**.

Tip: if you receive an error that ~/.ssh doesn't exist, don't worry! We'll create it in **Step 2**.

### Step 2: Generate a new SSH key

1. With the command line still open, copy and paste the text below. Make sure you substitute in your GitHub email address.

        $ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
        # Creates a new ssh key, using the provided email as a label
        Generating public/private rsa key pair.

2. We strongly suggest keeping the default settings as they are, 
   so when you're prompted to "Enter a file in which to save the key", just press Enter to continue.

        Enter file in which to save the key (/Users/you/.ssh/id_rsa): [Press enter]

3. You'll be asked to enter a passphrase.

        Enter passphrase (empty for no passphrase): [Type a passphrase]
        Enter same passphrase again: [Type passphrase again]
   
   Tip: We strongly recommend a very good, secure passphrase. 
   For more information, see "[Working with SSH key passphrases][]".

4. After you enter a passphrase, you'll be given the fingerprint, or id, of your SSH key. 
   It will look something like this:

        Your identification has been saved in /Users/you/.ssh/id_rsa.
        Your public key has been saved in /Users/you/.ssh/id_rsa.pub.
        The key fingerprint is:
        01:0f:f4:3b:ca:85:d6:17:a1:7d:f0:68:9d:f0:a2:db your_email@example.com

[Working with SSH key passphrases]: https://help.github.com/articles/working-with-ssh-key-passphrases/

### Step 3: Add your key to the ssh-agent

To configure the [ssh-agent][] program to use your SSH key:

1. Ensure ssh-agent is enabled:

        # start the ssh-agent in the background
        $ eval "$(ssh-agent -s)"
        Agent pid 59566

2. Add your SSH key to the ssh-agent:

        $ ssh-add ~/.ssh/id_rsa

Tip: If you didn't generate a new SSH key in Step 2, and used an existing SSH key instead, 
you will need to replace id_rsa in the above command with the name of your existing private key file.

[ssh-agent]: https://en.wikipedia.org/wiki/Ssh-agent

### Step 4: Add your SSH key to your account

To configure your GitHub account to use your SSH key:

1. In your favorite text editor, open the ~/.ssh/id_rsa.pub file.
2. Select the entire contents of the file and copy it to your clipboard. Do not add any newlines or whitespace.

Warning: It's important to copy the key exactly without adding newlines or whitespace.

Add the copied key to GitHub:

1. Settings icon in the user barIn the top right corner of any page, click your profile photo, then click **Settings**.
2. SSH keysIn the user settings sidebar, click **SSH keys**.
3. SSH Key buttonClick **Add SSH key**.
4. In the Title field, add a descriptive label for the new key. 
   For example, if you're using a personal Mac, you might call this key "Personal MacBook Air".
5. Paste your key into the "Key" field.
6. Click **Add key**.
7. Confirm the action by entering your GitHub password.

### Step 5: Test the connection

To make sure everything is working, you'll now try to SSH into GitHub. 
When you do this, you will be asked to authenticate this action using your password, 
which is the SSH key passphrase you created earlier.

1. Open the command line and enter:

        $ ssh -T git@github.com
        # Attempts to ssh to GitHub

2. You may see this warning:

        The authenticity of host 'github.com (207.97.227.239)' can't be established.
        RSA key fingerprint is 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
        Are you sure you want to continue connecting (yes/no)?

   Verify the fingerprint in the message you see matches the following message, then type `yes`:

        Hi username! You've successfully authenticated, but GitHub does not
        provide shell access.

3. If the username in the message is yours, you've successfully set up your SSH key!
   If you receive a message about "access denied," you can [read these instructions for diagnosing the issue][].
   If you're switching from HTTPS to SSH, you'll now need to update your remote repository URLs. 
   For more information, see [Changing a remote's URL][].

[read these instructions for diagnosing the issue]: https://help.github.com/articles/error-permission-denied-publickey
[Changing a remote's URL]: https://help.github.com/articles/changing-a-remote-s-url

## Using SSH over HTTPS port
Sometimes, firewalls refuse to allow SSH connections entirely.
If using HTTPS cloning with credential caching is not an option,
you can attempt to clone using an SSH connection made over the HTTPS port.

To test if SSH over the HTTPS port is possible, run following SSH command.
If that worked, great! If not, you may need to follow troubleshooting guide.
```
$ ssh -T -p 443 git@ssh.github.com
```

