#!/bin/sh
# Set a static IPv6 host token on wlan0 while keeping a dynamic prefix.
# Default token: ::25

IFACE="wlan0"
TOKEN="::25"

ip token set "$TOKEN" dev "$IFACE"
