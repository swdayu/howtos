
# cat

```
$ cat [OPTION]... [FILE]...
# Concatenate FILE(s), or standard input, to standard output.
# With no FILE, or when FILE is -, read standard input.

-b, --number-nonblank     number nonempty output lines, override -n
-n, --number              number all output lines
```

Create a new file and append content.
```
cat > new_file << DELIMITER
> enter the first line of text
> enter the last line of text
> DELIMITER
```

Append content to a file.
```
cat >> a_file << END
> append the first line of text
> append last line of text
> END
```

Dispaly file content.
```
cat a_file
```
