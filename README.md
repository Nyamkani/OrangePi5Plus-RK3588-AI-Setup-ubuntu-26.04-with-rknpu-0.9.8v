# Orange Pi 5 Plus RK3588 AI Setup — Ubuntu 26.04 + RKNPU 0.9.8

> **한국어 / English**  
> Orange Pi 5 Plus (RK3588, 32 GB)에서 Joshua-Riek Ubuntu Rockchip BSP를 기반으로 userspace를 Ubuntu 26.04.1 LTS로 올리고, 기존 Rockchip BSP kernel 계열을 유지하면서 RKNPU kernel driver를 0.9.7 → 0.9.8로 업데이트한 실제 작업 기록입니다.  
> This repository documents the actual setup used to upgrade the userspace to Ubuntu 26.04.1 LTS while preserving the Joshua-Riek Rockchip BSP kernel family, and to update the built-in RKNPU kernel driver from 0.9.7 to 0.9.8 on an Orange Pi 5 Plus.

## Final verified environment / 최종 검증 환경

| Item | Verified value |
|---|---|
| Board | Orange Pi 5 Plus |
| SoC | Rockchip RK3588 |
| RAM | 32 GB |
| Base image | Joshua-Riek Ubuntu Rockchip 24.04 |
| Current userspace | Ubuntu 26.04.1 LTS (Resolute) |
| Original kernel | `6.1.0-1025-rockchip` |
| Custom kernel | `6.1.0-1025-73400e-rockchip` |
| Kernel package source | Ubuntu-rockchip `6.1.0-1025.25` |
| Joshua-Riek source commit | `7348ed5de414cc11a9831d269963d4a62f60b00e` |
| RKNPU driver | **0.9.8 / 20240828** |
| Official RKNPU 0.9.8 commit | `736d89f344156b75393b01ab2c0e3a06c39e110f` |
| RKLLM Runtime tested | 1.3.1 |
| Test model | Gemma 4 E2B-it, W8A8, RK3588, ctx16k |
| Decode baseline | ~8.0–8.2 tokens/s |
| NPU load | ~65–70% on Core0/Core1/Core2 |
| NPU freq under load | 1.0 GHz |
| DDR freq under load | 2.112 GHz |
| Observed max temperature | ~49 °C |

## Critical design rule / 핵심 원칙

**Do not install RKNPU 0.9.8 as an external DKMS module on this kernel.**  
**이 커널에서는 RKNPU 0.9.8을 외부 DKMS 모듈로 설치하지 않습니다.**

The installed Joshua-Riek kernel has:

```text
CONFIG_ROCKCHIP_RKNPU=y
```

Therefore RKNPU is built into the kernel image, not provided as `rknpu.ko`. The successful method was:

```text
exact Joshua-Riek 6.1.0-1025.25 source
        +
official Rockchip RKNPU 0.9.8 patch
        ↓
rebuild kernel Image/packages in-tree
        ↓
install as a separate ABI
6.1.0-1025-73400e-rockchip
```

This keeps the original `6.1.0-1025-rockchip` kernel available as a fallback.

## Documentation / 문서 순서

1. [System overview / 시스템 개요](docs/00_SYSTEM_OVERVIEW.md)
2. [Joshua-Riek base state / 초기 환경](docs/01_JOSHUA_RIEK_BASE.md)
3. [Ubuntu 26.04 userspace upgrade / 26.04 업그레이드](docs/02_UBUNTU_26_04_UPGRADE.md)
4. [Failed RKNPU 0.9.8 attempts / 실패한 외부 모듈 시도](docs/03_RKNPU_0_9_8_FAILED_ATTEMPTS.md)
5. [RKNPU 0.9.8 kernel build / 커널 빌드](docs/04_RKNPU_0_9_8_KERNEL_BUILD.md)
6. [Kernel install and boot / 설치 및 부팅](docs/05_KERNEL_INSTALL_AND_BOOT.md)
7. [Post-install issues / 설치 후 이슈](docs/06_POST_INSTALL_ISSUES.md)
8. [RKLLM + Gemma 4 test / 실제 NPU 성능 검증](docs/07_RKLLM_GEMMA4_TEST.md)

## Quick verification / 빠른 확인

```bash
uname -r
sudo cat /sys/kernel/debug/rknpu/version
dmesg | grep -Ei 'rknpu|npu|iommu'
```

Expected / 기대값:

```text
6.1.0-1025-73400e-rockchip
RKNPU driver: v0.9.8
[drm] Initialized rknpu 0.9.8 20240828 ...
```

Helper scripts are available under [scripts/](scripts/).

## Important notes / 주의

- This repository is a **reproduction log for this exact BSP/kernel path**, not a generic RK3588 installation guide.
- Ubuntu userspace and the Rockchip BSP kernel are intentionally treated separately.
- Kernel headers are not required for RKNN/RKLLM runtime use. A custom header-package dependency issue encountered during this setup is documented separately.
- For a remote-only board, changing the default U-Boot entry carries a real lockout risk. Keep the original kernel entry intact.

---

## English summary

This setup intentionally preserves the vendor-style Rockchip BSP kernel while moving the userspace forward to Ubuntu 26.04.1. The RKNPU driver is built into the kernel, so the correct upgrade path is an in-tree kernel rebuild using the exact Joshua-Riek source revision plus the official Rockchip RKNPU 0.9.8 patch. The resulting kernel was installed under a separate ABI and successfully validated with RKLLM 1.3.1 and a 3-NPU-core Gemma 4 E2B W8A8 model.
