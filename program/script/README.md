
JSON 数据格式

* _数字_: `3, 12`
* _空值_: `null`
* _布尔值_: `false, true`
* _字符串_: `"abc" /* 必须用双引号 */`
* _数组_: `[3, null, "abc", [1, "a"], {"size":8, "data":"12345678"}]`
* _对象_: `{"size":8, "user":{"name":"john", "id":13}, "data":[1, 2]} /* 冒号前的名称必须使用双括号引起 */`

HTML 相关链接

* http://missingmanuals.com/cds/html5tmm2e
* http://caniuse.com/
* http://www.prosetech.com/html5/
* http://www.w3.org/TR/html5/
* https://html.spec.whatwg.org/multipage/
* http://validator.w3.org/
* http://dev.w3.org/html5/markup/
* http://gs.statcounter.com
* http://modernizr.com/docs/
* http://tinyurl.com/polyfill
* https://www.w3.org/WAI/
* http://html5doctor.com/
* http://gsnedders.html5.org/outliner/
* http://microformats.org/wiki/
* http://www.ietf.org/rfc/bcp/bcp47.txt

空元素

```
<img> <br> <wbr> <hr>
```

Special element
```html
Add
<article> <aside> <figcaption> <figure> <footer> <header> <nav> <section> <details> <summary>
<mark> <time> <wbr>
<datalist> <keygen> <meter> <progress> <command> <menu> <output>
<audio> <video> <source> <embed> <canvas>
<bdo> <rp> <rt> <ruby>
    
Delete
<big> <center> <font> <tt> <strike>

Remain
<iframe>
<abbr> is better than <acronym>
<object> is better than <applet>

Change
<small> small print
<hr> topic switch
<s> no longer correct or relative
<strong> important content
<em> read loudly
<b> should using bold font no matter important or not
<i> should using italic font no matter important or not
<address> only for contact info
<cite> only for the name of the book/article/news/show
<a> can contain anything like text/list/image
```

## Document structure

Structure element
```html
<header> page/article header, should contain a <h?> element
<footer> page/article footer, page footer usually can only contain copyright/links/law limitation
<nav> page navigation links, usually used in page <header> or page <aside>
<aside> page side column, article related content
<main> page main content
<article> a article, should contain <h?> elements
<section> a section of article, should contain <h?> elements
<hgroup> can only contain <h?> elements
<figure> insserted figure in the article
<figcaption> title of the figure, can contain any elements like text/link/image

<body>
<header></header>
<aside></aside>
<main><article></article><article></article></main>
<footer></footer>
</body>

Article header
<h1>...</h1>
<header>
  <img>
  <h1>...</h1>
  ...
</header>
<header>
  <h1>...</h1>
  <p class="subtitle">...</p>
  <p class="bywho">...</p>
  ...
</header>
<header>
  <hgroup>
    <h1>...</h1>
    <h2>...</h2>
  </hgroup>
  <p>...</p>
</header>
   
Article
<article>
<header></header>
<section></section>
<aside></aside>
<section></section>
<figure><figcaption></figcaption></figure>
<section></section>
<footer></footer>
</article>
```

Avoid old browaser apply inline to unknown elements
```css
article, aside, figure, figcaption, footer, section {
  display: block;
}
```

Avoid old browser dont apply styles to unknown elements
```html
<!-- create out new elements to ask IE to apply styles -->
<!--[if lt IE 9]> 
<script>document.createElement("header")</script>
<![endif]-->

<!--[if lt IE 9]>
<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
```

Document outline
```html
<body>
<h1>header1</h1>
<h1>header1</h1>
<h2>header2</h2>
<h3>header3</h3>
<h2>header2</h2>
<h4>header4</h4>
<h3>header3</h3>
</body>

- header1
- header1
  - header2
    - header3
  - header2
    - header4
    - header3
```

Sectioning element and Section root element
```html
<article> <aside> <nav> <section>
Each sectioning element ends the previous section and start a new section.
The headers <h?> in a section are independent from headers in other sections.
All headers in a section form a sub-outline, they combined together to form the document outline. 

<body> <blockquote> <td> <fieldset> <figure> <details>
The section root element has its own document outline, it's invisible to the main document outline.
The <body> element is a little different due to its outline is the main document outline.
```

Untitiled section
```html
<body>
  <article>
    <section>
      <h1>Titiled Section</h1>
      <h2>Header2</h2>
      <h2>Header2</h2>
    </section>
  </article>
</body>

- Untitiled Section <body>
  - Untitiled Section <article>
    - Titled Section
      - Header2
      - Header2
```

Titiled section
```html
<body>
  <h3>Body</h3>
  <article>
    <header><h1>Article</h1></header>
    <h1>Header1</h1>
    <h2>header2</h2>
    <h2>header2</h2>
  </article>
</body>

- Body
  - Article
  - Header1
    - Header2
    - Header2
```

A section has a level equal to the super section level + 1.
```html
<body>
  <article>
    <h3>Article</h3>
    <section><h1>Section</h1></section>
  </article>
</body>

- Untitled Section
  - Article
    - Section
    
<article>
  <h1>Article</h1>
    <h2>Header2</h2>
    <section><h1>Section1</h1></section>
</article>

- Untitled Section <body>
  - Article
    - Header2
    - Section1
  
<article>
  <h1>Article</h1>
    <h2>Header2</h2>
      <h3>Header3</h3>
    <section><h4>Section4</h4></section>
    <section><h3>Section3</h3></section>
    <section><h2>Section2</h2></section>
</article>

- Untitled Section <body>
  - Article
    - Header2
      - Header3 
    - Section4
    - Section3
    - Section2
```

A header has the same or a greater level as the section above it.
```html
<article>
  <h1>Article</h1>
  <h2>Header2</h2>
  <section>
    <h1>Section</h1>
    <h2>Section header2</h2>
    <h3>Section header3</h3>
  </section>
  <h3>Header3</h3>
</article>

- Untitled Section <body>
  - Article
    - Header2
    - Section  # the level is 2
      - Section header2
        - Section header3
    - Header3  # no greater than level2
 
<article>
  <h1>Article</h1>
  <h2>Header2</h2>
  <section>
    <h1>Section</h1>
    <h2>Section header2</h2>
    <h3>Section header3</h3>
  </section>
  <h1>Header1</h1>
</article>

- Untitiled Section <body>
  - Article
    - Header2
    - Section  # the level is 2
      - Section header2
        - Section header3
  - Header1    # is greater than level2
```

## Meaningful content
