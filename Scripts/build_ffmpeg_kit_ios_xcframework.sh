#!/usr/bin/env bash
# 在 pod 根目录执行：克隆 ffmpeg-kit v6.0，按「https」包（gmp+gnutls）打 iOS xcframework，输出到 Artifacts/。
# 依赖：Xcode、Homebrew 等，见 README。首次构建需联网下载 FFmpeg 与各依赖源码，耗时较长。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UP="${ROOT}/.upstream/ffmpeg-kit"
OUT="${ROOT}/Artifacts"
SRC_BUNDLE="${UP}/prebuilt/bundle-apple-xcframework-ios"

need=(ffmpegkit libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale)

if [[ -n "${SKIP_FFMPEG_KIT_BUILD:-}" ]]; then
  for n in "${need[@]}"; do
    if [[ ! -d "${OUT}/${n}.xcframework" ]]; then
      echo "error: SKIP_FFMPEG_KIT_BUILD set but missing ${OUT}/${n}.xcframework" >&2
      exit 1
    fi
  done
  echo "ok: skip build (Artifacts present)"
  exit 0
fi

mkdir -p "${OUT}"

if [[ -d "${UP}" ]] && [[ ! -f "${UP}/ios.sh" ]]; then
  echo "warning: incomplete ${UP}, removing for clean clone" >&2
  rm -rf "${UP}"
fi

if [[ ! -f "${UP}/ios.sh" ]]; then
  mkdir -p "$(dirname "${UP}")"
  echo "Cloning arthenica/ffmpeg-kit (v6.0) into ${UP} ..."
  git clone --branch v6.0 --single-branch https://github.com/arthenica/ffmpeg-kit.git "${UP}"
fi

# 与官方「https」包一致：gmp、gnutls；xcframework。-x
# 架构：默认仅 arm64 真机 + arm64 模拟器（Apple Silicon 开发机）。Intel Mac 模拟器需去掉 --disable-x86-64 并视情况关闭 arm64-simulator，见 README。
IOS_FLAGS=(
  -x
  --enable-gmp
  --enable-gnutls
  --disable-armv7
  --disable-armv7s
  --disable-arm64e
  --disable-i386
  --disable-x86-64
  --disable-arm64-mac-catalyst
  --disable-x86-64-mac-catalyst
)

echo "Running ios.sh in ${UP} (first run can take a long time) ..."
( cd "${UP}" && ./ios.sh "${IOS_FLAGS[@]}" )

for n in "${need[@]}"; do
  if [[ ! -d "${SRC_BUNDLE}/${n}.xcframework" ]]; then
    echo "error: missing ${SRC_BUNDLE}/${n}.xcframework after build" >&2
    exit 1
  fi
done

echo "Staging xcframeworks into ${OUT} ..."
rm -rf "${OUT}"/*.xcframework
for n in "${need[@]}"; do
  cp -R "${SRC_BUNDLE}/${n}.xcframework" "${OUT}/"
done

echo "ok: FFmpegKit iOS xcframeworks are in ${OUT}"
