+++
title = 'How I run my ATProto PDS'
date = 2025-04-29T12:51:40+02:00
draft = false
author = "geesawra"
+++

Hi!

I run my own [ATProto](https://atproto.com/guides/overview) [PDS](https://atproto.com/guides/glossary#pds-personal-data-server), for various reasons:

- I want to own my data.
- It's a good way to make the ATProto network resilient against centralized infrastructure.
- I'm a nerd.

Last year I set myself a challenge: buy the cheapest VPS during the Black Friday deals and host my PDS on it.

{{< bskypost src=https://bsky.app/profile/geesawra.industries/post/3lc7bzgmf2s25 >}}

It hasn't been a flawless experience --- mostly due to deliberately choosing cheap hosting --- but the process gave me the knowledge and confidence to host my main ATProto account on it: this post explains how I did it.

PDS hosting doesn't require many resources: posts are lightweight, the only media you're storing is your own, and the nature of the relay architecture means you have limited traffic aimed directly at your server --- except if you're [hosting your own website](/posts/pds-website.html) on it!

As a huge [Alpine Linux](https://alpinelinux.org/) fan, I installed it through the VPS administration panel, and as expected, it has performed flawlessly.

The entire stack is executed on rootless [Podman](https://podman.io/), managed remotely through [Portainer](https://www.portainer.io/): I use a variation of the [official](https://github.com/bluesky-social/pds) Bluesky [`compose.yml`](https://github.com/bluesky-social/pds/blob/main/compose.yaml) file that I extracted their repository.

I don't like the `install.sh` approach as it feels brittle and hard to maintain long-term: I run many services on my machines, all of them containerized, to avoid messing with the host configuration files and runtime.

I kept Caddy as my reverse proxy of choice because it's set-and-forget once configured properly, and the setup Bluesky provides just works.

Bluesky suggests the use of `containrrr/watchtower`, but I'd advise against it: I've been bitten in the past by indiscriminate upgrades, mostly due to pulling Docker images with the `latest` tag, and I'd like not to repeat that experience anymore.

Instead of automated updates, I subscribed to Bluesky's Github notifications to keep myself up to date with new releases.

> My philosophy for this deployment is to do the best you can: posting on Bluesky is _not a vital service_ for me, I'm okay with a few hours of downtime.

So far the PDS software seems to be managed in a sane way, following [semver](https://semver.org) best practices.

I never had issues stemming from `docker pull`ing every once in a while.

The only problem I encountered was due to the host system clock losing track of time, which I promptly solved by enabling an NTP daemon.

To mitigate the risk of data loss, I backup the data directory on [Borgbase](https://borgbase.com) with [Restic](https://restic.net/) every few hours --- I also schedule regular scrubs and checks with the same Docker image.

Without further ado, here's the `compose.yml` file:

```yml
version: "3.9"
services:
  pds:
    container_name: pds
    image: ghcr.io/bluesky-social/pds:0.4
    restart: unless-stopped
    env_file: "./stack.env"
    volumes:
      - type: bind
        source: ${DATADIR}
        target: /pds
  caddy:
    image: caddy:latest
    restart: unless-stopped
    command: caddy run --config /etc/caddy/Caddyfile
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ${DATADIR}/geesawra.industries:/geesawra.industries
      - ${DATADIR}/caddy/Caddyfile:/etc/caddy/Caddyfile
      - ${DATADIR}/caddy/data:/data
      - ${DATADIR}/caddy/config:/config

  backup:
    image: mazzolino/restic
    hostname: docker
    restart: unless-stopped
    environment:
      RUN_ON_STARTUP: "true"
      BACKUP_CRON: "*/45 * * * *"
      RESTIC_CHECK_ARGS: >-
        --read-data-subset=10%
      RESTIC_REPOSITORY: rest:[REDACTED]
      RESTIC_PASSWORD: [REDACTED]
      RESTIC_BACKUP_SOURCES: /mnt/pds
      RESTIC_BACKUP_ARGS: >-
        --tag pds
      RESTIC_FORGET_ARGS: >-
        --keep-last 10
        --keep-daily 7
        --keep-weekly 5
        --keep-monthly 12
      TZ: Europe/Berlin
    volumes:
      - ${DATADIR}:/mnt/pds:ro

  prune:
    image: mazzolino/restic
    hostname: docker
    restart: unless-stopped
    environment:
      SKIP_INIT: "true"
      RUN_ON_STARTUP: "false"
      PRUNE_CRON: "0 0 4 * * *"
      RESTIC_REPOSITORY: rest:[REDACTED]
      RESTIC_PASSWORD: [REDACTED]
      TZ: Europe/Berlin

  check:
    image: mazzolino/restic
    hostname: docker
    restart: unless-stopped
    environment:
      SKIP_INIT: "true"
      RUN_ON_STARTUP: "false"
      CHECK_CRON: "0 15 5 * * *"
      RESTIC_CHECK_ARGS: >-
        --read-data-subset=10%
      RESTIC_REPOSITORY: rest:[REDACTED]
      RESTIC_PASSWORD: [REDACTED]
      TZ: Europe/Berlin
```

There are two notable features in this `compose.yml`:

- As `pds` is configured through environment variables, I'm storing them in a `stack.env` --- this file is auto-generated by Portainer, managed through its web UI.
- I'm binding the host volume path to `${DATADIR}`, which is defined in `stack.env`.

Running a PDS isn't exactly a walk in the park, but if you've played around with containers before and feel at home in the Linux shell, you should be good to go.

On a positive note, migrating my account from `bsky.social` to my own PDS has been a great experience, and it's certainly something the ActivityPub folks should look into for their next protocol iteration.

{{< bskypost src=https://bsky.app/profile/geesawra.industries/post/3l772nfieyk2t >}}

{{< bskypost src=https://bsky.app/profile/geesawra.industries/post/3l772vddndc2t >}}

Until next time!
