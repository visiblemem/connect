#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: ./scripts/set-hostname.sh connect.example.com" >&2
  exit 1
fi

hostname_value="$1"

case "$hostname_value" in
  *[!A-Za-z0-9.-]*|.*|*.)
    echo "Invalid hostname: $hostname_value" >&2
    exit 1
    ;;
esac

config_dir="meshcentral/data"
config_path="$config_dir/config.json"
mkdir -p "$config_dir"

escaped_hostname=$(printf '%s' "$hostname_value" | sed 's/[&/]/\\&/g')
sed "s/CONNECT_HOSTNAME/$escaped_hostname/g" meshcentral/config.example.json > "$config_path"
chmod 600 "$config_path" 2>/dev/null || true

echo "Configured Connect for https://$hostname_value"
echo "Initialize the admin locally before exposing the tunnel."
