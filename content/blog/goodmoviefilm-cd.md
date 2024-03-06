---
title: 'System Log #4: Automatically deploying goodmoviefilm.com'
date: 2022-05-12
params:
  lastUpdated: 2022-05-12
---

Right now, the way I update my website [goodmoviefilm.com][0] is by
SSHing into my VPS and editing the HTML live. No more. I've created a
user `goodmoviefilm.com` on my VPS to facilitate automatic
deployment of the site.

The user was created like so:

```
root@blue:~# useradd -m -s /bin/bash goodmoviefilm.com
root@blue:~# groups goodmoviefilm.com
goodmoviefilm.com : goodmoviefilm.com
root@blue:~# passwd goodmoviefilm.com
New password:
Retype new password:
passwd: password updated successfully
root@blue:~# chown -R goodmoviefilm.com:goodmoviefilm.com /var/www/goodmoviefilm.com/
```

I wrote up [a build manifest][1] and [a Makefile][2], I generated an SSH
keypair, and ta-da! Automatic deployment. Easier than I thought it'd be,
honestly, thanks to rsync.

Later that day, I also tore my hair out over making the source a bit
easier to edit and read with m4 macros.

[0]: https://goodmoviefilm.com
[1]: https://git.sr.ht/~smlavine/goodmoviefilm.com/tree/master/item/.build.yml
[2]: https://git.sr.ht/~smlavine/goodmoviefilm.com/tree/master/item/Makefile
