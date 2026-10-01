# 05. Kernel Install and Boot / 커널 설치 및 부팅

## 한국어

## 1. 설치 package

실제 부팅에 필요한 핵심 package는 다음입니다.

```text
linux-image
linux-modules
linux-modules-extra
```

headers는 RKNN/RKLLM 실행에 필요하지 않으며, 이후 dependency 문제가 발생했으므로 재설치 시에는 우선 제외하는 것을 권장합니다.

예:

```bash
sudo dpkg -i   ../linux-modules-6.1.0-1025-73400e-rockchip_6.1.0-1025.25_arm64.deb   ../linux-modules-extra-6.1.0-1025-73400e-rockchip_6.1.0-1025.25_arm64.deb   ../linux-image-6.1.0-1025-73400e-rockchip_6.1.0-1025.25_arm64.deb
```

## 2. 설치 결과 확인

```bash
ls -lh   /boot/vmlinuz-6.1.0-1025-73400e-rockchip   /boot/initrd.img-6.1.0-1025-73400e-rockchip

ls -ld   /lib/modules/6.1.0-1025-73400e-rockchip   /lib/firmware/6.1.0-1025-73400e-rockchip/device-tree
```

## 3. U-Boot extlinux 생성

```bash
sudo u-boot-update
cat /boot/extlinux/extlinux.conf
```

실제 생성 결과는 다음 구조였습니다.

```text
l0  = 6.1.0-1025-rockchip
l0r = original rescue
l1  = 6.1.0-1025-73400e-rockchip
l1r = custom rescue
```

기본값은 처음에는 `l0`, 즉 기존 kernel이었습니다.

## 4. 원격 장비에서 새 kernel을 기본값으로 변경

당시 Orange Pi는 원격으로 접속 중이어서 U-Boot 메뉴에서 직접 `l1`을 선택하기 어려웠습니다.

기존 설정 백업:

```bash
sudo cp -a /etc/default/u-boot /etc/default/u-boot.pre-rknpu98
sudo cp -a /boot/extlinux/extlinux.conf   /boot/extlinux/extlinux.conf.pre-rknpu98
```

새 kernel을 default로 설정:

```bash
echo 'U_BOOT_DEFAULT="l1"' | sudo tee -a /etc/default/u-boot
sudo u-boot-update
grep '^default ' /boot/extlinux/extlinux.conf
```

기대값:

```text
default l1
```

재부팅:

```bash
sync
sudo reboot
```

부팅 확인:

```bash
uname -r
```

```text
6.1.0-1025-73400e-rockchip
```

## 원격 부팅 위험

이 방식은 새 kernel이 boot 실패하면 SSH로 되돌리기 어렵습니다.

당시 확인 결과:

- `CONFIG_KEXEC*` 없음
- `fw_printenv` → `Cannot initialize environment`
- 자동 bootcount fallback을 즉시 구성할 근거가 없음

따라서 이 변경은 실제로 위험을 감수하고 진행했습니다.

기존 `l0` kernel 항목 자체는 삭제하지 않았습니다.

---

## English

The custom kernel was installed side-by-side with the original kernel.

U-Boot/extlinux generated both entries, preserving recovery:

```text
l0 = original kernel
l1 = RKNPU 0.9.8 custom kernel
```

Because the board was remote-only, `U_BOOT_DEFAULT="l1"` was set before reboot.

This carries a real remote-lockout risk because no verified automatic fallback mechanism was available. Keep the original kernel installed and keep its extlinux entry intact.
