---
title: 'System Log #8: Automatically deploying smlavine.com'
date: 2022-09-26
params:
  lastUpdated: 2022-09-26
---

In [a previous entry][previously] I discussed how I made my website
[goodmoviefilm.com][gmf] automatically deployable. Now the time has come
to do the same with my main website, [smlavine.com][smlavine.com].

[previously]: https://smlavine.com/blog/goodmoviefilm-cd/
[gmf]: https://goodmoviefilm.com
[smlavine.com]: https://smlavine.com

For the time being, the website is written in pure HTML/CSS, so unlike
goodmoviefilm.com (which uses m4) there is no build step required.

A difference is that in addition to these text files, I also have several large
binary files such as images and PDFs that I obviously do not want to check into
version control. For right now, I'm just not going to use rsync's `--delete`
option, which I use in goodmoviefilm.com to remove any old stale files. For the
future, though, I've been thinking of a solution that involves

- uploading the files to my server separately
- specifying symlinks in version control with paths to where the files
  are on my server
- verifying that the files are correct with hashes kept in version
  control

The devil is in the (implementation) details, but I think it could work.
I've skimmed the website for [git-annex][git-annex] and it looks like it uses a
similar approach. Needs more research.

[git-annex]: https://git-annex.branchable.com

I could also embrace a third-party host (or first-party "third-party" host,
using [tmp][tmp] or similar) to have all of my static files located on a
subdomain, sidestepping the issue.

[tmp]: https://sr.ht/~smlavine/tmp

Anyway, the actual steps to create the `smlavine.com` user on my VPS were
largely the same as those to create the `goodmoviefilm.com` user:

```
root@blue:~# useradd -m -s /bin/bash smlavine.com
root@blue:~# groups smlavine.com
smlavine.com : smlavine.com
root@blue:~# passwd smlavine.com
New password:
Retype new password:
passwd: password updated successfully
root@blue:~# chown -R smlavine.com:smlavine.com /var/www/smlavine.com/
```

I also took this opportunity to clean up some file permissions on my
system that were more liberal than I would have liked. Oops.

I created an SSH keypair with

```
$ ssh-keygen -t ed25519 -N '' -C "smlavine.com builds.sr.ht deployment key" -f smlavine.com.txt
```

then copied the public key to `/home/smlavine.com/.ssh/authorized_keys` and
registered the private key as a secret on builds.sr.ht.

After that, using goodmoviefilm.com as a template, I wrote up a new
[build manifest][build] and [Makefile][makefile], and crossed my fingers:

[build]: https://git.sr.ht/~smlavine/smlavine.com/tree/master/item/.build.yml
[makefile]: https://git.sr.ht/~smlavine/smlavine.com/tree/master/item/Makefile

```
master$ git push sr.ht master -o visibility=public -o description='Personal website'
Enter passphrase for key '/home/sebastian/.ssh/id_ed25519':
Enumerating objects: 87, done.
Counting objects: 100% (87/87), done.
Delta compression using up to 4 threads
Compressing objects: 100% (86/86), done.
Writing objects: 100% (87/87), 30.30 KiB | 6.06 MiB/s, done.
Total 87 (delta 31), reused 0 (delta 0), pack-reused 0
remote: Build started:
remote: https://builds.sr.ht/~smlavine/job/851290 [.build.yml]
To git.sr.ht:~smlavine/smlavine.com
 * [new branch]      master -> master
master$ sleep 30; hut builds show
#851290 - smlavine.com/commits/master/.build.yml: ✔ SUCCESS
✔ build  ✔ deploy

  [caf87fa][0] — [Sebastian LaVine][1]

      Add build manifest, Makefile

  [0]: https://git.sr.ht/~smlavine/smlavine.com/commit/caf87fa08b023a8361c697532ca2b71331b40945
  [1]: mailto:mail@smlavine.com

```

Ta-da! I'll work more on making it easier to add new content to the site later,
but for now, being able to quickly modify what is already there is very helpful.
