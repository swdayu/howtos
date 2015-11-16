
# TAIL

## Display last 10 lines
```
$ tail c.txt
   111       7
   112       8  input line for c.txt
   113       1  input line for c.txt
   114       2  input line for c.txt
   115       3
   116       4  input line for c.txt
   117       5  input line for c.txt
   118       6  input line for c.txt
   119       7
   120       8  input line for c.txt
   
$ tail c.txt d.txt # multiple files
==> c.txt <==
   111       7
   112       8  input line for c.txt
   113       1  input line for c.txt
   114       2  input line for c.txt
   115       3
   116       4  input line for c.txt
   117       5  input line for c.txt
   118       6  input line for c.txt
   119       7
   120       8  input line for c.txt

==> d.txt <==
   991       7
   992       8  input line for c.txt
   993       1  input line for c.txt
   994       2  input line for c.txt
   995       3
   996       4  input line for c.txt
   997       5  input line for c.txt
   998       6  input line for c.txt
   999       7
  1000       8  input line for c.txt
```

## Display last `n` lines
```
$ tail -n 3 c.txt
   118       6  input line for c.txt
   119       7
   120       8  input line for c.txt
```

## Continuously show last lines without exit
```
# Continuously show last lines in Terminal A
$ tail -f c.txt
   111       7
   112       8  input line for c.txt
   113       1  input line for c.txt
   114       2  input line for c.txt
   115       3
   116       4  input line for c.txt
   117       5  input line for c.txt
   118       6  input line for c.txt
   119       7
   120       8  input line for c.txt
   
# Edit c.txt in Terminal B
$ cat << EOF >> c.txt
>    121 update line for c.txt
>    122 update line for c.txt
> EOF

# The content in Terminal A auto updated
$ tail -f c.txt
   111       7
   112       8  input line for c.txt
   113       1  input line for c.txt
   114       2  input line for c.txt
   115       3
   116       4  input line for c.txt
   117       5  input line for c.txt
   118       6  input line for c.txt
   119       7
   120       8  input line for c.txt
   121 update line for c.txt
   122 update line for c.txt
```
