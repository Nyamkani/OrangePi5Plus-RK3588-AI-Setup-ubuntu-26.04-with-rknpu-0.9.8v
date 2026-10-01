# 01. Joshua-Riek Base State / 초기 환경

## 한국어

초기 환경은 Joshua-Riek Ubuntu Rockchip 24.04 계열 이미지였습니다.

핵심은 **userspace와 kernel을 분리해서 관리**하는 것입니다.

초기 kernel:

```bash
uname -r
```

```text
6.1.0-1025-rockchip
```

### RKNPU가 built-in인지 확인

```bash
grep -E 'CONFIG_(ROCKCHIP_RKNPU|PM_DEVFREQ)' /boot/config-$(uname -r)
find /lib/modules/$(uname -r) -iname 'rknpu*.ko*'
```

확인된 config:

```text
CONFIG_PM_DEVFREQ=y
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_ROCKCHIP_RKNPU=y
CONFIG_ROCKCHIP_RKNPU_DEBUG_FS=y
# CONFIG_ROCKCHIP_RKNPU_PROC_FS is not set
# CONFIG_ROCKCHIP_RKNPU_FENCE is not set
# CONFIG_ROCKCHIP_RKNPU_SRAM is not set
CONFIG_ROCKCHIP_RKNPU_DRM_GEM=y
```

`find` 결과에 `rknpu.ko`가 없었던 것은 정상입니다.

### 의미

```text
CONFIG_ROCKCHIP_RKNPU=y
```

는 RKNPU가 module이 아니라 kernel Image에 포함된다는 뜻입니다.

따라서 이후 RKNPU 버전 업그레이드는 external `.ko` 교체가 아니라 **kernel in-tree rebuild**가 필요합니다.

### 원본 driver 버전

Joshua-Riek `6.1.0-1025.25` source의 RKNPU는:

```c
#define DRIVER_DATE "20240424"
#define DRIVER_MAJOR 0
#define DRIVER_MINOR 9
#define DRIVER_PATCHLEVEL 7
```

즉 0.9.7입니다.

---

## English

The base image used the Joshua-Riek Rockchip Ubuntu stack with kernel:

```text
6.1.0-1025-rockchip
```

The key discovery was:

```text
CONFIG_ROCKCHIP_RKNPU=y
```

This means RKNPU is built into the kernel image. No standalone `rknpu.ko` is expected.

The original driver version in the matching Joshua-Riek source was:

```text
RKNPU 0.9.7
DRIVER_DATE 20240424
```

This fact determines the entire upgrade strategy: use an in-tree kernel rebuild, not DKMS.
