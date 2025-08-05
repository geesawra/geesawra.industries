+++
title = 'MNT Reform notes'
date = 2025-07-21T19:30:15+02:00
draft = false
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

{{< image src=/pictures/reform.jpg alt="MNT Reform in all its beauty.">}}

With my credit card in hand, I carefully selected the top-spec'd build and pressed buy: the wait was on.

And I waited, and waited... It took almost a year for the thing to be built, tested and delivered to my home, but hey it's here!

My order came at an unfortunate time: MNT was in the middle of shipping the first iteration of their Pocket Reform, which was powered by the same SoC[^soc] I chose, and that was also backordered for months --- on top of that they decided to implement some hardware bugfixes in the motherboard design, and add USB-C Power Delivery charging support.

[^soc]: System-On-Chip, the silicon incorporating CPU, GPU and sometimes also RAM and AI accelerators.

Admittedly I was a little frustrated with the ever-prolonging waiting line for this laptop, and was _very_ close to just calling it a nice experiment and cancelling my order, but ultimately I'm happy I stuck with it and waited a little longer.

The MNT team overall has been great, always answering to emails and making sure I was still happy with my order: I can't blame a small artisan shop for being late on an incredibly complex and custom piece of hardware!

Hardware-wise the laptop is almost flawless, except for an issue with the display which is due to a bad interface soldering job done at the factory[^display]: this causes horizontal bands and color distortion when adjusting the display -- MNT is aware of this issue and I'm sure they'll send over a replacement part soon.

[^display]: While MNT tests devices before sending them out, I feel this issue is so subtle and random that they couldn't diagnose this easily.

While the Reform Linux distribution --- based on Debian --- is stable for good day-to-day usage, and there's enough juice in this Rockchip RK3588 SoC to actually do real work[^realwork], I feel the general community isn't yet accustomed to ARM processors for personal computing.

[^realwork]: Except Rust, `rust-analyzer` is too heavy for this SoC in large projects.

Some software is simply not packaged for ARM, and the driver situation is considerably worse than x86 due to embedded components not shining for upstream Linux support except for the bare minimum needed for server usage.

One thing I had to find a workaround for was Vulkan: to use things like the Zed editor[^vulkan] I needed newer `mesa` packages that implement the 1.2 revision of the graphics API.

[^vulkan]: I spent the majority of my Linux user life on rolling-release distros, getting used to slower but better tested software releases is hard.

I can't blame anybody for this -- except for the hardware manufacturers -- as the only real ARM desktop computers out there are Macs, and Qualcomm attempt at replacing x86 has been laughable at best.

---

A funny thing about this laptop is the keyboard.

The layout is custom but not quite, I like it! Their choice of splitting the space bar into three separate zone alleviates the wobbly spacebar issue.

Unfortunately the switches aren't really _that good_ in my opinion: they are not factory lubed, they cling and clang when you mash onto them harder, and overall they sound like one of the first gamer-oriented mechanical keyboards.

I'm going to experiment in the future about this, especially around sound dampening.

The flipside is there's basically zero keyboard flex, keycaps are high-quality and the fully configurable RGB lighting is **awesome**[^lights].

[^lights]: This is the best RGB lighting I've ever seen, gaming devices manufacturers should take notes!

Since it's open hardware I could just pop the keyboard out, replace the switches and call it a day.

{{< image src=/pictures/reform-circle.jpg alt="The Reform `Circle` button.">}}

The pointing device I chose on my Reform is the 5-button trackball: it's fine, works okay if it's not dirty -- if I had the chance to choose again I would probably go for the trackpad though.

The keyboard has a small OLED screen on it, that is activated by pressing the `Circle` button.

You can access various system statistics through it, like battery status down to the individual cell, or control the RGB matrix color and hue, but most importantly it’s the main way to **turn the device on and off**!

Recall the Reform has upgradeable SoC by means of plug-in boards: none of them have an universal way to turn on and off, so the solution MNT implemented is to build their own, which is connected straight to the board’s power rail -- turning the device off through the operating system works as long as it’s running the Reform device driver, while hard shutdowns are achieved by an OLED display entry.

---

