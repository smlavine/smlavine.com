---
title: Pausing WordPress services
author: Sebastian LaVine
date: 2023-10-01
---

WordPress is a real pain to host.

Sure, it's possible -- that's their whole thing, right? -- but if you're
running into problems and "throw more RAM at it" isn't the solution
you're looking for, you're not going to have a fun time.

I'm pausing the WordPress services I've been hosting for my friend's
site. It was unreliable due to my resource constraints and they'll be
seeking hosting somewhere else anyway. Which is fine. It was an
interesting experiment. But having to host a *full on HTML WYSISWYG
editor plus plugin marketplace service* when what you actually want is
*a static site with maybe some shopify-like integration* is a recipe for
a headache.

So for now, I'm going to hold onto the files,

```shell-session
for service in mariadb php8.2-fpm; do
	sudo systemctl stop "$service"
	sudo systemctl disable "$service"
done
```

, disable the nginx proxy, and un-download the more RAM I got.
