
# Loaders
- [Loader API Summary](./loader-api.md)
- [Using Loaders in an Application](./using-loader.md)
- [Example](./loader-example.md)

Introduced in Android 3.0, loaders make it easy to asynchronously load data in an activity or fragment. 
Loaders have these characteristics:
- They are available to every Activity and Fragment.
- They provide asynchronous loading of data.
- They monitor the source of their data and deliver new results when the content changes.
- They automatically reconnect to the last loader's cursor when being recreated after a configuration change. 
  Thus, they don't need to re-query their data.

Loader主要用于在Avtivity或Fragment中异步加载数据。
Loader的一些特性如下：
- 对于每个Activity和Fragment都可用
- 提供异步加载数据功能
- 会监控数据源头，内容改变时传递新结果
- 变更系统配置重新创建对象时，Loader会自动重连关联到原来的数据游标处。
  因此不需要重新查询数据。
  
