---
title: 'System Log #1: Excess mail from omnavi crontab'
date: 2021-12-21
params:
  lastUpdated: 2021-12-21
---

After taking a backup of blue, I noticed that there was an oddly high
amount of disk space in `/home/omnavi`. I tracked this down to the
`Mail` directory, equally odd since there should be no substantial
interaction with that user through email. In the directory for
/home/omnavi/Mail/Inbox/new was a listing like the following:

```
total 17660
...
-rw------- 1 .. 1270 Dec 21 14:17 1640114222.M131998P20828.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 13:17 1640110622.M55373P20430.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 12:17 1640107021.M993795P20165.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 11:17 1640103421.M911567P19959.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 10:17 1640099821.M858800P19597.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 09:17 1640096221.M780369P19398.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 08:17 1640092621.M718225P19209.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 07:17 1640089021.M645353P19025.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 06:17 1640085421.M551262P18816.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 05:17 1640081821.M197206P7343.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 04:17 1640078222.M131076P7157.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 03:17 1640074622.M38919P6865.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 02:17 1640071021.M984497P6428.blue,S=1270,W=1298
-rw------- 1 .. 2270 Dec 21 01:25 1640067903.M253707P6160.blue,S=2270,W=2316
-rw------- 1 .. 1270 Dec 21 01:17 1640067421.M740996P5956.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 21 00:17 1640063821.M693826P5704.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 23:17 1640060221.M613212P5489.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 22:17 1640056621.M554691P5262.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 21:17 1640053021.M477312P5079.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 20:17 1640049421.M395554P4863.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 19:17 1640045821.M343643P4670.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 18:17 1640042221.M238968P4429.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 17:17 1640038621.M179400P4211.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 16:17 1640035022.M109915P4005.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 15:17 1640031422.M48334P3702.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 14:17 1640027821.M964562P2803.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 13:17 1640024221.M887469P2625.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 12:17 1640020621.M827943P2376.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 11:17 1640017021.M751954P2088.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 10:17 1640013421.M679220P1892.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 09:17 1640009821.M611637P1697.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 08:17 1640006221.M556059P1485.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 07:17 1640002621.M471558P1248.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 06:17 1639999021.M382536P796.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 05:17 1639995421.M479977P21504.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 04:17 1639991821.M370709P21329.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 03:17 1639988221.M328275P21121.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 02:17 1639984621.M258764P20940.blue,S=1270,W=1298
-rw------- 1 .. 2270 Dec 20 01:25 1639981502.M897961P20765.blue,S=2270,W=2316
-rw------- 1 .. 1270 Dec 20 01:17 1639981021.M806029P20563.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 20 00:17 1639977421.M756967P20292.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 19 23:17 1639973821.M687275P19924.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 19 22:17 1639970221.M623925P19709.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 19 21:17 1639966621.M572400P19513.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 19 20:17 1639963021.M497726P19319.blue,S=1270,W=1298
-rw------- 1 .. 1270 Dec 19 19:17 1639959421.M435345P19112.blue,S=1270,W=1298
...
```

In most of these files was a message like the following:

```
Return-Path: <omnavi@smlavine.com>
X-Original-To: omnavi
Delivered-To: omnavi@smlavine.com
Received: by mail.smlavine.com (Postfix, from userid 1006)
	id 541F37FDE3; Mon, 20 Dec 2021 00:17:01 +0000 (UTC)
DKIM-Signature: ...
From: root@smlavine.com (Cron Daemon)
To: omnavi@smlavine.com
Subject: Cron <omnavi@blue> root    cd / && run-parts --report /etc/cron.hourly
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Cron-Env: <SHELL=/bin/sh>
X-Cron-Env: <PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin>
X-Cron-Env: <HOME=/home/omnavi>
X-Cron-Env: <LOGNAME=omnavi>
Message-Id: <20211220001701.541F37FDE3@mail.smlavine.com>
Date: Mon, 20 Dec 2021 00:17:01 +0000 (UTC)

/bin/sh: 1: root: not found
```

Given these clues, I was able to determine the problem, which was that
`omnavi` had its cron file inaccurately set to `/etc/crontab`.
This file is formatted differently from other cron files, in that it has
an extra field for the user executing the command, thus "root: not
found".

I solved this problem by running `crontab -r` as the `omnavi`
user, and then deleting all the excess mail that had accumulated.

rkta in #sr.ht.watercooler on libera.chat pointed me in the direction of
setting up a user or directory quota to make sure that disk space cannot
be exceeded. I might also look into doing something like this for
[tmp](https://sr.ht/~smlavine/tmp).
