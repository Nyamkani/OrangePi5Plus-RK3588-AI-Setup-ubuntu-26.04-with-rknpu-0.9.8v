# 07. RKLLM + Gemma 4 Test / RKLLM + Gemma 4 실제 테스트

## 한국어

RKNPU 0.9.8 설치가 끝난 뒤 실제 NPU workload로 검증했습니다.

## 1. driver 검증

```bash
uname -r
sudo cat /sys/kernel/debug/rknpu/version
dmesg | grep -Ei 'rknpu|npu|iommu'
```

확인:

```text
6.1.0-1025-73400e-rockchip
RKNPU driver: v0.9.8
[drm] Initialized rknpu 0.9.8 20240828 ...
```

## 2. RKLLM

사용한 runtime:

```text
rkllm-runtime version: 1.3.1
```

사용한 모델:

```text
gemma-4-E2B-it_w8a8_rk3588_ctx16384.rkllm
```

모델 source:

```text
ndneighbor/gemma-4-E2B-it-RKLLM-RK3588-W8A8-ctx16k
```

직접 다운로드는 Hugging Face의 `resolve/main` URL을 사용했습니다.

예:

```bash
mkdir -p ~/rkllm-models/gemma4
cd ~/rkllm-models/gemma4

wget -c   "https://huggingface.co/ndneighbor/gemma-4-E2B-it-RKLLM-RK3588-W8A8-ctx16k/resolve/main/gemma-4-E2B-it_w8a8_rk3588_ctx16384.rkllm"
```

모델 초기화 로그:

```text
rkllm-runtime version: 1.3.1
rknpu driver version: 0.9.8
rkllm-toolkit version: 1.3.0
max_context_limit: 16384
npu_core_num: 3
target_platform: RK3588
model_dtype: W8A8
Enabled cpus: [4, 5, 6, 7]
rkllm init success
```

## 3. 실행 예

```bash
cd ~/rknn-llm/examples/rkllm_api_demo/deploy/install/demo_Linux_aarch64

export LD_LIBRARY_PATH="$PWD/lib"
export RKLLM_LOG_LEVEL=1

./llm_demo   ~/rkllm-models/gemma4/gemma-4-E2B-it_w8a8_rk3588_ctx16384.rkllm   1024   16384
```

## 4. baseline

1024-token test:

```text
Model init time : 3024.87 ms

Prefill
- 121 tokens
- 708.77 ms
- 5.86 ms/token
- 170.72 tokens/s

Generate
- 1023 tokens
- 127281.75 ms
- 124.42 ms/token
- 8.04 tokens/s

Peak RKLLM memory
- 3032.43 MB
```

다른 512-token tests에서도 generate는 약:

```text
8.18
8.23
8.24
8.21 tokens/s
```

범위로 안정적이었습니다.

## 5. NPU / DDR / thermal

추론 중 측정:

```text
NPU Core0: ~65–70%
NPU Core1: ~65–70%
NPU Core2: ~65–70%

NPU freq: 1000000000 Hz
DDR freq: 2112000000 Hz
max observed temperature: ~49 °C
```

즉:

- 3개 NPU core가 모두 사용됨
- NPU frequency는 최대 1 GHz
- DDR frequency는 최대 2.112 GHz
- thermal throttling 징후는 관찰되지 않음
- 2분 이상 decode에서도 token/s가 크게 무너지지 않음

### CPU 관찰

초기 관찰에서:

```text
CPU 0–3 : mostly <10%
CPU 4–6 : mostly <30%
CPU 7   : roughly 50–70%
```

RKLLM log의 enabled CPU set은 `[4,5,6,7]`이었습니다.

## 6. NPU 80% 목표에 대한 해석

초기 목표는 3개 NPU core 모두 80% 이상이었지만, 실제 Gemma 4 decode에서는 최대 NPU/DDR clock 상태에서도 약 65–70%가 안정적으로 유지되었습니다.

따라서 단순 utilization 수치보다 다음을 함께 보는 것이 더 의미 있습니다.

1. tokens/s
2. prefill throughput
3. decode latency
4. 3-core load balance
5. temperature / throttling

현재 baseline은 정상적인 3-core RKLLM execution의 기준값으로 보관합니다.

---

## English

The final validation used RKLLM Runtime 1.3.1 with a Gemma 4 E2B W8A8 model compiled for RK3588 with three NPU cores.

Verified runtime metadata:

```text
RKNPU driver  : 0.9.8
RKLLM runtime : 1.3.1
Toolkit       : 1.3.0
NPU cores     : 3
Context       : 16384
Model dtype   : W8A8
```

Measured decode performance was approximately 8.0–8.2 tokens/s.

All three NPU cores were active at approximately 65–70% during sustained generation, with the NPU at 1 GHz and DDR at 2.112 GHz. Peak observed temperature was approximately 49 °C.
