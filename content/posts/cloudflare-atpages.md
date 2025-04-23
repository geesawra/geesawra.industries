+++
title = 'Cloudflare atpages'
date = 2025-04-23T19:18:00+02:00
draft = true
author = "geesawra"
+++

Hi!

I recently played with [`atpage`](https://github.com/geesawra/atpage) again after a long hiatus (which was due mostly to `$newjob`, so it wasn't all that bad), and wanted to see if I could deploy it to GitHub Pages, as a treat.

After some initial success, I quickly encountered the same issue I had during the [first iteration](/posts/pds-website.html): you can't easily hotlink a blog post online and expect it to work, because the Service Worker is only installed when visiting the website's root.

I [complained on Bluesky](https://bsky.app/profile/geesawra.industries/post/3lng6cbuqss2z) and it turns out **Cloudflare Pages** allows you to do custom redirects and stuff like that, for free, without hosting anything yourself.

I wanted to replicate the same workflow as any common Hugo user, which boils down to `git commit`, `git push` and poof, your new blogpost is available on your website.

Setting up GitHub Actions wasn't as bad as I expected: I cloned the blog sources repo, cloned atpage in a subdirectory, called Hugo to obtain the rendered HTML, then `atpage post` to post it on my PDS, easy!

Setting up Cloudflare Pages wasn't much harder to be fair, I don't like how they coerce you to move your domain's DNS servers to theirs if you want to use your own - you can probably set it up differently, but I can't see how.

A neat feature of Pages is that you can specify custom redirects by including a text file called `_redirects` in your deployment bundle.

This is how I do it with Caddy v2:

```
geesawra.industries {
  handle /at/* {
          root * /geesawra.industries
  }
	root * /geesawra.industries
	file_server
}
```

This is how I do it with `_redirects`:

```
/at/* / 200
```

By moving to Cloudflare Pages I also gained access to very business tooling, like staging and production environments: whatever isn't the `main` branch is automatically treated as staging, and you also get a deploy-specific URL to go look at your staging website!

I use GitHub environments to have all the fancy UI/UX goodies, like a "click here to see your staging prod" button in PRs, or the deus ex machina, branch protection rules.

Each environment is tied to a specific Bluesky account, so that I don't end up overwriting my main account's blog with the staging one.

I'm not a web developer, and I'm in awe at what we can achieve nowadays with great tooling available **completely free of charge**.

I [open-sourced](https://github.com/geesawra/geesawra.industries) this blog, including the Pages configuration and the GitHub Action I wrote to automate the deployment.

I should also document `atpage`, shouldn't I? `:^)`

Until next time!
