#!/usr/bin/env bash
# 在 pod 根目录执行：克隆 ffmpeg-kit v6.0，按「仅本地媒体」取向打 iOS xcframework（等价官方 min：不启用 gmp/gnutls 等外链），输出到 Artifacts/。
# 适合本地文件路径的转码/拼接；若要让 ffmpeg 直接打开 https URL，需改脚本加上 --enable-gmp --enable-gnutls。
# 依赖：Xcode、Homebrew 等，见 README。首次构建需联网下载 FFmpeg 源码，耗时较长。
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

# -x：xcframework。不追加 --enable-gmp/--enable-gnutls → 与官方 min 包同取向（无 TLS，仅本地/常规 demux）。
# 架构：默认仅 arm64 真机 + arm64 模拟器。Intel Mac 模拟器见 README。
IOS_FLAGS=(
  -x
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
