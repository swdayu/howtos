HTTP/HTTPS

```
* 内容编码（Content-Encoding）表示对内容的压缩编码（如gzip），内容编码是可择的（如jpg/png一般不需要），而传输编码（Transfer-Encoding）则用来表示报文内容的格式
* HTTP协议中有一个重要的概念是持久连接或长连接，我们都知道HTTP运行在TCP之上，自然有TCP三次握手和慢启动等特性，为了尽可能提高HTTP性能，使用持久连接尤为重要
* HTTP/1.0中持久连接是后来引入的，通过 Connection: keep-alive 这个头部实现，服务器和客户端都可以使用它告诉对方在发送完数据之后不需要断开TCP连接以备后用
* HTTP/1.1则规定所有连接必须是持久的，除非显式的在头部加上 Connection: close，浏览器重用已经打开的空闲持久连接，可以避免缓慢的三次握手以及TCP慢启动的拥塞适应过程
* 对于非持久连接，浏览器可以通过连接是否关闭来界定请求或响应的边界；但对于持久连接这种方法行不通，一种方法是使用 Content-Length 告诉对方实际的长度
* 但如果不小心将长度设置的比实际长，浏览器又会一直傻傻的等待，另一个指定长度的坏处是如果你事先不知道内容的长度，必须将所有内容加载到内存才知道，可能必须使用很大的内存
* 在Web性能优化中，一个重要的指标叫 TTFB（Time To First Byte），就是客户端发出请求到收到响应的第一个字节所花费的时间，将所有内容都缓存起来再发送也无疑违背这个指标
* 在HTTP报文中，内容主体必须要在头部之后发送，为此我们需要一个新的机制，不依赖头部的长度信息也能知道内容的长度，传输编码（Transfer-Encoding）正是用来解决这个问题的
* 历史上 Transfer-Encoding 有多种取值，还为此定义了一个名为 TE 的头部用来协商采用哪种编码，但最新的HTTP规范里，只定义了一种传输编码：分块编码（chunked）
* 分块编码很简单，在头部加入 Transfer-Encoding: chunked 之后，报文的内容就由一个个的分块组成，连续的小块内容可以不断的发送给客户端，而无需等所有内容加载完才一次发送
* 每个分块包含十六进制的长度值和数据，长度独占一行不包括它后面的CRLF，也不包括分块数据结尾的CRLF，最后一个分块长度必须为0，对应的分块数据仅包含CRLF表示内容结束
---
HTTP用户识别的机种机制
* 承载用户身份信息的HTTP首部
* 客户端IP地址跟踪，通过用户的IP地址对其进行识别
* 用户登录，用认证方式来识别用户
* 胖URL，一种在URL中嵌入识别信息的技术
* cookie，一种功能强大且高效的持久身份识别技术

承载用户信息的HTTP首部
From: 用户email地址
User-Agent: 用户浏览器软件
Referer: 用户从那个页面依照链接跳转过来的
Authorization: 用户名和密码
Client-IP: 客户端IP地址
X-Forwarded-For: 客户端IP地址
Cookie: 服务器产生的ID标签

客户IP地址来识别用户存在着很多缺点， 限制了将其作为用户识别的效果：
- 客户端IP地址描述的是所用机器，而不是用户，如果多个用户共享同一台计算机，就无法进行区分
- 很多因特网服务提供商都会在用户登录时为其动态分配IP地址，用户每次登录时多会得到一个不同的地址，因此Web服务器不能假设IP地址可以在个登录回话之间标识用户
- 为了提高安全性，并对稀缺的地址资源进行管理，很多用户都是通过网络地址转换（NAT）防火墙来浏览网络内容的，这些NAT设备隐藏了防火墙后面那些实际客户端的IP
  地址，将实际的客户端IP地址转换成一个共享的防火墙IP地址（和不同的端口号）
- HTTP代理和网关通常会打开一些新的、到原始服务器的TCP连接。Web服务器看到的将是代理服务器的IP地址，而不是客户端的；有些代理为了绕过
  这个问题会添加特殊的Client-IP或X-Forward-For扩展首部来保存原始IP地址，但并不是所有的代理服务器都支持这种行为

少数站点甚至将客户端IP地址作为一种安全特性使用，它们只向来自特定IP地址的用户提供文档。
在内部网路中可以这么做，但是在因特网就不行了，主要是因为因特网上IP地址太容易伪造了。
路径上如果有拦截代理也会破坏方案，第14章将讨论一些强大得多的特权文档访问控制策略

Web服务器无需被动第根据用户的IP地址来猜测其身份，它可以要求用户通过用户名和密码进行认证（登录）来显式地询问用户是谁
为了是Web站点的登录更加简便，HTTP中包含了一种内建机制，可以用www-Authenticate首部和Authorization首部向Web站点传送用户的相关信息
一旦登录，浏览器就可以不断地在每条发往这个站点的请求中发送这个登录信息，这样就总是有登录信息可用，我们将在第12章对这种HTTP认证机制进行更详细的讨论
现在我们先来简单看看，如果服务器希望在为用户提供对站点的访问之前，先行登录，可以像浏览器回送一条HTTP响应代码 401 Login Required
然后，浏览器会显示一个登录对话框，并用Authorization首部在下一条对服务器的请求中提供这些信息，为了不让用户重复登录，大多数浏览器都会记住某站点的登录信息，
并将登录信息放在发送给该站点的每条请求中，说明用户名和密码。对用户名和密码进行加密，放置那些有意无意的网路观察者看到。
在第14章我们会看到，任何有这种想法的人，不用费多大事就可以轻易地将HTTP基本的认证用户名和密码破解出来，稍后将讨论一些更安全的技术

有些Web站点会为每个用户生成特定版本的URL来跟踪用户的身份
通常会对真正的URL进行扩展，在URL路径开始或结束的地方添加一些状态信息
用户浏览站点时，Web服务器会动态生成一些超链，继续维护URL中的状态信息
改动后包含了用户状态信息的URL被称为胖URL，下面是amazon.com电子商务使用的一些胖URL实例
每个URL后面都会附加了一个用户特有的标识码（如002-1145265-8016838)，这个标识码有助于用户浏览商店内容时对其进行跟踪
<a> href="/browse/-/229220/ref=gr_gifts/002-1145265-8016838">All Gifts</a>
可以通过胖URL将Web服务器上若干个独立的HTTP事务捆绑成一个“会话”或“访问”
用户首次访问这个Web站点时，会生成一个唯一的ID，用服务器可以识别的方式将这个ID添加到URL中去，然后服务器就会将客户端重新导向这个胖URL
不论什么时候，只要服务器收到了对胖URL的请求，就可以去查找与那个用户ID相关的所有增量状态（购物车、简介等），然后重写所有的输出超链，使其成为胖URL以维护用户ID
可以在用户浏览站点时，用胖URL对齐进行识别，但这种技术存在几个很严重的问题：
* 丑陋的URL，显示的胖URL会给新用户带来困扰
* 无法共享URL，胖URL中包含了与特定用户和回话相关的状态信息，如果将这个URL发送给其他人，可能就在无意中将你积累的个人信息都共享出去了
* 破坏缓存，为每个URL生成用户特定版本就意味着不再有可供公共访问的URL需要缓存了
* 额外的服务器负担，服务器需要重写HTML页面使URL变胖
* 逃逸口，用户跳转到其他站点或者请求一个特定URL时，就很容易在无意中“逃离”胖URL会话，
  只有当用户严格地追随预先修改过的链接时，胖URL才能工作，如果用户逃离次链接，就会丢失他的进展信息
* 在会话间是非持久的，除非用户收藏了特定的胖URL，否则用户退出登录，所有的信息都会丢失

Cookie是当前识别用户，实现持久会话的最好方式，前面各种技术中存在的很多问题对它们都没什么影响
但是通常会将它们与那些技术共用，以实现额外的价值，cookie最初是由网景公司开发的，但现在所有主要的浏览器都支持它
Cookie非常重要，而且它们定义了一些新的HTTP首部，所以我们要比前面那些技术更详细的家邵它们
Cookie的存在也影响了缓存，大多数缓存和浏览器都不允许对任何Cookie的内容进行缓存，后面的内容会对此做更为详细的介绍
可以笼统的将Cookie分为回话Cookie和持久Cookie两类，会话Cookie是一种临时的Cookie，它记录了用户访问站点时的设置和偏好
用户退出浏览器时，回话Cookie就被删除了，持久Cookie的生存时间更长一些，它们存储在硬盘上，浏览器退出，计算机重启时它们仍然存在
通常会用持久Cookie维护某个永辉会周期性访问的站点的配置文件或登录名
会话Cookie和持久Cookie之间唯一的区别就是它们的过期时间
稍后我们会看到，如果设置了Discard参数，或者没有设置Expires或Max-Age参数来说明扩展的过期时间，这个Cookie就是一个会话Cookie

Cookie就像服务器给用户贴的“嗨，我叫...“的贴纸一样，用户访问一个Web站点时，这个Web站点就可以读取那个服务器贴在用户身上的所有贴纸
用户首次访问Web站点时，Web服务器对用户一无所知，Web服务器希望这个用户会再次回来，所以想给这个用户”拍上“一个独有的Cookie
Cookie中包含了一个”名字=值"这样的信息构成的任意列表，并通过Set-Cookie或Set-Cookie2响应首部将其贴到用户身上去
Cookie中可以包含任意信息，但它们通常都只包含一个服务器为进行跟踪而产生的独特识别码
比如，服务器会将一个表示id="34294"的cookie贴到用户上去，服务其可以用这个数字来查找服务器为其访问者积累的数据库信息
但是Cookie并不仅限于ID号，很多Web服务器都会将信息直接保存在Cookie中，比如 name="Brian Totty"; phone="555-1212"
浏览器会记住从服务器返回的Set-Cookie或Set-Cookie2首部中的Cookie内容，并将Cookie集存储在浏览器的Cookie数据库中
将来用户返回同一个站点时，浏览器会挑中那个服务器贴到用户上的那些Cookie，并在一个Cookie强求首部中将其传回去

公开密钥加密技术
双方都拥有自己才知道的私有密钥，而使用公开的公有密钥对数据进行加密解密
节点X可以公开一个公有密钥，任何想像节点X发送报文的人都可以使用相同的公开密钥了
尽管每个人都可以用同一个公有密钥对发给X的报文进行编码，但除了X其他人都无法对报文进行解码
因为只有X才有与该公有密钥配对的私有密钥，只有该私有密钥才能对数据进行解密
这样，各节点向服务器安全地发送报文就更加容易了，因为它们只需要查找到服务器的公开密钥就行了
制定标准化的公开密钥技术包是非常重要的，因此大规模的公开密钥(Public-Key Infrastructure, PKI)标准创建工作已经开展十多年了

所有公开密钥非对称加密系统所面临的共同挑战是，要确保即便有人拥有了下面所有的线索，也无法计算出保密的私有密钥
* 公开密钥，是公开的，所有人都可以获得
* 一小片拦截下来的密文，可通过对网络的嗅探获取
* 一条报文及与之相关的密文（对任意一段文本运行加密器就可以得到）
RSA算法就是一个满足了所有这些条件的流行的公开密钥加密系统，它是在MIT发明的，后来由RSA数据安全公司将其商业化
即使有了公共密钥、任意一段密文、用公共密钥对明文编码之后得到的相关密文、RSA算法自身、甚至RSA实现的源代码，
破解代码找到对应的私有密码的难度仍相当于对一个极大的数进行质因数分解的困难程度，这种计算被认为是所有计算机科学中最难的问题之一
但公开密钥加密算法的计算可能会很慢，实际上它混合使用了对称和非对称策略
比如比较常见的做法是在两个节点之间通过便捷的公开密钥加密技术建立起安全通信，然后再用那条安全通常产生并发送临时的随机对称密钥，
通过更快的对称加密技术对其余的数据进行加密

用证书对服务器进行认证
通过HTTPS建立一个安全Web事务之后，现代浏览器都会自动获取所连接服务器的数字证书
如果服务器没有证书，安全连接就会失败，服务器证书包含很多字段，其中包含：Web站点的名称和主机名，Web站点的公开密钥，签名颁发机构的名称，来自签名机构的签名
浏览器收到证书时会对签名颁发机构进行检查，如果这个机构是很有权威的公共签名机构，浏览器可能已经知道其公开密钥了（浏览器会预先安装很多签名颁发机构的证书）
如果对签名颁发机构一无所知，浏览器就无法确定是否应该信任这个签名颁发机构，它通常会向用户显示一个对话框，看看是否相信这个签名发布者，签名发布者可能是本地的IT部门或软件厂商
浏览器和其他因特网应用程序都会尽量隐藏大部分证书管理的细节，是的浏览更加方便
但通过安全连接进行浏览时，所有主要的浏览器都允许你自己去检查所有对话站点的证书，以确保所有内容都是诚实可信的

HTTPS是最常见的HTTP安全版本，它得到了很广泛的应用，所有主要的商业浏览器和服务器上都提供HTTPS
HTTPS将HTTP协议与一组强大的对称、非对称和基于证书的加密技术结合在一起，是的HTTPS不仅很安全，而且很灵活，很容易在处于无序状态的、分散的全球互联网上进行管理
HTTPS就是在安全的传输层上发送的HTTP，它在将HTTP报文发送给TCP之前，先将其发送给一个安全层，对其进行进行加密
现在，HTTP安全层是通过SSL及其现代替代协议TLS来实现的，我们遵循常见的用法，用术语SSL来表示SSL或者TLS
如果URL方案为HTTPS，客户端就会打开一条到服务器端口443（默认情况下）的连接，然后与服务器“握手”，以二进制格式与服务器交换一些SSL安全参数，附上加密的HTTP命令
SSL是个二进制协议，与HTTP完全不同，其流量是承载在另一个端口上的（SSL通常是由端口443承载的）
如果SSL和HTTP流量都从端口80到达，大部分Web服务器会将二进制SSL流量理解为错误的HTTP并关闭连接
将安全服务进一步整合到HTTP层中去就无需使用多个目的端口了，在实际中这样不会引发严重的问题，我们来详细介绍下SSL是如何与安全服务其建立连接的
```
