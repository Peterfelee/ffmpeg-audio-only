# ffmpeg-audio-only

用于在 CocoaPods 中分发 **FFmpegKit iOS xcframework** 的 podspec 仓库（不包含二进制本身，二进制通过 `s.source` 的 HTTP zip 拉取）。

## 推送到本仓库

在本地执行（将路径换成你本机 `AINoteTaker` 工程目录）：

```bash
cd /path/to/clone/of/ffmpeg-audio-only
cp /path/to/AINoteTaker/ffmpeg-audio-only-publish/AinoteFFmpegKitIOS.podspec .
# 按需编辑 README，然后：
git add AinoteFFmpegKitIOS.podspec README.md
git commit -m "Add AinoteFFmpegKitIOS podspec"
git push origin main
```

## 换成自建 audio zip

1. 按 [ffmpeg-kit wiki](https://github.com/arthenica/ffmpeg-kit/wiki) 本地构建 iOS xcframework（audio 配置），将 8 个 `*.xcframework` 放在同一目录。
2. 在 AINoteTaker 工程中运行：  
   `./scripts/ffmpeg_kit_ios_make_pod_zip.sh /path/to/dir/containing/ffmpegkit.xcframework ffmpeg-kit-ios-audio.zip`
3. 在 GitHub 本仓库 **Releases** 新建一条，例如 Tag `6.0.0-audio`，上传 `ffmpeg-kit-ios-audio.zip`。
4. 编辑根目录 `AinoteFFmpegKitIOS.podspec`：把 `s.source` 改为该资源的直链，例如：  
   `https://github.com/Peterfelee/ffmpeg-audio-only/releases/download/6.0.0-audio/ffmpeg-kit-ios-audio.zip`  
   可选：增加 `:sha256 => '...'`（`shasum -a 256 ffmpeg-kit-ios-audio.zip`）。
5. 若 zip 变更，同步修改 `s.version` 并提交、打 tag（与主工程 `pod update` 一致即可）。

## 主工程引用

在 `Podfile` 中使用：

```ruby
pod 'AinoteFFmpegKitIOS', :git => 'https://github.com/Peterfelee/ffmpeg-audio-only.git', :branch => 'main'
```

不要使用 `:path` 指向仅含 podspec 的目录；vendored zip 必须由 podspec 的 `s.source` 下载。
