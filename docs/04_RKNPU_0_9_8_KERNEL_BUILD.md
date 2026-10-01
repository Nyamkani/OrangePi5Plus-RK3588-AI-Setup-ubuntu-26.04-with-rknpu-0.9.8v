# 04. RKNPU 0.9.8 Kernel Build / RKNPU 0.9.8 커널 빌드

## 한국어

이 단계가 실제 해결 방법입니다.

## 1. 정확히 일치하는 Joshua-Riek source 준비

현재 설치된 kernel package source release:

```text
Ubuntu-rockchip-6.1.0-1025.25
commit: 7348ed5de414cc11a9831d269963d4a62f60b00e
```

clone:

```bash
git clone --branch noble --single-branch   https://github.com/Joshua-Riek/linux-rockchip.git

cd linux-rockchip

git switch -c rknpu-0.9.8   7348ed5de414cc11a9831d269963d4a62f60b00e
```

## 2. 공식 Rockchip RKNPU 0.9.8 patch 적용

공식 commit:

```text
736d89f344156b75393b01ab2c0e3a06c39e110f
```

```bash
wget -O /tmp/rknpu-0.9.8.patch   https://github.com/rockchip-linux/kernel/commit/736d89f344156b75393b01ab2c0e3a06c39e110f.patch

git apply --check /tmp/rknpu-0.9.8.patch
git apply /tmp/rknpu-0.9.8.patch
```

변경되는 6개 파일:

```text
drivers/rknpu/include/rknpu_drv.h
drivers/rknpu/include/rknpu_iommu.h
drivers/rknpu/rknpu_drv.c
drivers/rknpu/rknpu_gem.c
drivers/rknpu/rknpu_iommu.c
drivers/rknpu/rknpu_job.c
```

patch 후 version:

```c
#define DRIVER_DATE "20240828"
#define DRIVER_MAJOR 0
#define DRIVER_MINOR 9
#define DRIVER_PATCHLEVEL 8
```

### 왜 이 patch를 그대로 적용할 수 있었나

Joshua-Riek의 해당 0.9.7 source와 official Rockchip 0.9.7 기준에서 위 6개 파일이 byte/blob 기준으로 일치하는 것을 확인했습니다.

따라서 전체 2024-10 snapshot을 가져오는 것보다 official 0.9.8 commit만 적용하는 쪽이 안전했습니다.

## 3. Ubuntu 26.04 host build compatibility issue

`prepare-rockchip` 도중:

```text
tools/lib/bpf/libbpf.c
error: assignment discards 'const' qualifier from pointer target type
```

문제 부분:

```c
char *next_path;
next_path = strchr(s, ':');
```

수정:

```diff
- char *next_path;
+ const char *next_path;
```

이 변경은 RKNPU 기능 수정이 아니라 newer userspace/header 환경에서 kernel host tool을 빌드하기 위한 compatibility fix입니다.

patch 파일은 [../patches/libbpf-const-fix.patch](../patches/libbpf-const-fix.patch)에 기록했습니다.

## 4. AUTOBUILD ABI suffix 문제

처음 `AUTOBUILD=1` 상태에서:

```text
KERNELVERSION=6.1.0-1025-ref-rockchip
```

이 생성되었습니다.

원인은 packaging logic이 `.git/HEAD` 문자열을 직접 잘라 suffix를 만들기 때문입니다.

branch 상태의 `.git/HEAD`:

```text
ref: refs/heads/...
```

해결:

```bash
git switch --detach
```

그 후 `.git/HEAD`는 exact commit SHA를 담고, ABI가:

```text
6.1.0-1025-73400e-rockchip
```

으로 생성되었습니다.

## 5. prepare

```bash
fakeroot debian/rules clean   AUTOBUILD=1   gcc=gcc-13

fakeroot debian/rules prepare-rockchip   AUTOBUILD=1   gcc=gcc-13
```

정상 확인:

```text
KERNELVERSION=6.1.0-1025-73400e-rockchip
HOSTCC=aarch64-linux-gnu-gcc-13
CC=aarch64-linux-gnu-gcc-13
```

prepared config:

```text
CONFIG_PM_DEVFREQ=y
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_ROCKCHIP_RKNPU=y
CONFIG_ROCKCHIP_RKNPU_DEBUG_FS=y
CONFIG_ROCKCHIP_RKNPU_DRM_GEM=y
```

## 6. build

```bash
fakeroot debian/rules binary-rockchip   AUTOBUILD=1   gcc=gcc-13   DEB_BUILD_OPTIONS="parallel=$(nproc)"
```

생성된 주요 package:

```text
linux-image-6.1.0-1025-73400e-rockchip
linux-modules-6.1.0-1025-73400e-rockchip
linux-modules-extra-6.1.0-1025-73400e-rockchip
linux-headers-6.1.0-1025-73400e-rockchip
linux-buildinfo-...
linux-tools-...
```

---

## English

The successful build used the exact Joshua-Riek source revision corresponding to package release `6.1.0-1025.25`, then applied only the official Rockchip RKNPU 0.9.8 commit.

A separate ABI was intentionally generated using `AUTOBUILD=1`:

```text
Original: 6.1.0-1025-rockchip
New     : 6.1.0-1025-73400e-rockchip
```

This avoids overwriting the known-good kernel.

Two build-environment details were important:

1. a one-line const-correctness fix in `tools/lib/bpf/libbpf.c`
2. detached HEAD before packaging so the AUTOBUILD suffix is based on the commit SHA rather than the literal string `ref`
