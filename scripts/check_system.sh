#!/usr/bin/env bash
set -u

echo "=== OS / 운영체제 ==="
lsb_release -a 2>/dev/null || cat /etc/os-release

echo
echo "=== Kernel / 커널 ==="
uname -a

echo
echo "=== Held packages / hold 패키지 ==="
apt-mark showhold 2>/dev/null || true

echo
echo "=== Memory / 메모리 ==="
free -h
