#!/usr/bin/env bash
# Simple IPv6 JSON status for Debian Trixie.
# Shows state, addresses, and default route per interface.

set -e

interfaces=("wlan0" "eth0")

echo "{"
first_if=1
for IF in "${interfaces[@]}"; do
  ip link show "$IF" >/dev/null 2>&1 || continue

  [ $first_if -eq 0 ] && echo ","
  first_if=0

  echo -n "  \"$IF\": {"

  state=$(ip -o link show "$IF" 2>/dev/null | awk '{print $9}')
  echo -n "\"state\": \"${state:-UNKNOWN}\""

  global=$(ip -6 addr show dev "$IF" scope global 2>/dev/null | awk '/inet6/ {print $2}' | paste -sd "," -)
  ula=$(ip -6 addr show dev "$IF" scope global 2>/dev/null | awk '/fd[0-9a-f]{2}:/ {print $2}' | paste -sd "," -)
  echo -n ", \"global\": \"${global:-none}\""
  echo -n ", \"ula\": \"${ula:-none}\""

  ll=$(ip -6 addr show dev "$IF" scope link 2>/dev/null | awk '/inet6/ {print $2}' | paste -sd "," -)
  echo -n ", \"link_local\": \"${ll:-none}\""

  def6=$(ip -6 route show default 2>/dev/null | awk -v dev="$IF" '$0 ~ ("dev " dev) {print $0}' | head -n1)
  echo -n ", \"default_route\": \"${def6//"/\\\"}\""

  echo -n "}"
done
echo
echo "}"
