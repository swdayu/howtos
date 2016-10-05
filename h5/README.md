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

void element
```html
<img>
<br>
<wbr> word break
<hr>
```

special element
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

structure
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

article header
1. <h1>...</h1>
2. <header>
     <img>
     <h1>...</h1>
     ...
   </header>
3. <header>
     <h1>...</h1>
     <p class="subtitle">...</p>
     <p class="bywho">...</p>
     ...
   </header>
4. <header>
     <hgroup>
       <h1>...</h1>
       <h2>...</h2>
     </hgroup>
     <p>...</p>
   </header>
   
 article
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

avoid old browaser apply inline to unknown elements
```css
article, aside, figure, figcaption, footer, section {
  display: block;
}
```

avoid old browser dont apply styles to unknown elements
```html
<!-- create out new elements to ask IE to apply styles -->
<!--[if lt IE 9]> 
<script>document.createElement("header")</script>
<![endif]-->

<!--[if lt IE 9]>
<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
<![endif]-->
```

document outline
```html
```
