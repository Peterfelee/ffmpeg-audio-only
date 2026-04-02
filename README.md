# ffmpeg-audio-only

CocoaPods 库：**从 [arthenica/ffmpeg-kit](https://github.com/arthenica/ffmpeg-kit) v6.0 源码**在本地执行 `ios.sh` 生成 iOS **xcframework**，**不**通过 `:http` 下载预编译 zip。

## 行为说明

- `pod install` 时执行 `prepare_command` → `Scripts/build_ffmpeg_kit_ios_xcframework.sh`。
- 在 `Pods/AinoteFFmpegKitIOS/.upstream/ffmpeg-kit` 克隆上游（仅首次或清理后）。
- 构建输出复制到 `Pods/AinoteFFmpegKitIOS/Artifacts/*.xcframework`。
- `.upstream/`、`Artifacts/` 已 `.gitignore`，**不进本仓库**；每位开发者 / CI 机器本地编译一次（或见下文跳过变量）。

当前脚本使用的 `ios.sh` 参数等价官方 **https** 包（启用 **gmp、gnutls**），并默认只编 **arm64 设备 + arm64 模拟器**（适合 Apple Silicon Mac 开发）。若在 **Intel Mac** 上需要 **x86_64 模拟器**，请编辑脚本：去掉 `--disable-x86-64`，并按需调整模拟器架构（见 [Building](https://github.com/arthenica/ffmpeg-kit/wiki/Building)）。

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

`SKIP_FFMPEG_KIT_BUILD=1 pod install`

（用于调试；正常流程应依赖脚本完整构建。）

## 旧版 zip 流程

若改回预编译 zip，可使用主工程 `scripts/ffmpeg_kit_ios_make_pod_zip.sh` 自行打包并改 podspec 的 `s.source` / `vendored_frameworks` 路径（与本「源码构建」版互斥）。
