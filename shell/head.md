
# HEAD


## Output first 10 lines
```
$ head c.txt
     1       1  input line for c.txt
     2       2  input line for c.txt
     3       3
     4       4  input line for c.txt
     5       5  input line for c.txt
     6       6  input line for c.txt
     7       7
     8       8  input line for c.txt
     9       1  input line for c.txt
    10       2  input line for c.txt

$ head c.txt d.txt # multiple files
==> c.txt <==
     1       1  input line for c.txt
     2       2  input line for c.txt
     3       3
     4       4  input line for c.txt
     5       5  input line for c.txt
     6       6  input line for c.txt
     7       7
     8       8  input line for c.txt
     9       1  input line for c.txt
    10       2  input line for c.txt

==> d.txt <==
     1       1  input line for c.txt
     2       2  input line for c.txt
     3       3
     4       4  input line for c.txt
     5       5  input line for c.txt
     6       6  input line for c.txt
     7       7
     8       8  input line for c.txt
     9       1  input line for c.txt
    10       2  input line for c.txt
```

## Display first `n` lines
```
$ head -n 13 c.txt
     1       1  input line for c.txt
     2       2  input line for c.txt
     3       3
     4       4  input line for c.txt
     5       5  input line for c.txt
     6       6  input line for c.txt
     7       7
     8       8  input line for c.txt
     9       1  input line for c.txt
    10       2  input line for c.txt
    11       3
    12       4  input line for c.txt
    13       5  input line for c.txt
```

## Display first 'n' bytes
```
# Bytes can be for example 100 (100B), 10k (10KB), 10m (1MB)
$ head -c 100 c.txt 
     1       1  input line for c.txt
     2       2  input line for c.txt
     3       3
     4       4  i
```
