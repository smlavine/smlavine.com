---
title: Internet not working? Check your VPN killswitch.
date: 2024-06-05
params:
  lastUpdated: 2024-06-05
---

Yes, even if you haven't used the VPN software or logged in or whatever
in months.

Sigh.

After a recent upgrade and reboot, my internet suddenly was not working.
What was confusing about this was that the last day or so we've been
having some weirdness with our apartment complex's internet service. But
what was aggravating about this was that I was *able to connect to the
routers*, but not to the internet.

Oh, and my phone's hotspot didn't work either.

Sigh.

Shout-out to KDE for having a notification on the bar to indicate that
there's even a problem here -- I was pretty much in the dark in my
normal window manager. So that was step one.

Next I spent the next thirty minutes or so messing with everything I
could think of/Google: routing things, checking the different networks,
traceroute-ing, downgrading the kernel and firmware.

Eventually I found a post which asked me to check `ping localhost`, and
that worked. Then I decided to ping an IP address instead of a domain,
since that wasn't working: `ping 8.8.8.8`. This gave an error message of
`operation not permitted`. Strange. This led me to [this question
thread][0] where all of the answers pointed to their VPN's killswitch.
On a whim I started my VPN's client and...yep. Killswitch was activated.
Turned it off in the GUI and everything back to normal.

*Siiiigh.*

Thank you for reading my disappointed rant.
