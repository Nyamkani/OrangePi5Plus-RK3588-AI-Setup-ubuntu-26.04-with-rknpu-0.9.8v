#!/usr/bin/env bash
set -u

echo "=== Kernel ==="
uname -r

echo
echo "=== RKNPU config ==="
grep -E 'CONFIG_(ROCKCHIP_RKNPU|PM_DEVFREQ)' /boot/config-$(uname -r) 2>/dev/null || true

echo
echo "=== RKNPU version ==="
if [ -r /sys/kernel/debug/rknpu/version ]; then
    cat /sys/kernel/debug/rknpu/version
else
    echo "debugfs version node is not readable."
    echo "Try: sudo mount -t debugfs none /sys/kernel/debug"
    echo "Then: sudo cat /sys/kernel/debug/rknpu/version"
fi

echo
echo "=== dmesg ==="
dmesg 2>/dev/null | grep -Ei 'rknpu|npu|iommu' | tail -n 80 || true
