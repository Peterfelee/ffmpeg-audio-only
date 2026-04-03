# ffmpeg-audio-only

CocoaPods 库：**从内置的 `Sources/ffmpeg-kit-v6.0.zip`**（arthenica/ffmpeg-kit v6.0 源码）在本地执行 `ios.sh` 生成 iOS **xcframework**，**不**通过网络下载任何内容。

## 行为说明

- `pod install` 时执行 `prepare_command` → `Scripts/build_ffmpeg_kit_ios_xcframework.sh`。
- 脚本解压 `Sources/ffmpeg-kit-v6.0.zip` 到 `Sources/ffmpeg-kit-v6.0/`（已 `.gitignore`，仅首次或清理后解压）。
- 构建输出复制到 `Pods/AinoteFFmpegKitIOS/Artifacts/*.xcframework`。
- `Sources/ffmpeg-kit-v6.0/`、`Artifacts/` 已 `.gitignore`，**不进本仓库**；`Sources/ffmpeg-kit-v6.0.zip` **进仓库**（约 25MB）。

**取向（只要本地音频处理）**：脚本使用 `./ios.sh -x` 且**不**启用 `gmp` / `gnutls`，与官方 **min** 包一致——适合**本地路径**的拼接、转码等；应用自己用 `URLSession` 下载文件再交给 FFmpeg 即可。若将来要让 **ffmpeg 直接读 `https://` 输入**，在 `Scripts/build_ffmpeg_kit_ios_xcframework.sh` 的 `IOS_FLAGS` 里加上 `--enable-gmp` 与 `--enable-gnutls`。

默认只编 **arm64 真机 + arm64 模拟器**。**Intel Mac** 需要 x86_64 模拟器时，编辑脚本去掉 `--disable-x86-64` 并视情况调整模拟器架构（见 [Building](https://github.com/arthenica/ffmpeg-kit/wiki/Building)）。

## 初次添加 zip（仓库维护者操作，一次性）

```bash
mkdir -p Sources
curl -L https://github.com/arthenica/ffmpeg-kit/archive/refs/tags/v6.0.zip \
     -o Sources/ffmpeg-kit-v6.0.zip
git add Sources/ffmpeg-kit-v6.0.zip
git commit -m "chore: embed ffmpeg-kit v6.0 source zip"
git push
```

> zip 约 25MB，低于 GitHub 单文件 100MB 限制，无需 Git LFS。提交前可用 `du -sh Sources/ffmpeg-kit-v6.0.zip` 确认。

## 环境依赖

与上游一致，需安装（示例用 Homebrew）：

`autoconf automake libtool pkg-config curl git doxygen nasm cmake gperf texinfo yasm bison wget gettext meson ninja` 等，详见 [apple/README](https://github.com/arthenica/ffmpeg-kit/blob/main/apple/README.md) 与 Wiki。

## 主工程 Podfile

```ruby
pod 'AinoteFFmpegKitIOS', :git => 'https://github.com/Peterfelee/ffmpeg-audio-only.git', :branch => 'main'
```

## 与 AINoteTaker 同步

主工程目录 `ffmpeg-audio-only-publish/` 与本仓库应对齐；修改后复制到本仓库根目录并 `git push`，再在客户端执行 `pod update AinoteFFmpegKitIOS`。

## 跳过构建（仅当 Artifacts 已存在）

若你已在 pod 目录内手动生成过 `Artifacts/` 下 8 个 xcframework，可临时：

```bash
SKIP_FFMPEG_KIT_BUILD=1 pod install
```

（用于调试；正常流程应依赖脚本完整构建。）

## 旧版 zip 流程

若改回预编译 zip，可使用主工程 `scripts/ffmpeg_kit_ios_make_pod_zip.sh` 自行打包并改 podspec 的 `s.source` / `vendored_frameworks` 路径（与本「源码构建」版互斥）。
