
嵌套字符串
----------

字符串起始括号与结束括号不同，可以让字符串自然嵌套而无需转义。例如 m4 语法： ::

    define(`a', `a')
    ifelse(a, `a', `a==a', a, `b', `a==b', `a==?')

    define(`my_if_else', `ifelse(`$1', `a', `a==a', `$1', `b', `a==b', `a==?')')
    my_if_else(a)   /* a==a */
    my_if_else(b)   /* a==b */

如果使用区别明显的括号比如尖括号，可以更清晰看到括号的嵌套： ::

    define(«my_if_else», «ifelse(«$1», «a», «a==a», «$1», «b», «a==b», «a==?»)»)

原子操作
--------

当多个线程访问一个原子对象时，所有的原子操作都会针对该原子对象产生明确的行为：在任何其他原子操作能够访问该对象之前，每个原子操作都会在该对象上完整地执行完毕。这就保证了在这些对象上不会出现数据竞争，而这也正是定义原子性的关键特征。

标准库 <stdatomic.h> 提供的功能： ::

    atomic_flag
    atomic_bool         _Atomic _Bool
    atomic_int          _Atomic int
    atomic_uint         _Atomic unsigned int
    atomic_intptr_t     _Atomic intptr_t
    atomic_uintptr_t    _Atomic uintptr_t
    atomic_size_t       _Atomic size_t
    atomic_ptrdiff_t    _Atomic ptrdiff_t

    atomic_char         _Atomic char
    atomic_schar        _Atomic signed char
    atomic_uchar        _Atomic unsigned char
    atomic_short        _Atomic short
    atomic_ushort       _Atomic unsigned short
    atomic_int          _Atomic int
    atomic_uint         _Atomic unsigned int
    atomic_long         _Atomic long
    atomic_ulong        _Atomic unsigned long
    atomic_llong        _Atomic long long
    atomic_ullong       _Atomic unsigned long long
    atomic_char8_t      _Atomic char8_t
    atomic_char16_t     _Atomic char16_t
    atomic_char32_t     _Atomic char32_t
    atomic_wchar_t      _Atomic wchar_t
    atomic_intmax_t     _Atomic intmax_t
    atomic_uintmax_t    _Atomic uintmax_t

    bool atomic_is_lock_free(const atomicT* a);
    void atomic_init(volatile atomicT* a, T v);

    函数 atomic_is_lock_free() 判断上面的类型是否是无锁类型。atomic_init() 对
    原子类型变量进行初始化，该操作不是原子操作，并且对已经初始化的原子变量再次调用
    该函数会导致未定义行为。

**store load** ::

    void atomic_store(volatile atomicT* a, T v);
    void atomic_store_explicit(volatile atomicT* a, T v, memory_order sync);

    原子写操作，保证某种内存顺序，默认是 memory_order_seq_cst：
    - memory_order_seq_cst 顺序一致（sequentially consistent），在所有可能对
      所涉及的其他线程有可见副作用的内存访问都已经发生之后，所有使用该内存顺序的
      操作才按照一定的排序发生。这是最严格的内存顺序，它保证尽管有非原子内存访问
      线程交互之间出现最少的不预期副作用。
    - memory_order_release 适用于存储操作，该操作被安排在 consume 或 acquire
      操作之前发生，充当可能对加载线程（loading thread）有可见副作用的其他内存访
      问的一个同步点。
    - memory_order_relaxed 该操作规定在某个时刻以原子方式发生。这是最宽松的内存
      顺序，对于不同线程中的内存访问相对于原子操作的顺序没有任何保证。

    T atomic_load(const volatile atomicT* a);
    T atomic_load_explicit(const volatile atomicT* a);

    原子读操作，保证某种内存顺序，默认是 memory_order_seq_cst
    - memory_order_consume 适用于加载操作，当释放线程中所有对于释放操作存在依
      赖关系（并且对加载线程有可见副作用）的内存访问都已完成之后，该操作才被安排
      发生。
    - memory_order_acquire 适用于加载操作，当释放线程中所有对内存的访问（对加
      载线程有可见副作用）都已完成之后，该操作才被安排发生。
    - memory_order_relaxed 宽松内存顺序。

**fetch_add fetch_or fetch_xor** ::

    T atomic_fetch_add/sub/or/xor(volatile atomicT* a, T v);
    T atomic_fetch_add/sub/or/xor_explicit(..., memory_order sync);

    原子的完成读值和相加/相减/位或/异或操作，返回修改前的值，默认使用
    memory_order_seq_cst 内存顺序。

**exchange compare_exchange** ::

    T atomic_exchange(volatile atomicT* a, T v);
    bool atomic_compare_exchange_weak(volatile atomicT* a, T* expected, T v);
    bool atomic_compare_exchange_strong(volatile atomicT* a, T* expected, T v);

    T atomic_exchange_explicit(..., memory_order sync);
    bool atomic_compare_exchange_weak_explicit(..., memory_order sync);
    bool atomic_compare_exchange_strong_explicit(..., memory_order sync);

    原子的修改变量的值，并返回修改前的值，对比 atomic_store 只会写操作不会返回原来
    的值。compare_exchange 读取变量的值并与 expected 比较，如果相等将原子值写为v
    并返回 true，如果不相等则将原子值写入到 expected 中并返回 false。对于弱版本来
    说，允许在相等的情况下返回 false。

    请注意，compare_exchange 直接将所包含值的实际内容与 expected 的内容进行比较；
    对于那些使用 operator== 比较时相等的值（如果基础类型具有填充位、陷阱值或同一值
    的不同表示形式），这可能会导致比较失败。

    与 atomic_compare_exchange_strong 不同，atomic_compare_exchange_weak即使在
    expected 确实与 obj 中包含的值相等的情况下，也允许通过返回 false 来虚假地失败。
    对于某些循环算法而言，这可能是可接受的行为，并且在某些平台上可能会带来显著更好的
    性能。在这些虚假失败的情况下，该函数返回 false，同时不会修改 expected。对于非
    循环算法，通常更倾向于使用 atomic_compare_exchange_strong。

    与 atomic_compare_exchange_weak 不同，当 expected 确实与所包含的对象相等时，
    atomic_compare_exchange_strong 必须始终返回 true，不允许出现虚假失败的情况。
    然而，在某些机器上，对于某些在循环中检查此情况的算法，compare_exchange_weak
    可能会带来显著更好的性能。

**clear test_and_set** ::

    atomic_flag lock_acquire = ATOMIC_FLAG_INIT;
    void atomic_flag_clear(volatile atomic_flag* a);
    bool atomic_flag_test_and_set(volatile atomic_flag* a);

    void atomic_flag_clear_explicit(..., memory_order sync);
    bool atomic_flag_test_and_set_explicit(..., memory_order sync);

    ATOMIC_FLAG_INIT 初始化为清位状态，atomic_flag_clear() 对原子标志进行清位，
    atomic_flag_test_and_set() 对原子标志进行置位，返回修改前的值，返回true表示
    在函数读取前的一瞬间已经置位，该函数对标志的读取-修改-写入这个过程是原子的。

标准头文件
----------

**assert.h** ::

    #ifdef NDEBUG
    #define assert(condition) ((void)0)
    #else
    #define assert(condition) /*implementation-defined*/
    #endif

**ctype.h** ::

    isalnum     checks if a character is alphanumeric
    isalpha     checks if a character is alphabetic
    islower     checks if a character is lowercase
    isupper     checks if a character is an uppercase character
    isdigit     checks if a character is a digit
    isxdigit    checks if a character is a hexadecimal character
    iscntrl     checks if a character is a control character
    isgraph     checks if a character is a graphical character
    isspace     checks if a character is a space character
    isblank     checks if a character is a blank character
    isprint     checks if a character is a printing character
    ispunct     checks if a character is a punctuation character
    tolower     converts a character to lowercase
    toupper     converts a character to uppercase

**stdarg.h** ::

    va_list ap;
    va_start(ap, start_arg);
    type va_arg(ap, type);
    va_copy(dest, src_ap);
    va_end(ap);

**stdint.h** ::

    int8_t
    int16_t
    int32_t
    int64_t
    uint8_t
    uint16_t
    uint32_t
    uint64_t
    intptr_t
    uintptr_t

    INT8_MIN INT8_MAX UINT8_MAX
    INT16_MIN INT16_MAX UINT16_MAX
    INT32_MIN INT32_MAX UINT32_MAX
    INT64_MIN INT64_MAX UINT64_MAX
    INTPTR_MIN INTPTR_MAX UINTPTR_MAX

**stddef.h** ::

    ptrdiff_t
    size_t
    NULL
    offsetof

**stdlib.h** ::

    atof atoi atol atoll
    strtod strtof strtol strtold strtoll strtoul strtoull
    rand srand
    calloc free malloc realloc
    abort atexit at_quick_exit exit getenv quick_exit system _Exit
    bsearch qsort
    abs div labs ldiv llabs lldiv
    mblen mbtowc wctomb mbstowcs wcstombs
    EXIT_FAILURE EXIT_SUCCESS MB_CUR_MAX NULL RAND_MAX

**stdio.h** ::

    remove rename tmpfile tmpnam
    fclose fflush fopen freopen setbuf setvbuf
    fprintf printf snprintf sprintf vfprintf vprintf vsnprintf vsprintf
    fscanf scanf sscanf vfscanf vscanf vsscanf
    fgetc fgets fputc fputs getc getchar gets ungetc
    putc putchar puts
    fread fwrite
    fgetpos fseek fsetpos ftell rewind
    clearerr feof ferror perror
    BUFSIZ EOF FILENAME_MAX FOPEN_MAX L_tmpnam NULL TMP_MAX

**string.h** ::

    void* memcpy(void* s1, const void* s2, size_t n);
    void* memccpy(void* s1, const void* s2, int c, size_t n);
    void* memmove(void* s1, const void* s2, size_t n);
    char* strcpy(char* s1, const char* s2);
    char* strncpy(char* s1, const char* s2, size_t n);
    char* strdup(const char* s);
    char* strndup(const char* s, size_t n);
    char* strcat(char* s1, const char* s2);
    char* strncat(char* s1, const char* s2, size_t n);
    int memcmp(const void* s1, const void* s2, size_t n);
    int strcmp(const char* s1, const char* s2);
    int strcoll(const char* s1, const char* s2);
    int strncmp(const char* s1, const char* s2, size_t n);
    size_t strxfrm(char* s1, const char* s2, size_t n);
    void* memchr(void* s, int c, size_t n);
    qchar* strchr(qchar* s, int c);
    size_t strcspn(const char* s1, const char* s2);
    qchar* strpbrk(qchar* s1, const char* s2);
    qchar* strrchr(qchar* s, int c);
    size_t strspn(const char* s1, const char* s2);
    qchar* strstr(qchar* s1, const char* s2);
    char* strtok(char* s1, const char* s2);
    void* memset(void* s, int c, size_t n);
    void* memset_explicit(void* s, int c, size_t n);
    char* strerror(int errnum);
    size_t strlen(const char* s);
    size_t strnlen(const char* s, size_t n);

    errno_t memcpy_s(void* s1, rsize_t s1max, const void* s2, rsize_t n);
    errno_t memmove_s(void* s1, rsize_t s1max, const void* s2, rsize_t n);
    errno_t strcpy_s(char* s1, rsize_t s1max, const char* s2);
    errno_t strncpy_s(char* s1, rsize_t s1max, const char* s2, rsize_t n);
    errno_t strcat_s(char* s1, rsize_t s1max, const char* s2);
    errno_t strncat_s(char* s1, rsize_t s1max, const char* s2, rsize_t n);
    char* strtok_s(char* s1, rsize_t* s1max, const char* s2, char** ptr);
    errno_t memset_s(void* s, rsize_t smax, int c, rsize_t n)
    errno_t strerror_s(char* s, rsize_t maxsize, errno_t errnum);
    size_t strerrorlen_s(errno_t errnum);
    size_t strnlen_s(const char* s, size_t maxsize);
