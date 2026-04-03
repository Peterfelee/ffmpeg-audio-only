#!/usr/bin/env bash
# 在 pod 根目录执行：解压内置的 Sources/ffmpeg-kit-v6.0.zip，
# 按「仅本地媒体」取向打 iOS xcframework（等价官方 min：不启用 gmp/gnutls 等外链），输出到 Artifacts/。
# 适合本地文件路径的转码/拼接；若要让 ffmpeg 直接打开 https URL，需改脚本加上 --enable-gmp --enable-gnutls。
# 依赖：Xcode、Homebrew 等，见 README。首次构建耗时较长，但无需联网下载源码。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZIP="${ROOT}/Sources/ffmpeg-kit-v6.0.zip"
UP="${ROOT}/Sources/ffmpeg-kit-v6.0"          # 解压目标目录（已在 .gitignore 排除）
OUT="${ROOT}/Artifacts"
SRC_BUNDLE="${UP}/prebuilt/bundle-apple-xcframework-ios"

need=(ffmpegkit libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale)

# ---------- SKIP 逻辑 ----------
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

# ---------- 校验内置 zip ----------
if [[ ! -f "${ZIP}" ]]; then
  echo "error: 内置源码包不存在：${ZIP}" >&2
  echo "       请执行：curl -L https://github.com/arthenica/ffmpeg-kit/archive/refs/tags/v6.0.zip -o Sources/ffmpeg-kit-v6.0.zip" >&2
  exit 1
fi

# ---------- 解压（幂等：已存在 ios.sh 则跳过）----------
if [[ ! -f "${UP}/ios.sh" ]]; then
  echo "Extracting ${ZIP} into ${ROOT}/Sources ..."
  unzip -q "${ZIP}" -d "${ROOT}/Sources"
  # GitHub archive 解压出的顶层目录名为 ffmpeg-kit-6.0（无 v 前缀），统一重命名
  if [[ -d "${ROOT}/Sources/ffmpeg-kit-6.0" && ! -d "${UP}" ]]; then
    mv "${ROOT}/Sources/ffmpeg-kit-6.0" "${UP}"
  fi
fi

if [[ ! -f "${UP}/ios.sh" ]]; then
  echo "error: 解压后未找到 ios.sh，请检查 zip 内容是否完整" >&2
  exit 1
fi

# ---------- 编译 ----------
# -x：生成 xcframework。不追加 --enable-gmp/--enable-gnutls → 与官方 min 包同取向（无 TLS，仅本地/常规 demux）。
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

# ---------- 校验产物 ----------
for n in "${need[@]}"; do
  if [[ ! -d "${SRC_BUNDLE}/${n}.xcframework" ]]; then
    echo "error: missing ${SRC_BUNDLE}/${n}.xcframework after build" >&2
    exit 1
  fi
done

# ---------- 归档 ----------
echo "Staging xcframeworks into ${OUT} ..."
rm -rf "${OUT}"/*.xcframework
for n in "${need[@]}"; do
  cp -R "${SRC_BUNDLE}/${n}.xcframework" "${OUT}/"
done

echo "ok: FFmpegKit iOS xcframeworks are in ${OUT}"
