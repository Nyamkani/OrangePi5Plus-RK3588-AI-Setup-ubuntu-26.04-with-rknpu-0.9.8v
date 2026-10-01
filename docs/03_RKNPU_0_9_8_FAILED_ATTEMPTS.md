# 03. RKNPU 0.9.8 Failed Attempts / 실패한 외부 모듈 시도

## 한국어

초기에는 `airockchip/rknn-llm`에 포함된 다음 driver archive를 사용해 RKNPU 0.9.8을 external module / DKMS 형태로 올리려고 했습니다.

```text
rknpu_driver_0.9.8_20241009.tar.bz2
```

결과적으로 이 방식은 현재 kernel과 맞지 않았습니다.

## 실제로 발생한 문제

### 1. kernel-private header 참조

```c
#include <../drivers/devfreq/governor.h>
```

설치된 Ubuntu kernel headers에는 이런 kernel-internal/private header가 제공되지 않습니다.

즉 external module build에 필요한 공개 header 범위를 넘어섭니다.

### 2. `rockchip_opp_set_low_length` mismatch

2024-10-09 driver snapshot은 현재 사용 중인 2024-08 Joshua-Riek kernel source보다 뒤의 Rockchip kernel API를 기대했습니다.

그 결과 함수/API mismatch가 발생했습니다.

### 3. MODPOST / IOMMU symbol 충돌

기존 kernel은 이미:

```text
CONFIG_ROCKCHIP_RKNPU=y
```

이므로 RKNPU와 관련 IOMMU 코드가 kernel에 built-in 되어 있습니다.

동일 기능을 external module로 다시 넣으려고 하면서 symbol 충돌이 발생했습니다.

### 4. IOMMU/devfreq를 주석 처리하는 우회는 폐기

빌드를 통과시키기 위해 IOMMU나 devfreq 경로를 제거하는 접근도 검토했지만 사용하지 않았습니다.

RKNPU 0.9.8의 주요 변경점이 바로 multi-process / IOMMU domain handling 쪽이기 때문입니다.

공식 0.9.8 commit message:

```text
driver: rknpu: Update rknpu driver, version: 0.9.8

* Fix muti-process run error
* Fix mult-process domain switch error
```

따라서 해당 기능을 제거하고 0.9.8이라고 부르는 것은 목적과 맞지 않습니다.

## 최종 결론

```text
external .ko / DKMS  → 사용하지 않음
full matching source → 필요
in-tree patch        → 사용
```

또한 GCC version mismatch 자체가 Kbuild가 source compilation을 건너뛰는 원인은 아니었습니다. 핵심 문제는 **in-tree driver를 external-module 방식으로 다루려 한 구조적 mismatch와 kernel API 시점 차이**였습니다.

---

## English

The first approach used the `rknpu_driver_0.9.8_20241009.tar.bz2` snapshot as an external module/DKMS build.

That approach failed for structural reasons:

- it includes kernel-private headers such as `drivers/devfreq/governor.h`
- it expects newer Rockchip kernel APIs such as `rockchip_opp_set_low_length`
- the installed kernel already contains RKNPU/IOMMU code built-in
- MODPOST therefore encounters symbol conflicts

Commenting out IOMMU/devfreq code was rejected because the 0.9.8 changes specifically address multi-process and IOMMU-domain issues.

The correct solution was to patch the exact matching kernel source in-tree.
