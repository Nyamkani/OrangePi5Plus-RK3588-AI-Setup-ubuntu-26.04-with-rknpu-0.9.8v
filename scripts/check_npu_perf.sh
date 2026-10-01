#!/usr/bin/env bash
set -u

echo "Ctrl+C to stop / 종료: Ctrl+C"

while true; do
    clear
    date

    echo
    echo "=== NPU LOAD ==="
    cat /sys/kernel/debug/rknpu/load 2>/dev/null || echo "Need root/debugfs access"

    echo
    echo "=== NPU FREQ ==="
    cat /sys/class/devfreq/fdab0000.npu/cur_freq 2>/dev/null || true

    echo
    echo "=== DDR FREQ ==="
    cat /sys/class/devfreq/dmc/cur_freq 2>/dev/null || true

    echo
    echo "=== THERMAL ==="
    for z in /sys/class/thermal/thermal_zone*; do
        [ -e "$z/type" ] || continue
        t=$(cat "$z/type" 2>/dev/null)
        case "$t" in
            soc-thermal|bigcore0-thermal|bigcore1-thermal|littlecore-thermal|npu-thermal)
                printf "%-20s " "$t"
                awk '{printf "%.1f C\n", $1/1000}' "$z/temp" 2>/dev/null
                ;;
        esac
    done

    sleep 1
done
