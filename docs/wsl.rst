
使用WSL2的两个前提，第一个是开启CPU虚拟化，任务管理器打开CPU性能，看虚拟化是否已启用，
如果没有开启，需要打开BIOS找到英特尔VMX虚拟化平台或AMD的AMD-v的开关开启就行了。第二个
前提是开启两个Windows 功能，在任务栏搜索功能，点击开启或关闭Windows功能，勾选上适用于
Linux的Windows子系统，以及虚拟机平台。

WSL相关命令： ::

    wsl --help
    wsl --install --web-download # 默认下载的发行版本是Ubuntu，但也可以下载其他的
    wsl --list --online # 这里列出了所有可按装的发行版
    wsl --install kali-linux --web-download
    wsl --list -v
    wsl --set-default kali-linux # 默认切换到 kali-linux 发行版
    wsl -d Ubuntu-20.04 # 启动
    exit # 退出子系统
    wsl --unregister kali-linux # 卸载
    wsl --export Ubuntu-20.04 ubuntu.tar # 备份系统
    wsl --import Ubuntu2 dir/ ubuntu.tar # 导入备份的系统，导入后的是一个镜像文件，
                                         # 所有的东西都在这个镜像文件里
    df -h # 可以列出子系统中所有的挂在卷
    wsl --shutdown # 等个8秒关闭所有的wsl服务

WSL2可以直接使用 wsl.exe --install 进行按照，如果你已经有了 wsl1，可以使用以下命令进
行升级： ::

    wsl.exe --list -v
    wsl.exe --set-version Ubuntu<ver_name> 2
    wsl.exe --set-default-version 2 # 设置 wsl 的默认版本为 wsl2
    wsl.exe --version # 查看版本信息
    wsl.exe --status  # 查看wsl状态
    wsl.exe --update  # 更新wsl
    wsl.exe --help    # 获取帮助

wsl1 不支持允许 Linux 32-bit 程序，需要使用 wsl2 因为 wsl2 更接近原生的 Linux 系统。
Ubuntu 64系统运行32位程序，需要设置： ::

    # 添加对32位架构的支持
    sudo dpkg --add-architecture i386
    sudo apt update

    # 安装 32 位运行时库
    sudo apt install libc6:i386 libncurses5:i386 libstdc++6:i386
    sudo apt install zlib1g:i386 zlib1g-dev:i386

    # 如果失败尝试
    sudo apt install gcc-multilib

在Windows上如何查看Linux文件，打开文件资源管理器在我的电脑下面有一个小企鹅，把它展开里
面就是各个子系统的文件列表。

WSL的一个神奇之处是在Windows里可以直接运行Linux命令，在Linux里又可以直接运行Windows程
序。例如可以在子系统中使用nodepad.exe test.txt编辑文件，然后使用Linux中的vi修改文件。
例如还可以在子系统里使用 explorer.exe . 这样Ubuntu的文件系统就以Windows资源管理器的形
式打开了。我们可以在Windows里使用Linux命令，例如在CMD里 dir | wsl grep file 在 dir 
列出的文件中使用linux的grep对结果进行刷选。

WSLg 运行Linux里带UI界面的程序直接以Windows窗口的形式打开，WSLg是利用了RDP远程桌面协
议。

GIMP是一个Linux免费的图形编辑软件，类似于Photoshop，在子系统里安装它的Linux版本； ::

    sudo apt-get install gimp
    gimp # 然后窗口就打开了

还有黑科技就是显卡直通，可以使用 nvidia-smi 看一下显卡，这个显卡配好了驱动配好的CUDA就
直接出现在Linux系统里面了，也就是我们以后运行一些Linux版本的AI大模型，直接使用这个
Linux 子系统，它就可以自动识别出这个显卡，没有任何虚拟机的显卡直通比这个方式更丝滑了。

在讲一个Kali linux专属的黑科技 KEX，我们在 Kali linux下面输入这个命令： ::

    sudo apt install kali-win-kex
    kex --esm --ip -sound

这里利用远程桌面的形式连接进了这个Linux 系统，Kali这个系统又很多网络相关的工具，感兴趣
的可以找来研究研究。我们再看Ubuntu远程桌面的连接，这里我们不建议使用wsl的方式，很复杂而
且很容易踩坑，这里我们建议使用Hyperv，在Hyperv管理器里面，在任务栏搜素Hyperv就可以找
到，点击快速创建，然后我们选择Ubuntu版本，点击创建虚拟机就可以了，一键使用也是非常的简
单方便，这个不会踩坑。

WSL的一些高级配置，WSL有两种配置文件，一个是 wsl.conf 另一个是 .wslconfig，
.wslconfig 是一个Windows文件，用于在WSL2上对所有已安装的发行版进行一个全局的配置，而
wsl.conf是某个子系统独立的本地设置。配置的8秒原则，也就是更改完配置以后，就要使用
wsl --shutdown 命令把Linux子系统关闭等8秒以后重启才能生效。

使用 .wslconfig 可以修改网络配置，可以将Linux子系统的ip设成Windows的镜像，完全一样的
ip： ::

    ifconfig # 查看Linux的网络配置，看它的网段
    ipconfig # 可以查看宿主机Windows的配置，可能两个系统不在同一个网段上，
             # 局域网的其他设备就访问不到这个WSL2这个虚拟机的
    cd C:\Users\<usrname> # 我们可以修改配置改成镜像网络，也就是让我的虚拟机跟
                          # Windows系统共用同一个IP地址

    创建.wslconfig
    [wsl2]
    networkingMode=mirrored

    wsl --shutdown
