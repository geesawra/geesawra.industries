+++
title = 'Hosting a website on your ATProto PDS'
date = 2024-12-16T20:23:02+01:00
draft = false
author = "geesawra"
+++

I built a thing called [`atpage`](https://github.com/geesawra/atpage), it publishes websites to an ATProto PDS and provides a handy viewer tool.

You can find it [here](https://github.com/geesawra/atpage).

---

Have you ever wanted to host a fully-fledged website on your [ATProto](https://atproto.com/) [PDS](https://atproto.com/guides/glossary#pds-personal-data-server)?

No?

Too bad, it's gonna happen anyway.

> **Disclaimer**: *I'm not an ATProto expert, I may very well be doing nasty stuff, please do not emulate!*

## How it works
In ATProto, objects can be uniquely identified by an [AT URI](https://atproto.com/specs/at-uri-scheme), made up of three components:
- **User identifier**: can either be a DID, or an @-handle[^aturi].
- **Collection name**: essentially the "table name" of ATProto, containing a set of well-defined objects called *records*.
- **Record key**: a string that uniquely identifies the record.

[^aturi]: Handles can change, so it is best to use DIDs in AT URIs.

This is an example of an AT URI:

```
at://geesawra.industries/industries.geesawra.website/0J5SYQ0SVQTKF
```

`geesawra.industries` is the user identifier, `industries.geesawra.website` is the collection name, while `0J5SYQ0SVQTKF` is the record key.

You can see the raw content of the record associated to this AT URI [here](https://pdsls.dev/at/did:plc:6ll5xi67lyuyovt6fiv4fnjo/industries.geesawra.website/0J5SYQ0SVQTKF).

`atpage` is made of a series of components:
- Lexicon definition
- Web viewer
- Publishing tool

The sum of these components allows you to publish websites on an ATProto PDS, and view them in a web browser without third-party services intervention.

### Lexicon definition
Records needs schemas, which in ATProto terms are called **[Lexicons](https://atproto.com/guides/glossary#lexicon)**.

A web page contains HTML, which can reference resources like CSS, JavaScript, images or even other HTML pages.

The most basic lexicon would contain just the HTML for a page, but in `atpage` *every resource* that would be loaded from the same origin *must* live on the PDS: no half-measures.

In order to do that, I decided to store referenced objects as __blobs__, and the page content in a `Page` lexicon record:

```json
{
  "lexicon": 1,
  "id": "industries.geesawra.website.page",
  "defs": {
    "main": {
      "type": "record",
      "description": "A record holding the content of a page, addressable by its record key",
      "key": "any",
      "record": {
        "type": "object",
        "required": ["content"],
        "properties": {
          "content": { "type": "string" },
          "embeds": {
            "type": "array",
            "items": {
              "type": "blob",
              "accept": ["*"]
            }
          }
        }
      }
    }
  }
}
```

Blobs are an interesting beast: they can contain arbitrary data, and are referenced and keyed by the PDS at upload time.

The Bluesky [documentation](https://docs.bsky.app/docs/api/com-atproto-repo-upload-blob) for the `com.atproto.repo.uploadBlob` method says:

> The blob will be deleted if it is not referenced within a time window (eg, minutes).

The implications are two-fold:
 - If your page contains CSS in a referenced resource, it must be uploaded as a blob and referenced in the `embeds` lexicon field.
 - If you delete a page, the associated blobs will be deleted automatically as well.

Neat!

### Web viewer
The original `atpage` design started as a proof-of-concept around the idea of referencing data from a PDS, **without** using third-party servers: the browser should be able to solve AT URIs and display its content as a web page.

Let's say Firefox or Chrome decided to natively support `atpage`'s Lexicon, an AT URI resolution process would look like this:
1. Validate and split the AT URI in its parts.
2. Solve the [DID](https://atproto.com/guides/glossary#did-decentralized-id) document to look up the PDS URL associated with the user identifier.
3. Fetch the specified record from the associated collection from said PDS URL.

I focused on making sure that this flow would work without forking Chrome and/or Firefox to add this functionality.

Armed with lots of patience and a healthy dose of stubbornness, I ventured my way into the Mozilla MDN Web Docs in search of inspiration and guidance.

I'm a little rusty[^rusty] on web technologies, but a quick search opened my mind about [Service Workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers): __you can intercept `fetch` calls with them__!

[^rusty]: I.e. I know basically zero.

A Service Worker-based solution for the flow I outlined earlier looks like this:
0. Install the Service Worker (`SW`) as soon as possible, blocking everything else in the meantime.
1. Browser does a `fetch`.
2. `SW` intercepts the `fetch` call.
3. Check if the request URL's first path component is `/at`, if not returns without replacing the request content.
4. If yes, do as explained earlier.

I wanted to keep the browser experience as seamless as possible: clicking on a link that points to an AT URI must yield the same outcome as clicking on an HTTP URL. 

You still need to host an `index.html` page that loads the Service Worker, but once that's installed, you can browse AT URIs seamlessly.

If you noticed, [geesawra.industries](https://geesawra.industries) shows a loading page first, then redirects the user to an AT URI which contains the equivalent of an `index.html`.
#### A quick Rust detour
I'm in a phase of my life in which I'm seeking change, and as a lifelong Gopher I figured "change" in this context means **Rust**: I decided that this thing should be written in it, compiling down to a WebAssembly blob because I don't know JavaScript.

On top of that, at the moment Go WASM binary size doesn't scale down well as Rust's, it also made sense from a technological perspective: the total binary size is roughly 104KB uncompressed, ~40KB compressed!

To achieve this result, I had to:
- Write a small ATProto abstraction, focusing on bringing along just what's needed for `atpage` to work.
- Don't throw around as many `#[derive(Debug)]` as I usually do.
- Use [`serde_json::Value`](https://docs.rs/serde_json/latest/serde_json/value/enum.Value.html) to navigate ATProto `JSON` responses rather than `derive`-ing serializers/deserializers at compile time.
- Leverage the browser's `fetch()` method and `Request` object through the magical [`web_sys`](https://docs.rs/web-sys/latest/web_sys/) crate instead of bringing in dependencies like [`reqwest`](https://docs.rs/reqwest/latest/reqwest/).

Tooling like [`wasm-bindgen`](https://github.com/rustwasm/wasm-bindgen) are a godsend: incredibly powerful and very well documented.

I had to [jump through](https://bsky.app/profile/geesawra.industries/post/3ld57lg6jek2b) [some hoops](https://github.com/geesawra/atpage/commit/f897ec00de6cdcabc0b3445d4e1d9ceb22d5c829) to make `atpage` work on Firefox as well since it [lacks support](https://bugzilla.mozilla.org/show_bug.cgi?id=1360870) for ES2015 JavaScript modules, but in the end I was able to implement it thanks to helpful folks on the Rust Discord server.

### Publishing tool
Client rendering is done, but how do I publish my website?

[`publish`](https://github.com/geesawra/atpage/tree/main/publish) is a small CLI tool that publishes the content of a directory, the `source` directory, on the specified PDS for the logged-in user.

Publishing is a two-step process:
1. Find all HTML files.
2. Find all tags with an `src` or `href` attribute.

To do that, `publish` recursively explores the `source` directory looking for HTML files.

For example, let's say your website `source` directory is `./my-website` and it looks like this:

```bash
$ tree ./my-website/
./my-website/
├── dog.jpg
└── index.html
```

and the `index.html` file contains an image like this:
```html
<html>
	<body>
		<h1>Hello!</h1>
		<img src="/dog.jpg">
	</body>
</html>
```

During step 1, `publish` will find the `index.html` file, then during step 2 it will look for `./my-website/dog.jpg`: any resource that's missing on disk will stop the process.

It also provides a handy `nuke` command, whenever you feel a lil crazy and want to get rid of your PDS-hosted website.

### Conclusions
`atpage` has been an interesting experiment, it allowed me to space out of my comfort zone and explore ideas "just because": I should do that more often.

Sure, there are still some rough corners here and there, but where's the fun without a little uncertainty?

I think it's also important to highlight the limitations that this approach imposes on the users: without a JavaScript-enabled browser, it's impossible to browse a website powered by `atpage`.

It must also be said that's requiring a decentralized network, a Service Worker, WebAssembly and the Rust programming language to look at what would otherwise be a statically-generated website is over-engineered, silly and most probably goofy as well.

That said, tread lightly, and have fun hosting websites on your PDSes!

### Update 1 (16 Dec, 2024)

Right after posting a link to this post, it occurred to me that in order to load it you first need to navigate to the root of the website, have the Service Worker install itself and then navigate back to the original link: too inconvenient!

As a workaround, I pushed a [hot-fix](https://github.com/geesawra/atpage/commit/30e66b37178f1d71a3740236a21e5ccae45fc9fe) and modified my Caddy configuration:

```diff
geesawra.industries {
+	redir /at/* /?redir={uri} permanent
	root * /geesawra.industries
	file_server
}
```

If the Service Worker is installed already, navigating to an `/at/{AT URI}` page will go through it, but if it isn't, redirect it to `/`, allow for the initial setup to happen and then redirect to the `redir` value, if and only if `uri` begins with `/at/`.

### Update 2 (19 Dec, 2024)

Instead of relying on redirects, a better fix for the issue described in **Update 1** is to handle all `/at/` URLs with the same code, and distinguish between index or sub-page navigation by checking `window.location.pathname`.

[This commit](https://github.com/geesawra/atpage/commit/4bb871f036e1756250d6a52b530ddfb8f5e58d54) implements the described change.

The Caddy configuration looks like this:

```diff
geesawra.industries {
- redir /at/* /?redir={uri} permanent
+ handle /at/* {
+         root * /geesawra.industries
+ }
	root * /geesawra.industries
	file_server
}
```
