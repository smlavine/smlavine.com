---
title: Fixing Python after Upgrading Debian
author: Sebastian LaVine
date: 2022-09-14
---

After I upgraded to Debian Bullseye last week, it took me a few days to
realize that the python installation was now a bit borked. On
2022-09-13, I discovered that [omnavi](https://sr.ht/~smlavine/omnavi)
had not been generating lists properly since the update, because,
Debian, as part of deprecating Python 2, removed the `python` executable
symlink. Which is a bit annoying. Luckily, though, it was easily fixed
by just installing the `python-is-python3` package.

...until this morning when I found out that youtube-dl was not working
anymore:

```
omnavi@blue:~$ youtube-dl
Traceback (most recent call last):
  File "/usr/local/bin/youtube-dl", line 6, in <module>
    from youtube_dl import main
ModuleNotFoundError: No module named 'youtube_dl'
```

Yeah. Instead of trying to fix that mess, I decided it was high time to
"upgrade" to the spiritual successor to youtube-dl,
[yt-dlp](https://yt-dlp.org). Not yet in the Debian repository proper, I
installed it locally for my `omnavi` user with `pip3`, then [pushed a
commit to omnavi][commit] that fixes the issue. For now...

[commit]: https://git.sr.ht/~smlavine/omnavi/commit/dcc1b25
