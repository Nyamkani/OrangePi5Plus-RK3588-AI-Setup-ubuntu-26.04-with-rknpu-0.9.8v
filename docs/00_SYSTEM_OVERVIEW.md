# 00. System Overview / 시스템 개요

## 한국어

이 저장소는 Orange Pi 5 Plus (RK3588, 32 GB)에서 실제로 수행한 다음 작업을 재현하기 위한 기록입니다.

1. Joshua-Riek Ubuntu Rockchip 24.04 기반 이미지 사용
2. Rockchip BSP kernel `6.1.0-1025-rockchip`을 유지한 채 userspace를 Ubuntu 26.04.1 LTS (Resolute)로 업그레이드
3. 기존 built-in RKNPU driver 0.9.7 확인
4. RKNPU 0.9.8을 external module/DKMS로 올리려다 실패
5. 정확히 일치하는 Joshua-Riek kernel source에 공식 Rockchip 0.9.8 patch를 적용
6. 별도 ABI의 kernel을 빌드/설치
7. 새 kernel에서 RKNPU 0.9.8 확인
8. RKLLM Runtime 1.3.1 + Gemma 4 E2B W8A8 모델로 NPU 3-core 추론 검증

### 최종 환경

```text
Board          : Orange Pi 5 Plus
SoC            : RK3588
RAM            : 32 GB
Userspace      : Ubuntu 26.04.1 LTS (Resolute)
Original kernel: 6.1.0-1025-rockchip
Custom kernel  : 6.1.0-1025-73400e-rockchip
RKNPU          : 0.9.8 (20240828)
RKLLM Runtime  : 1.3.1
```

### 가장 중요한 설계 결정

현재 Joshua-Riek kernel은 다음과 같습니다.

```text
CONFIG_ROCKCHIP_RKNPU=y
```

즉 RKNPU는 `.ko` 외부 모듈이 아니라 kernel Image에 built-in 되어 있습니다.

따라서 최종적으로 채택한 방법은:

```text
Joshua-Riek exact kernel source
+ official Rockchip RKNPU 0.9.8 commit
→ in-tree kernel rebuild
→ separate ABI installation
```

입니다.

기존 kernel `6.1.0-1025-rockchip`은 삭제하지 않고 fallback으로 유지했습니다.

---

## English

This repository is a reproducibility log for the actual setup performed on an Orange Pi 5 Plus (RK3588, 32 GB).

The final strategy was:

1. Start from a Joshua-Riek Ubuntu Rockchip 24.04 image.
2. Upgrade userspace to Ubuntu 26.04.1 LTS while preserving the Rockchip BSP kernel family.
3. Confirm that the original RKNPU 0.9.7 driver is built into the kernel.
4. Abandon the external-module/DKMS approach after real compatibility failures.
5. Use the exact Joshua-Riek source revision corresponding to the installed kernel package.
6. Apply the official Rockchip RKNPU 0.9.8 commit in-tree.
7. Build and install a separate kernel ABI.
8. Verify RKNPU 0.9.8 and run a 3-core RKLLM workload.

### Final verified state

```text
Ubuntu userspace : 26.04.1 LTS
Original kernel  : 6.1.0-1025-rockchip
Custom kernel    : 6.1.0-1025-73400e-rockchip
RKNPU driver     : 0.9.8
Driver date      : 20240828
```

The original kernel remains installed for recovery.
