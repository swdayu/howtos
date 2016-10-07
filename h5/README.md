# HTML5

- http://missingmanuals.com/cds/html5tmm2e
- http://caniuse.com/
- http://www.prosetech.com/html5/
- http://www.w3.org/TR/html5/
- https://html.spec.whatwg.org/multipage/
- http://validator.w3.org/
- http://dev.w3.org/html5/markup/
- http://gs.statcounter.com
- http://modernizr.com/docs/
- http://tinyurl.com/polyfill
- https://www.w3.org/WAI/
- http://html5doctor.com/
- http://gsnedders.html5.org/outliner/
- http://microformats.org/wiki/
- http://www.ietf.org/rfc/bcp/bcp47.txt

Void element
```html
<img>
<br>
<wbr> word break
<hr>
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

Structure
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
All headers in a section forms a sub-outline, all sub-outlines combined together to form the document outline. 

<body> <blockquote> <td> <fieldset> <figure> <details>
Section root elements have their own document outlines, they are invisible to the main document outline.
The <body> element is a little different, because the document outline in it is the main document outline.
```

Untitiled root section
```html
<body>
  <article>
    <h1>Header1</h1>
    <h1>Header1</h1>
    <h2>Header2</h2>
    <h2>Header2</h2>
  </article>
</body>

- Untitiled Section
  - Header1
  - Header1
    - Header2
    - Header2
```

Titiled root section
```html
<body>
  <h3>Body</h3>
  <article>
    <header><h1>Header1</h1></header>
    <h1>Header1</h1>
    <h2>header2</h2>
    <h2>header2</h2>
  </article>
</body>

- Body
  - Header1
  - Header1
    - Header2
    - Header2
```

A section has the same or a greater header level as the header above it,
except that the header is untitled or is the 1st level header.
```html
<body>
  <article>
    <h3>Article</h3>
    <section><h1>Section</h1></section>
  </article>
</body>

- Untitled Section
  - Article    # above header is untitled
    - Section  # above header is 1st level header
    
<article>
  <h1>Article</h1>
    <h2>Header2</h2>
    <section><h1>Section header1</h1></section>
</article>

- Untitled Section <body>
  - Article
    - Header2          # not a untitled or 1st level header
    - Section header1  # became the same level (the minimum section level is the super section level + 1)
  
<article>
  <h1>Article</h1>
    <h2>Header2</h2>
      <h3>Header3</h3>
    <section><h2>Section header2</h2></section>
</article>

- Untitled Section <body>
  - Article
    - Header2
      - Header3        # not a untitled or 1st level header 
    - Section header2  # became a greater level
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
