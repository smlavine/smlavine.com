---
title: "Better" backups
author: Sebastian LaVine
date: 2022-08-07
---

Currently I back up my server every once and a while by manually running
this script:

```
#!/bin/sh

ssh root@smlavine.com tar cf - /var /usr /sbin /bin /opt /root /home /etc /bin /lib
```

which I then redirect to a file named something like
`bluebackup.2022-04-15.tar`. Beyond the questionable use of SSH, this
has two main drawbacks:

- It relies on logging in as `root`, so every time I want to back up my
  server I have to first log in as a normal user, `su` to root, and edit
  my sshd config to temporarily allow `root` login. Then disable it
  again once the backup is over.
- There is no schedule to the backups; I only make one when I think to
  do so and have the time.

