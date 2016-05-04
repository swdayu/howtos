
# 路径搜索

在对应文件夹（包含子文件夹）下查找对应目录名或文件名：
```
$ find folder -name filename
```

模糊查找目录名或文件名：
```
$ find folder -name *file*
```

# 文本查找

在对应文件中找出包含"str1"或"str2"的行：
```
$ grep -E "str1|str2" filename
```

忽略大小写：
```
$ cat file.txt | grep -i str1
```

# 统计行数
```shell
$ wc -l file.txt
```