Even though I love this laptop, there are some downsides, like battery life.

The battery configuration in Reforms isn't made of standard Li-Ion packs, but rather **8 LiFePo4** (lithium iron phosphate) cells connected on the underside of the motherboard.

An immediate downside of this kind of battery chemistry is that it's less power dense --- it lasts less than Li-ion ones of comparable size --- which means Reform battery life hovers around 3-5 hours depending on display and keyboard backlight usage.

{{< image src=/pictures/reform-underside.jpg alt="Reform underside --- look at those cells!" >}}

But! They're user-replaceable, can withstand more charging cycles than Li-ion and the chance of them catching on fire is close to zero -- a pretty nice property for a device that you can disassemble and reassemble on your own.

---

The display is nice: but it's a good quality **12.5" 1080p** display (approximately 176 PPI, not MacBook-level but quite good), running at 70hz refresh rate.

It tilts well over 180 degrees, and by this metric alone it's a better display than most laptops.

I love the display hinges MNT chose: they're sturdy and hard enough that they allow you to open the lid with a single finger.

---

I would say the Achille's heel of this device is thermals.

See, the Reform is a fanless device, relying on nooks and crannies and the aluminum chassis to cool itself.

With a powerful SoC like the RK3588 it becomes in my opinion too hot, making writing uncomfortable at times.

I believe a small Noctua fan could do a lot to make this laptop more manageable to handle under heavy load[^fan]. That said, the RK3588 is not the most power-efficient SoC out there: more modern platform could also help greatly.

[^fan]: Open hardware! Do it yourself! Hack the world!

All in all it runs hotter than most modern laptops, but not hotter than 2016-2021 era Macbooks :^)

{{< image src="pictures/reform-fastfetch.png" alt="`fastfetch` on the Reform." >}}

---

Since the Reform boots in a rather unconventional way, and it's an ARM single-board computer in disguise, debugging a non-bootable system is rather hard.

You can't simply boot a Linux live distribution and fix your system, you actually need to attach a serial cable and hope you can tweak it back in existence through that --- this is true for all devices of this class of course.

The RK3588 SoC supports EDK2, which is an open-source reference implementation of a UEFI bios: you can boot a live USB distro and fix things if you decide to use it.

Too bad there aren't many distros supporting the Reform with UEFI out of the box, and installing EDK2 is kind of a one-way street as it requires formatting your disk(s).

The RK3588 booting process is weird in by itself as well[^rkboot], requiring various bits of proprietary blobs and binaries to create a bootable image.

[^rkboot]: I have notes on how Rockchip devices boot, I may publish them sooner or later.

Reform has an NVMe slot that works really well --- reaching roughly ~2GB/s, ~800MB/s sequential read/write speeds on a desktop-class drive --- but the device **cannot** boot natively from it.

{{< image src="pictures/reform-disks.png" alt="KDiskMark running on my Reform." >}}

Rockchip devices can boot from either SD or eMMC, so MNT had to engineer a way to boot _the Linux kernel_ from the embedded eMMC, but load the root filesystem from the NVMe drive.

It's an okay solution, but not the most secure: even if you encrypt your main drive, the initramfs and kernel must remain unencrypted on the eMMC, potentially creating security vulnerabilities.

---

Some other nits:

- USB ports are upside down! I have an old-style FIDO2 USB token that when inserted in the Reform, has the user-presence button down, forcing me to lift the laptop a bit in order to press it.
- There is no such thing as suspend to RAM. Non-standard vendor implementations of all the bits and bobs needed for it aren't there yet, that said the device boots so fast I don't really feel the need for it.
- I don't particularly like Debian. I might try porting over a different distro and see how it goes.

---

Do I regret buying an unconventional device? No.

Would I buy one to use as my _only_ computer? No.

This is my **hacking laptop**, where I write my personal software, on which I log in to my alt accounts, chat on IRC networks, and overall have a good time away from daily obligations and perfectionism.

It makes computing fun again: rough edges are a feature, encouraging you to have your way at rounding them until **they** fit **your** style.

Yes, this is true of all Linux laptops, but does your laptop have a mechanical keyboard?

Until next time!
