+++
title = 'MNT Reform notes'
date = 2025-07-21T19:30:15+02:00
draft = true
author = "geesawra"
+++

Hi!

Last year after receiving a nice bonus from work I was in the mood for some inconsiderate money spending which ultimately led to buying another computing device: an MNT Reform Classic.

On paper, the MNT Reform Classic (henceforth referred to as Reform) is everything a person like me would want:

- ~90% open source
- completely hackable in the physical sense
- engineered and hand-assembled in Germany
- expandable
- display hinge that bends waaay past 180 degrees
- runs _only_ UNIX-like operating systems[^1]

[^1]: Except macOS, thankfully.

I picked the Classic because of its form factor: matte black, boxy, with some silver accents here and there and a transparent plexiglass bottom cover.

With my credit card on hand, I carefully selected the top-specced build and pressed buy: the wait was on.

And I waited, and waited... It took almost a year for the thing to be built, tested and delivered to my home, but hey it's here!

I think my order came at an unfortunate time: MNT was in the middle of shipping the first iteration of their Pocket Reform, which was powered by the same SoC I picked, which was also backordered for months --- on top of that they decided to implement some hardware bugfixes in the motherboard design, and add USB-C Power Delivery charging support.

Admittedly I was a little frustrated with the ever-prolonging waiting line for this laptop, and was _very_ close to just call it a nice experiment and just cancel my order, but ultimately I'm happy I stuck with it and just waited a little more.

The MNT overall has been great, always answering to emails and making sure I was still happy with my order: I can't blame a small artisan shop for being late on an incredibly complex and custom piece of hardware!

Hardware-wise the laptop is almost flawless, except for an issue with the display which is due to a bad interface soldering job done at the factory[^display] which I'm sure MNT will take care of.

[^display]: While MNT tests devices before sending them out, I feel this one is so subtle and random they couldn't diagnose this easily.

While the Reform Linux distribution --- based on Debian --- is stable for good day-to-day usage, and there's enough juice in this RK3588 SoC to actually do real work on this thing, I feel the general community isn't yet accustomed to ARM processors on the desktop.

Some software is simply not packaged for ARM, and the driver situation is considerably worse than x86 due to embedded components not shining for upstream Linux support except for the bare minimum needed for server usage.

One thing I had to find a workaround for was Vulkan: the GPU embedded in the RK3588 SoC needs newer `mesa` packages that implement 1.2 revision of Vulkan to use things like Zed editor[^vulkan].

[^vulkan]: I spent the majority of my Linux user life as a rolling-release distro user, getting used to slower but better tested software releases is hard.

I can't blame anybody for this -- except for the hardware manufacturers -- as the only real ARM desktop computers out there are Macs, and Qualcomm attempt at replacing x86 has been laughable at best.

A funny thing about this laptop is the keyboard.

The layout is custom but not quite, but I like it! I particularly like their choice of splitting the space bar into three separate zones.

Unfortunately the switches aren't really that good in my opinion: they are clearly not lubed, they cling and clang when you mash onto them harder, and overall they sound like one the first gamer-oriented mechanical keyboards.

The flipside is there's basically zero keyboard flex, keycaps and fully configurable RGB lighting are **really good**, and since it's open hardware I could just pop the keyboard out, replace the switches and call it a day.

I'm going to experiment in the future about this, especially around sound dampening and isolation.

The keyboard has a small OLED screen on it, that is activated by pressing the `Circle` button.

You can access various system statistics through it, like battery status down to the individual cell, or control the RGB matrix color and hue, but most importantly it’s the main way to __turn the device on and off__!

Recall the Reform has upgradeable SoC by means of external boards: none of them have an universal way to turn on and off, so the solution MNT implemented is to build their own, which is connected straight to the board’s power rail —— turning the device off through the operating system works as long as it’s running the Reform device driver, while hard shutdowns are achieved by an OLED display entry. 

## Develop this

- What's your current config?
- What are you doing with it? What's an hacking laptop?
- What is a personal laptop after all?
- Talk about thermals a bit
- Maybe briefly about the display
- How long does the battery last?
- What's up with that displayy on the keeb? Done
- Add a photo of the thing
- Plans for the future? Chimera linux?
- What's up with the upside down usb ports lmao
