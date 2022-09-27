---
title: Deleting nickreg user
author: Sebastian LaVine
date: 2022-05-07
---

When I iniitally registered my nickname on various IRC networks last
year, I created a new user account ```nickreg``` to give as the
confirmation email. Maybe I was planning to set up an individual email
address for every service I sign up to? Maybe I was worried about
privacy or spam?

Either way, I use my regular email address for so much else that IRC is
the least of my worries. And I, uh, haven't done that second thing. So
I've decided to delete the ```nickreg``` user from my VPS altogether.

First things first, what does this user do?

```
nickreg@blue:~$ ls -Al
total 20
-rw-r--r-- 1 nickreg mail  220 Apr 18  2019 .bash_logout
-rw-r--r-- 1 nickreg mail 3526 Apr 18  2019 .bashrc
drwx------ 3 nickreg mail 4096 May  8 05:03 .gnupg
drwx------ 7 nickreg mail 4096 May 20  2021 Mail
-rw-r--r-- 1 nickreg mail  807 Apr 18  2019 .profile
```

Hmm, what's that .gnupg doing here?

```
nickreg@blue:~$ ls -Al .gnupg
total 4
drwx------ 2 nickreg mail 4096 May  8 05:03 private-keys-v1.d
nickreg@blue:~$ ls -Al .gnupg/private-keys-v1.d/
total 0
```

Eh, I guess it's nothing. There's just the mail.

I configure aerc to view the mailbox:

```
2021-05-19 04:38 PM Libera.Chat Netwo  Libera.Chat Account Registration
2021-05-19 04:34 PM freenode           freenode Account New E-Mail Verification
2021-05-19 04:31 PM services@tilde.ch  Nickname registration for smlavine
```

Looks about what I remember it being. Heh, freenode. Ignoring that one
for obvious reasons, I go ahead and change the email associated with my
nick on Libera and tilde.chat. Only Libera sent a confirmation email for
me to do that -- though, to the new email, not the old. Well, whatever.

I do the deed.

```
nickreg@blue:~$ su
Password:
root@blue:/home/nickreg# cd
root@blue:~# deluser --remove-home nickreg
Looking for files to backup/remove ...
Removing files ...
Removing user `nickreg' ...
userdel: user nickreg is currently used by process 22609
/sbin/deluser: `/sbin/userdel nickreg' returned error code 8. Exiting.
```

Oh, I guess that makes sense. I log out and do it over again:

```
$ ssh rosie@smlavine.com
Enter passphrase for key '/home/sebastian/.ssh/id_ed25519':
Last login: Sun May  8 05:34:32 2022 from 72.65.17.226
rosie@blue:~$ su
Password:
root@blue:/home/rosie# cd
root@blue:~# deluser --remove-home nickreg
Looking for files to backup/remove ...
Removing user `nickreg' ...
userdel: user nickreg is currently used by process 22810
/sbin/deluser: `/sbin/userdel nickreg' returned error code 8. Exiting.
```

Hm, it's not just the shell process?

```
root@blue:~# ps aux | grep 22810
nickreg  22810  0.0  0.9   6220  4596 ?        S    05:33   0:00 dovecot/imap
root     22927  0.0  0.1   6072   876 pts/7    S+   05:38   0:00 grep --color=auto 22810
```

Oh dear, I'm going to have to actually administer my mail server aren't
I. Darn. Is uh...if I just kill that process, will things break terribly
for the other users? No, there must be a better way. I found a
StackOverflow page that said I could did this, so I did:

```
root@blue:~# service dovecot stop
root@blue:~# deluser --remove-home nickreg
Looking for files to backup/remove ...
Removing user `nickreg' ...
Done.
root@blue:~# service dovecot start
```

Job done.
