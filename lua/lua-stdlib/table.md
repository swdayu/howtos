
## Table Manipulation

This library provides generic functions for table manipulation. 
It provides all its functions inside the table `table`.

Remember that, whenever an operation needs the length of a table, 
the table must be a proper sequence or have a `__len` metamethod (see §3.4.7). 
All functions ignore non-numeric keys in the tables given as arguments. 

该库提供对表的一般操作。所有函数都导出在表`table`中。
当操作获取表的长度时，表必须可以看成是一个序列或拥有`__len`元函数。
所有函数都会忽略表参数的非数值键。

### table.concat 
```lua
concat(list [, sep [, i [, j]]])
-- return the string of `list[i]..sep..list[i+1]··· sep..list[j]`
-- or empty string if `i` is greater than `j`
```

Given a `list` where all elements are strings or numbers, 
returns the string `list[i]..sep..list[i+1] ··· sep..list[j]`. 
The default value for `sep` is the empty string, the default for `i` is 1, 
and the default for `j` is `#list`. 
If `i` is greater than `j`, returns the empty string.

将包含字符串和数值的列表每个元素连接起来，并用`sep`分隔，返回拼接后的字符串。
`sep`默认为空字符串，`i`默认是1，`j`默认是表的长度`#list`。
如果`i`大于`j`则返回空字符串。

### table.insert 
```lua
insert(list, [pos,] value)
-- insert the `value` into the position of `pos`
-- @pos: default value is `#list+1`
```

Inserts element `value` at position `pos` in `list`, 
shifting up the elements `list[pos], list[pos+1], ···, list[#list]`. 
The default value for `pos` is `#list+1`, 
so that a call `table.insert(t,x)` inserts `x` at the end of list `t`.

将元素插入到表的`pos`位置，其之后的元素都向后移动一位。
`pos`的默认值是`#list+1`，因此`table.insert(t,x)`将`x`插入到表的末尾。

### table.move 
```lua
move(a1, f, e, t [,a2])
-- move elements from `a1[f..e]` to `a2[t..]`
```

Moves elements from table `a1` to table `a2`. 
This function performs the equivalent to the following multiple assignment: 
`a2[t],··· = a1[f],···,a1[e]`. The default for `a2` is `a1`. 
The destination range can overlap with the source range. 
The number of elements to be moved must fit in a Lua integer.

将元素`a1[f..e]`移动到`a2[t..]`，表`a2`的默认值是`a1`。
目的范围可以与源范围重叠，移动的元素个数必须在Lua整数的表示范围内。

### table.remove 
```lua
remove(list [, pos])
-- remove the element a the `pos`
-- @pos: default value is `#list`
```

Removes from `list` the element at position `pos`, returning the value of the removed element. 
When `pos` is an integer between 1 and `#list`, 
it shifts down the elements `list[pos+1], list[pos+2], ···, list[#list]` and erases element `list[#list]`; 
The index `pos` can also be 0 when `#list` is 0, or `#list + 1`; 
in those cases, the function erases the element `list[pos]`.

The default value for `pos` is `#list`, so that a call `table.remove(l)` removes the last element of list `l`.

将表中`pos`位置的元素移除掉，`pos`之后的元素向前移动一位。
默认`pos`的值为`#list`，因此`table.remove(l)`表示移除表的最后一个元素。

### table.sort 
```lua
sort(list [, comp])
-- sort the table using `comp` or operator `<`
```

Sorts list elements in a given order, in-place, from `list[1]` to `list[#list]`. 
If `comp` is given, then it must be a function that receives two list elements 
and returns true when the first element must come before the second in the final order 
(so that not `comp(list[i+1],list[i])` will be true after the sort). 
If `comp` is not given, then the standard Lua operator `<` is used instead.

The sort algorithm is not stable; that is, elements considered equal by the given order 
may have their relative positions changed by the sort.

对表的元素进行排序。
如果指定了`comp`，这个函数必须接收两个表元素，并且当第一个元素需要排在第二个元素之前时返回`true`。
如果`comp`没有指定，则使用Lua标准操作`<`。
排序算法是不稳定的，即相等元素的相对位置在排序后可能会改变。

### table.pack 
```lua
pack(···)
-- return a new table with all parameters 
-- and the number of parameters
```

Returns a new table with all parameters stored into keys 1, 2, etc. 
and with a field "n" with the total number of parameters. 
Note that the resulting table may not be a sequence.

返回包含所有参数的表，以及参数的个数。

### table.unpack 
```lua
unpack(list [, i [, j]])
-- return all elements in `list[i..j]`
-- @i@j: default value is 1 and `#list`
```

Returns the elements from the given list. 
This function is equivalent to
```lua
return list[i], list[i+1], ···, list[j]
```
By default, `i` is `1` and `j` is `#list`. 

返回给定表中的元素，相当于`return list[i], list[i+1], ..., list[j]`。
参数`i`的默认值是1，`j`的默认值是`#list`。

