
# 下载和编译

在下载Android源代码之前，确保系统满足以下需求：
- Linux或者Mac OS操作系统，Android内部编译测试使用的是Ubuntu LTS(14.04)
- Gingerbread(2.3.x)及以上版本需要64位系统，32位系统只能编译老版本
- 至少需要100G硬盘空间下载代码（checkout），150G进行单次编译（single build），
  200G或更多空间进行多次编译（multiple build）
- [Python](python.org) 2.6-2.7； [GNU](gnu.org) Make 3.81-3.82； [Git](git-scm.com) 1.7+；
  需要JDK7编译AOSP主分支（master branch），JDK6编译Gingerbread到KitKat版本，JDK5编译Cupcake到Froyo版本
  > $ python --version
  > $ make --version
  > $ git --version
  > $ java -version # need openjdk

## 搭建编译环境

编译环境的一些需求跟选择的源代码版本有关，见版本分支的[完整列表](http://source.android.com/source/build-numbers.html)。
你也可以选择下载和编译最新版本的源代码，最新版本所在分支成为主分支（master branch）。

