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

<img src="/pictures/reform.jpg" class="image"/>

With my credit card on hand, I carefully selected the top-specced build and pressed buy: the wait was on.

And I waited, and waited... It took almost a year for the thing to be built, tested and delivered to my home, but hey it's here!

I think my order came at an unfortunate time: MNT was in the middle of shipping the first iteration of their Pocket Reform, which was powered by the same SoC I picked, which was also backordered for months --- on top of that they decided to implement some hardware bugfixes in the motherboard design, and add USB-C Power Delivery charging support.

Admittedly I was a little frustrated with the ever-prolonging waiting line for this laptop, and was _very_ close to just call it a nice experiment and just cancel my order, but ultimately I'm happy I stuck with it and just waited a little more.

The MNT overall has been great, always answering to emails and making sure I was still happy with my order: I can't blame a small artisan shop for being late on an incredibly complex and custom piece of hardware!

Hardware-wise the laptop is almost flawless, except for an issue with the display which is due to a bad interface soldering job done at the factory[^display] which I'm sure MNT will take care of.

[^display]: While MNT tests devices before sending them out, I feel this one is so subtle and random they couldn't diagnose this easily.

While the Reform Linux distribution --- based on Debian --- is stable for good day-to-day usage, and there's enough juice in this RK3588 SoC to actually do real work[^realwork] on this thing, I feel the general community isn't yet accustomed to ARM processors on the desktop.

[^realwork]: Except Rust, its LSP is too heavy for this SoC in large projects.

Some software is simply not packaged for ARM, and the driver situation is considerably worse than x86 due to embedded components not shining for upstream Linux support except for the bare minimum needed for server usage.

One thing I had to find a workaround for was Vulkan: the GPU embedded in the RK3588 SoC needs newer `mesa` packages that implement 1.2 revision of Vulkan to use things like Zed editor[^vulkan].

[^vulkan]: I spent the majority of my Linux user life as a rolling-release distro user, getting used to slower but better tested software releases is hard.

I can't blame anybody for this -- except for the hardware manufacturers -- as the only real ARM desktop computers out there are Macs, and Qualcomm attempt at replacing x86 has been laughable at best.

A funny thing about this laptop is the keyboard.

The layout is custom but not quite, but I like it! I particularly like their choice of splitting the space bar into three separate zones.

Unfortunately the switches aren't really that good in my opinion: they are clearly not lubed, they cling and clang when you mash onto them harder, and overall they sound like one the first gamer-oriented mechanical keyboards.

The flipside is there's basically zero keyboard flex, keycaps and fully configurable RGB lighting are **really good**[^lights], and since it's open hardware I could just pop the keyboard out, replace the switches and call it a day.

[^lights]: This is the best RGB lighting I've ever seen, gaming devices manufacturers should take notes!

I'm going to experiment in the future about this, especially around sound dampening and isolation.

The keyboard has a small OLED screen on it, that is activated by pressing the `Circle` button.

You can access various system statistics through it, like battery status down to the individual cell, or control the RGB matrix color and hue, but most importantly it’s the main way to **turn the device on and off**!

Recall the Reform has upgradeable SoC by means of external boards: none of them have an universal way to turn on and off, so the solution MNT implemented is to build their own, which is connected straight to the board’s power rail —— turning the device off through the operating system works as long as it’s running the Reform device driver, while hard shutdowns are achieved by an OLED display entry.

---

Even though I love this laptop, there are some downsides, like battery life.

The battery configuration in Reform Classics isn't made of standard Li-Ion, but rather 8 LiFePo4 cells connected on the underside of the motherboard.

An immediate downside of this kind of battery chemistry is that it's less power dense --- it lasts less than Li-ion ones of comparable size --- which means Reform Classic battery life hovers around 3-5 hours depending on display and keyboard backlight usage.

<img src="/pictures/reform-underside.jpg" class="image"/>

But! They're user-replaceable, can withstand more charging cycles than Li-ion and the chance of them catching on fire is close to zero: pretty nice property for a device that you can disassemble and reassemble on your own.

---

The display is nice: it's not big brand-level, but It's a good quality 12" 1080p display, running at 70hz refresh rate.

It tilts well over 180 degrees, and by this metric alone it's a better display than most laptops.

---

I would say the Achille's heel of this device is thermals.

See, the Reform is a fanless device, relying on nooks and crannies and the aluminum chassis on the device itself to cool itself.

With a powerful SoC like the RK3588 it becomes in my opinion too hot, up to the keyboard layer at times.

I believe a small Noctua fan could do a lot to make this laptop more manageable to handle under heavy load[^fan], that said, the RK3588 is not the most power-efficient SoC out there a more moder platform could also help greatly.

[^fan]: Open hardware! Do it yourself! Hack the world!

All in all it runs hotter than most modern laptops, but not hotter than 2016-2021 era Macbooks :^)

---

Since the Reform boots in a rather unconventional way, and since it's an ARM single-board computer in disguise, debugging a non-bootable system is rather hard.

You can't simply boot a Linux live distribution and fix your system, you actually need to attach a serial cable and hope you can tweak it back in existence through that --- this is true for all devices of this class of course.

The RK3588 SoC supports EDK2, which is an open-source reference implementation of a UEFI bios: you can boot a live USB distro and fix the thing.

Too bad there aren't many distros supporting the Reform out of the box, and installing UEFI is kind of a one-way street as it requires formatting your disk(s).

RK3588 booting is weird in by itself as well[^rkboot].

[^rkboot]: I have notes on how Rockchip devices boot, I may publish them sooner or later.

Reform has an NVMe slot that works really well --- reaching roughly ~2GB/s, ~800MB/s sequential read/write speeds on a desktop-class drive --- but the device **cannot** boot natively from it.

Rockchip devices can boot from either SD or eMMC, so MNT had to engineer a way to boot _the Linux kernel_ from the embedded eMMC, but load the root filesystem from the NVMe drive.

It's an okay solution, but not the most secure: even with an encrypted drive, the initramfs and kernel are left unencrypted.

---

Some other nits:

- Ports are upside down! I have an old-style FIDO2 USB token that when inserted in the Reform, has the user-presence button down, forcing me to lift the laptop a bit in order to press it.
- There is no such thing as suspend to RAM. Non-standard vendor implementations of all the bits and bobs needed for it aren't there yet, that said the device boots so fast I don't really feel the need for it.
- I don't particularly like Debian. I might try porting over a different distro and see how it goes.

---

Do I regret buying an unconventional device? No.

Would I buy one to use as my _only_ computer? No.

This is my hacking laptop, where I write my personal software, on which I log in with my alt accounts, talk on IRC with people, and overall have a good time away from daily obbligations and perfectionism.

It makes computing fun again: rough edges are a feature, encouraging you to have your way at rounding them until **they** fit **your** style.

Yes, this is true of all Linux laptops, but does your laptop have a mechanical keyboard?

Until next time!
