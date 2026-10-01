# 02. Ubuntu 26.04 Userspace Upgrade / Ubuntu 26.04 userspace 업그레이드

## 한국어

목표는 Ubuntu userspace를 26.04.1 LTS (Resolute)까지 올리되, **Joshua-Riek Rockchip BSP kernel 6.1 계열을 유지**하는 것이었습니다.

최종 확인 상태:

```bash
uname -r
lsb_release -a
```

```text
Kernel   : 6.1.0-1025-rockchip
Userspace: Ubuntu 26.04.1 LTS (Resolute)
```

### kernel 관련 package hold

실제 유지한 package:

```bash
sudo apt-mark hold   linux-firmware   linux-headers-rockchip   linux-image-rockchip
```

확인:

```bash
apt-mark showhold
```

기록된 hold 항목:

```text
linux-firmware
linux-headers-rockchip
linux-image-rockchip
```

### 중요한 원칙

이 작업에서는 Ubuntu userspace 업그레이드와 Rockchip BSP kernel 업그레이드를 같은 작업으로 취급하지 않았습니다.

```text
userspace → Ubuntu 26.04.1
kernel    → Joshua-Riek 6.1.0-1025-rockchip 유지
```

### 재설치 시 주의

현재 대화 기록에는 24.04 → 26.04.1로 넘어갈 때 사용한 **모든 release-upgrade 명령의 정확한 원문이 보존되어 있지 않습니다**.

따라서 이 문서에서 확실하게 재현 가능한 것은:

- base가 Joshua-Riek Ubuntu Rockchip 24.04였음
- kernel 관련 3개 package를 hold했음
- 최종 userspace가 Ubuntu 26.04.1 LTS Resolute였음
- kernel이 `6.1.0-1025-rockchip`로 유지되었음

입니다.

재설치할 때 distribution upgrade 자체는 당시 Ubuntu release-upgrade 절차에 맞게 수행하고, **kernel hold와 업그레이드 후 `uname -r` 검증을 반드시 먼저 확인**하는 것이 핵심입니다.

---

## English

The userspace was upgraded from a Joshua-Riek Ubuntu 24.04 base to Ubuntu 26.04.1 LTS (Resolute), while intentionally preserving the Rockchip BSP kernel.

The packages held during the upgrade were:

```text
linux-firmware
linux-headers-rockchip
linux-image-rockchip
```

Expected end state:

```text
Userspace : Ubuntu 26.04.1 LTS
Kernel    : 6.1.0-1025-rockchip
```

### Reproduction note

The complete original release-upgrade command sequence was not preserved in the current conversation record. This document therefore does not invent those missing commands.

The reliable checkpoints are the package holds and the final kernel/userspace versions above.
