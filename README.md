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
  - `2001:DB8:::25/64`
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
```

### 1. Install sysctl IPv6 config

```bash
sudo cp sysctl/99-ipv6.conf /etc/sysctl.d/99-ipv6.conf
sudo sysctl --system
```

This:

- Enables IPv6 globally
- Ensures `wlan0` is IPv6-enabled
- Allows RAs on `wlan0`
- (Optionally) disables temporary IPv6 addresses on `wlan0` (so your static host token address is “the” address)

### 2. Install IPv6 token script + systemd unit

```bash
sudo cp scripts/wlan0-ipv6-token.sh /usr/local/sbin/wlan0-ipv6-token.sh
sudo chmod +x /usr/local/sbin/wlan0-ipv6-token.sh

sudo cp systemd/wlan0-ipv6-token.service /etc/systemd/system/wlan0-ipv6-token.service
sudo systemctl daemon-reload
sudo systemctl enable wlan0-ipv6-token.service
sudo systemctl start wlan0-ipv6-token.service
```

This ensures that on every boot, `wlan0` gets a static host token (by default `::25`):

```bash
ip token get dev wlan0
# token ::25 dev wlan0
```

### 3. Install IPv6 status helper

```bash
sudo cp scripts/ipv6-status.sh /usr/local/sbin/ipv6-status.sh
sudo chmod +x /usr/local/sbin/ipv6-status.sh
```

Use it like:

```bash
ipv6-status.sh
```

Example output:

```json
{
  "wlan0": {
    "state": "UP",
    "global": "2001:DB8:::::25/64",
    "ula": "none",
    "link_local": "fe80:80::/64",
    "default_route": "default via fe80::1 dev wlan0 metric 1024"
  }
}
```

---

## What This Actually Does

### Sysctl IPv6 settings

The sysctl file:

- Turns IPv6 **on** globally
- Enables IPv6 specifically on `wlan0`
- Allows the kernel to accept router advertisements on `wlan0`
- Optionally disables temporary IPv6 addresses on `wlan0` (so your static host token address is the primary one)

### Static host token (`::25`) with dynamic prefix

Instead of hard-coding the **entire** IPv6 address, we only fix the **host part**:

```bash
ip token set ::25 dev wlan0
```

When your router advertises a prefix (e.g. `2001:DB8:::::/64`), the kernel builds:

```text
2001:DB8:::::25/64
```

If your ISP renumbers your prefix, your host automatically renumbers to:

```text
<new-prefix>::25/64
```

No manual editing needed, but your server/address remains easy to remember and script around.

---

## Customization

### Change interface

If your primary interface is `eth0` instead of `wlan0`, edit:

- `scripts/wlan0-ipv6-token.sh`
- `scripts/ipv6-status.sh`
- `systemd/wlan0-ipv6-token.service` (description is cosmetic; script still controls the actual token)

Replace `wlan0` with `eth0` in the scripts.

### Change host token

Default token is:

```text
::25
```

To change it:

1. Edit `scripts/wlan0-ipv6-token.sh`:

   ```bash
   ip token set ::25 dev wlan0
   ```

   → e.g. `ip token set ::1234 dev wlan0`

2. Reload the service:

   ```bash
   sudo systemctl restart wlan0-ipv6-token.service
   sudo ip -6 addr flush dev wlan0 scope global
   sudo ip link set wlan0 down
   sudo ip link set wlan0 up
   ```

3. Verify:

   ```bash
   ip -6 addr show dev wlan0
   ```

### Keep privacy addresses as well

If you want to **keep** IPv6 temporary/privacy addresses on `wlan0`, remove or comment out this line in `sysctl/99-ipv6.conf`:

```bash
net.ipv6.conf.wlan0.use_tempaddr = 0
```

Then reload sysctl:

```bash
sudo sysctl --system
```

In that mode you’ll typically see:

- A stable `::25` address
- One or more temporary privacy addresses

---

## Troubleshooting

### No global IPv6 address on `wlan0`

Check:

```bash
ip -6 addr show dev wlan0
ip -6 route
```

If you only see `fe80::` and no `2600:` (or similar GUA):

- Your router might not be advertising IPv6, or
- Your ISP isn’t delegating a prefix

### `ipv6-status.sh` returns empty / “no interfaces”

Make sure:

- You’re actually using `wlan0` (or adjust interface name in the script)
- IPv6 is enabled at the kernel:

  ```bash
  sysctl net.ipv6.conf.all.disable_ipv6
  ```

Expected: `0`.

---

## License

MIT License — see LICENSE file (optional).
