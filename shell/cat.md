
# cat

```
$ cat [OPTION]... [FILE]...
# Concatenate FILE(s), or standard input, to standard output.
# With no FILE, or when FILE is -, read standard input.

-b, --number-nonblank     number nonempty output lines, override -n
-n, --number              number all output lines
```

Output from input.
```
$ cat
input line one
input line one
input line two
input line two

# Multiple input lines util reach "EOF"
$ cat << EOF
> input line one
> input line two
> EOF
input line one
input line two
```

Output from files.
```
$ cat a.txt b.txt
file a content
file b content
```

Output from files and standard input.
```
$ cat a.txt - b.txt << EOF
> input line one
> input line two
> EOF
file a content
input line one
input line two
file b content

# when with multiple (-), only the first one is valid
$ cat a.txt - b.txt - a.txt - b.txt << EOF
> input line one
> input line two
> EOF
file a content
input line one
input line two
file b content
file a content
file b content
```

Redirect standard output to file.
```
# Truncate the file (create a new one if isn't exist) and output to the file
$ cat << EOF > c.txt
> input line one for c.txt
> input line two for c.txt
> EOF
$ cat c.txt
input line one for c.txt
input line two for c.txt

# Append to a file (creat a new one if isn't exist)
$ cat << EOF >> c.txt
> input line three for c.txt
> EOF
$ cat c.txt
input line one for c.txt
input line two for c.txt
input line three for c.txt

$ cat << EOF > c.txt
> input line one for c.txt truncate
> EOF
$ cat c.txt
input line one for c.txt truncate

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
