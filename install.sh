#!/bin/sh
# Runs on the Pi. Usage: sh install.sh <mediamtx version, e.g. v1.15.5>
set -eu

[ $# -eq 1 ] || { echo "usage: sh install.sh <version>" >&2; exit 64; }
VERSION=$1

for cmd in curl tar sudo systemctl; do
	command -v "$cmd" >/dev/null || { echo "missing required command: $cmd" >&2; exit 1; }
done

case "$(uname -m)" in
	aarch64) ARCH=arm64 ;;
	armv7l)  ARCH=armv7 ;;
	armv6l)  ARCH=armv6 ;;
	*) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

cd "$(dirname "$0")"

if [ ! -x mediamtx ] || ! ./mediamtx --version 2>/dev/null | grep -qxF "$VERSION"; then
	# temp dir on the same filesystem so the final mv is an atomic rename,
	# safe to do under a running service
	TMP=$(mktemp -d ./.install.XXXXXX)
	trap 'rm -rf "$TMP"' EXIT
	echo "downloading mediamtx $VERSION ($ARCH)"
	curl -fsSL --retry 3 -o "$TMP/mediamtx.tar.gz" \
		"https://github.com/bluenviron/mediamtx/releases/download/$VERSION/mediamtx_${VERSION}_linux_${ARCH}.tar.gz"
	tar -xzf "$TMP/mediamtx.tar.gz" -C "$TMP" mediamtx
	"$TMP/mediamtx" --version >/dev/null
	mv "$TMP/mediamtx" mediamtx
fi

sed "s|__DIR__|$PWD|g; s|__USER__|$(id -un)|g" irpi.service \
	| sudo tee /etc/systemd/system/irpi.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable irpi
sudo systemctl restart irpi

sleep 2
sudo systemctl --quiet is-active irpi || {
	echo "service is not running; check: journalctl -u irpi -e" >&2
	exit 1
}

echo "done - feed at http://$(hostname -I | awk '{print $1}'):8889/cam"
