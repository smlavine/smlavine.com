---
title: Setting up Syncthing
date: 2022-11-22
params:
  lastUpdated: 2022-11-22
---

For a while now I've wanted to set up Syncthing to sync music and
schoolwork between my laptop and my desktop. But unlike my system log
entries, this has been so easy that there's really no need for a big
writeup. Getting it up and running was as simple as `sudo pacman -Syu
syncthing` on my two computers, following [this guide][syncthing-guide],
and clicking a few buttons. Easy! The few bits of configuration I did in
the GUI are:

- Enabled password login
- Typed in my desktop's device ID
- Played around with the Default Folder to make sure that it was working
- Added the folders I wanted -- `Documents/` and `Media/`
- Allowed my devices to share those folders with each other

And that's it. It started syncing.

I started and enabled the systemd service to have Syncthing start up
automatically on my laptop, but it used a bit too much CPU for me to
have it running all the time on my laptop.

Something else I noticed is that the firefox running the web GUI was
eating up a *lot* of memory and CPU on my laptop -- much more so than
Syncthing itself. Of course, the syncing happens fine without that
happening, so that shouldn't be too big of a deal.

![A screenshot of the Syncthing web GUI. There are two columns: on the left, one labeled "Folders (2)" lists "Documents" and "Media". Media is "Up to Date", but "Documents" is still "Syncing (94%, 543 MiB)". On the right, the column is labeled "This Device" and lists information about the device "archlinux-x220": Download Rate, Upload Rate, Local State (showing ~85.3 GiB of data), and other diagnostic information. Below that section is a section labeled "Remote Devices" showing that "archlinux-white" is "Up to Date".](https://smlavine.com/images/syncthing/webgui.png "Syncing in progress.")

Next, I turned to syncing music with my Android phone. I installed
Syncthing through [F-Droid][fdroid], and a few taps later, I was ready
to go.

[fdroid]: https://f-droid.org/en/packages/com.nutomic.syncthingandroid/

One problem is that my media library is very large -- more than 75GB.
But I really only want a subset of this available on my phone: my
favorite music. So, I created a Syncthing Folder of the subdirectory
`Media/music/mine`, which is much smaller:

```
$ j mine
/home/sebastian/Media/music/mine
$ dh
4.0K    ./.stfolder
8.0K    ./.thumbnails
39M     ./The Seatbelts
49M     ./Chali 2na
51M     ./Valve Studio Orchestra
60M     ./C2C
68M     ./Tally Hall
95M     ./Toby Fox
106M    ./Lin-Manuel Miranda
119M    ./Parov Stelar
172M    ./Ghost
174M    ./Charlotte Church
184M    ./Hideki Naganuma
196M    ./Gustav Holst
198M    ./Queen
205M    ./Spiralmouth
229M    ./George Gershwin
258M    ./Django Reinhardt
287M    ./Camelot
390M    ./Tchaikovsky
396M    ./Yes
488M    ./Lemaitre
496M    ./ABBA
1.2G    ./Caravan Palace
8.8G    ./The Beatles
15G     .
```

Hmm. The Beatles are still taking up a lot of space, because they are in
FLAC. Anything else I can do about that?

```
$ cd The\ Beatles
$ dh
182M    ./Love
8.7G    ./The Beatles - Stereo and Mono Box Sets + Extras [FLAC]
8.8G    .
$ cd The\ Beatles\ -\ Stereo\ and\ Mono\ Box\ Sets\ +\ Extras\ \[FLAC\]/
$ dh
2.0G    ./Extras
2.5G    ./The Beatles in Mono
4.3G    ./The Beatles Stereo Box Set
8.7G    .
```

I see. Well, I don't really need both the Mono *and* Stereo sets on my
phone. Syncthing makes it simple to exlude a particular file or
directory:

![A screenshot of the Syncthing web GUI, showing a popup allowing us to "Edit Folder (Media/music/mine)". In the center of the window is a field for ignore patterns, labelled "Enter ignore patterns, one per line." In the field has been entered the path to the Beatles Mono set. Below that are some instructions on how to use a subset of regex to match patterns.](https://smlavine.com/images/syncthing/ignore.png)

This is small enough to squeeze onto my phone's microSD card. I scan the
QR code of my desktop's device ID, and the devices pair. I check a box
to share `Media/music/mine` with my phone, and after accepting a popup
and telling Syncthing Android where to put the folder, it begins
syncing.

![A screenshot of the Syncthing Android app. It shows that syncing of Media/music/mine is 11% complete. The app's interface is simple and clean.](https://smlavine.com/images/syncthing/android.png "The Android app is very simple to use.")

I am very pleased with using Syncthing so far. I look forward to
potentially using it to sync other data I have, like uncommitted code
between my laptop and desktop, or photos between my phone and computers.
Have you used Syncthing? I'd love to hear your experiences with it.

**P.S.**: After finishing this post, I noticed that three random music
files were not syncing properly. I tried adding new files, checking for
free space, restarting Syncthing on both my phone and my computer, but
still, these particular files would not sync. I "solved" the problem by
adding them to my list of files to ignore for syncing, since luckily
these weren't particular important music files to me. But the issue
does raises concern over the tool's reliability.

[syncthing-guide]: https://docs.syncthing.net/intro/getting-started.html
