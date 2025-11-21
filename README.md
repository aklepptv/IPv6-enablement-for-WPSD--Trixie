# IPv6-enablement-for-WPSD--Trixie
Enabling IPv6 support for Trixi
# Trixie IPv6 Enablement (Dynamic Prefix, Static Host Token)

This repository contains a small set of configs and helper scripts to **enable IPv6 cleanly on Debian Trixie** (13) with:

- IPv6 enabled at the kernel level
- Router Advertisements (RA) accepted on `wlan0`
- A **static IPv6 host token** on `wlan0` (e.g. `::25`) while still using a **dynamic /64 prefix** from your ISP/router
- A simple CLI IPv6 status script

It’s designed for lightweight devices (e.g. Raspberry Pi / WPSD-style images), but it works on any Debian Trixie host using `wlan0` as the primary interface.

## Features

- ✅ Enables IPv6 in `sysctl` across the system
- ✅ Accepts IPv6 RAs on `wlan0`
- ✅ Sets a **dynamic-prefix / static-host** IPv6 address, e.g.:
  - `2600:4041:20a6:67aa::25/64`
- ✅ Optional: disables temporary/privacy addresses on `wlan0`
- ✅ Provides `ipv6-status.sh` to quickly see interface and route state

## Requirements

- Debian **Trixie** (13) or later
- A working network interface (defaults to `wlan0`)
- Router/ISP that provides IPv6 via SLAAC / RA
- `systemd` (for the token service)

You can adapt the scripts for `eth0` or any other interface by editing one variable.

---

## Quick Start

> ⚠️ Run these as `root` (via `sudo`).

Clone the repo:

```bash
git clone https://github.com/<your-username>/trixie-ipv6-enable.git
cd trixie-ipv6-enable
