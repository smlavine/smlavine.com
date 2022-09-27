---
title: Replacing the git user with user accounts
author: Sebastian LaVine
date: 2022-05-08
---

While I use [sourcehut](https://sr.ht/~smlavine) for my public
programming presence online, I also have a ```git``` user on my VPS
where I keep private copies of various git repositories. For a while, I
used gitweb to show certain repositories at ```git.smlavine.com```, but
it was clunky to configure, so I turned that off once I established
myself on sourcehut. As of writing, that subdomain redirects to my sr.ht
profile.

This works well and good, but it has its flaws. For one thing, all
repositories have the same access level: the ```git``` user. That means
I can't give certain SSH keys access to only some repositories. Unix is
meant to be a multi-user environment, so I am going to be deleting
```git``` and replacing it with a personal ```smlavine``` user. In the
future, I might recreate the ```git``` user, for public read-only
access. But not right now.

I have ```find . -maxdepth 4 -type d -name '\*.git' | wc -l``` => **30**
repositories I need to replace. Another change I'm going to make while
I'm here is to keep things flat: at the moment, I have some repositories
in directories to match a sourcehut project they're in, like so:

```
...
./smlss/scripts.git
./smlss/dmenu.git
./smlss/st.git
./smlss/dots.git
./smlss/svkbd.git
./smlss/dwm.git
...
./aurpackages/jo-aur.git
./aurpackages/aurpackages.git
./aurpackages/catgirl-aur.git
```

But no more.

First things first, let's make this user:

```
git@blue:~$ su
Password:
root@blue:/home/git# cd
root@blue:~# useradd -ms /bin/bash smlavine
root@blue:~# passwd smlavine  # Generated with pass(1)
New password:
Retype new password:
passwd: password updated successfully
```

Good start, let's see what we got:

```
root@blue:~# ls -A /home/smlavine
.bash_logout  .bashrc  .profile
```

Looks about right. I'm going to quickly
```rm /home/smlavine/.bash_logout /home/smlavine/.bashrc```, so that I
can instead use the system default ```/etc/bash.bashrc``` I've already
installed. Now let's get login going:

```
root@blue:~# cd /home/smlavine
root@blue:/home/smlavine# l
.profile
root@blue:/home/smlavine# mkdir .ssh
root@blue:/home/smlavine# curl -L https://meta.sr.ht/~smlavine.keys > .ssh/authorized_keys
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   205  100   205    0     0    186      0  0:00:01  0:00:01 --:--:--   186
root@blue:/home/smlavine# chown -R smlavine:smlavine .
root@blue:/home/smlavine# ll
total 8.0K
-rw-r--r-- 1 smlavine smlavine  807 Apr 18  2019 .profile
drwxr-xr-x 2 smlavine smlavine 4.0K May  9 01:08 .ssh/
```

Now I create new bare git repos for each I am moving from ```git```:

```
$ ssh git@smlavine.com find . -maxdepth 4 -type d -name '\*.git' | xargs -I'{}' basename '{}' .git | sed 's:^:git/:' > repos.txt
Enter passphrase for key '/home/sebastian/.ssh/id_ed25519':
$ ssh smlavine@smlavine.com xargs -L1 git init --bare < repos.txt
Enter passphrase for key '/home/sebastian/.ssh/id_ed25519':
Initialized empty Git repository in /home/smlavine/git/mazesolver/
...
...
Initialized empty Git repository in /home/smlavine/git/aurpackages/
Initialized empty Git repository in /home/smlavine/git/catgirl-aur/
```

I thought about somehow automating finding the directories containing
the code and changing the remote, but that would take more time than
just doing it manually. I did, however, use some awk magic to make
updating the origin go a lot faster in most of the repos:

```
master$ function orig() { git remote -v | awk -F: '/origin/ { sub(/\.git.*$/, ""); print $2 }' | xargs -I'{}' git remote set-url origin smlavine@smlavine.com:git/'{}'; git push origin; }
master$ orig
Enter passphrase for key '/home/sebastian/.ssh/id_ed25519':
Enumerating objects: 53, done.
Counting objects: 100% (53/53), done.
Delta compression using up to 4 threads
Compressing objects: 100% (53/53), done.
Writing objects: 100% (53/53), 16.07 KiB | 4.02 MiB/s, done.
Total 53 (delta 19), reused 0 (delta 0), pack-reused 0
To smlavine.com:git/colat
 * [new branch]      master -> master
```

This worked for most of the repos, except those where the git repo was
nested in a directory. But it was easy to edit those manually. In this
process, I also deleted two remotes that I decided I didn't need
anymore, bringing down to 28.

I also added the SSH key from my phone in this process.

After this, I removed the ```git``` user. But, as ```git``` is also
hooked up to dovecot, I had to do [the trick][0] that I also did for
```nickreg```:

[0]: https:smlavine.com/systemlog#deleting-nickreg

```
$ ssh smlavine@smlavine.com
Enter passphrase for key '/home/sebastian/.ssh/id_ed25519':
Last login: Tue May 10 18:26:40 2022 from 72.65.17.226
smlavine@blue:~$ su
Password:
root@blue:/home/smlavine# service dovecot stop; \
> deluser --remove-home git; \
> service dovecot start
Looking for files to backup/remove ...
Removing files ...
Removing user `git' ...
Done.
root@blue:/home/smlavine# exit
exit
smlavine@blue:~$ exit
logout
Connection to smlavine.com closed.
```

I'm happy that I've gotten this done. It will allow me to be more
flexible in how I use my server for Git in the future.
