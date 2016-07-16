
cut sort wc uniq tr col join paste expand split xargs -

**df**
```shell
$ df -hl  # show human (-h) readable info about the local (-l) file systems
```

**du**
```shell
$ du -h                # show size of all files and directories in current folder
$ du -h folder/        # show size of all files and directories in the folder
$ du -h --max-depth=1  # only show first level files and directories in current folder
$ du -h folder/ -d 1   # only show first level files and directories in the folder
$ du -h mental/file    # show specific file's size
```

**cp**
```shell
$ cp --parents folder/struct/file.txt dest/folder/   # copy along with the folder structure
```

**rm**
```shell
$ rm -r folder/   # remove directories and their contents recursively
```

**tar**
```shell
$ tar zxf lpeg-1.0.0.tar.gz
```

**zip**
```shell
$ zip dest.zip file1 file2 file3  # compress specified files
$ zip dest.zip -r folder/         # compress all files in folder
$ unzip dest.zip                  # extract to current folder
$ unzip dest.zip -d folder/       # extract to specified folder
```

**head**
```shell
$ head a.txt b.txt   # show first 10 lines
$ head -n 13 a.txt   # show first 13 lines
$ head -c 100 file   # show first 100 bytes: 10k (10KB) 10m (10MB)
```

**tail**
```shell
$ tail a.txt b.txt   # show last 10 lines
$ tail -n a3 a.txt   # show last 13 lines
$ tail -f outfile    # continue show last lines of updating file
```

**less**
```shell
$ less largefile   # display with multiple pages
$ less -N file     # dispaly with line numbered

# q      # quit
# f      # forward one page
# b      # backward one page
# g      # go to first line
# G      # go to last line
# down   # next line
# up     # previous line
# left   # left one half screen
# right  # right half screen

# /patt  # search string with patt
# n      # next match
# N      # privous match

# m              # mark current position with a letter
mark: <letter>
# '<letter>      # go to a position related to the letter
# ''             # go to previous position
```

**find**
```shell
$ find folder -name name      # find directories or files contain the name
```

**grep**
```shell
$ grep -iE "str|str2" files   # grep files' content
$ pgrep ssh                   # grep current running processes

# grep strings started with `android.` in `.java` and `.aidl` files
$ grep -E "\"android\.*" $(find . | grep -E "*\.java|*\.aidl" |  tr "\n" " ")
```

**wc**
```shell
$ wc -l file   # count lines of the file
```

**cat**
```shell
# concatenate files, or stdin, to stdout
$ cat -b file1 file2        # concate file1 and file2 to stdout, number nonblank lines
$ cat -n file1 file2        # concate file1 and file2 to stdout, number all lines
$ cat << EOF                # concate stdin to stdout
$ cat file1 - file2 << EOF  # concate file1, stdin (only 1st '-` is valid), and file2 to stdout
$ cat file1 - file2 << EOF > newfile  # concate file1, stdin, file2, and output to newfile
$ cat file1 - file2 << EOF >> file    # concate file1, stdin, file2, and append to the file
$ tac file1 - file2 << EOF  # output from last line to first line
```

