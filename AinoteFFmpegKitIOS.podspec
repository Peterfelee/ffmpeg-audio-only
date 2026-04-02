# frozen_string_literal: true

# 本 podspec 设计为放在仓库根目录：https://github.com/Peterfelee/ffmpeg-audio-only
# 二进制 zip 建议托管在「同一仓库的 GitHub Releases」；将下方 s.source 的 :http 改为你的 Release 资源直链。
# 在出自建 zip 之前，可暂时保留 voyageh 的 https 镜像地址以保证 pod install 可用。

Pod::Spec.new do |s|
  s.name             = 'AinoteFFmpegKitIOS'
  s.version          = '6.0.0-audio'
  s.summary          = 'FFmpegKit iOS xcframework (https / audio-oriented, vendored zip)'
  s.description      = 'Vendored FFmpegKit + libav* iOS xcframeworks. Host podspec lives at github.com/Peterfelee/ffmpeg-audio-only; replace s.source with your Release zip when using a custom audio-only build.'
  s.homepage         = 'https://github.com/Peterfelee/ffmpeg-audio-only'
  s.license          = { :type => 'LGPL-3.0' }
  s.author           = { 'Peterfelee' => 'https://github.com/Peterfelee' }

  s.platform         = :ios, '12.1'
  s.requires_arc     = true

  # 使用自建包时：在 GitHub 创建 Release（例如 tag 6.0.0-audio），上传 ffmpeg_kit_ios_make_pod_zip.sh 生成的 zip，然后把 URL 换成该资源的「Download」直链。
  # 示例（需先上传对应资源后取消注释并删掉 voyageh 行）:
  # s.source = { :http => 'https://github.com/Peterfelee/ffmpeg-audio-only/releases/download/6.0.0-audio/ffmpeg-kit-ios-audio.zip' }
  s.source           = {
    :http => 'https://github.com/voyageh/ffmpeg-kit/releases/download/v6.0/ffmpeg-kit-https-6.0-ios-xcframework.zip'
  }

  s.libraries        = 'z', 'bz2', 'c++', 'iconv'
  s.frameworks       = 'AudioToolbox', 'AVFoundation', 'CoreMedia', 'VideoToolbox'

  s.vendored_frameworks = %w[
    ffmpegkit.xcframework
    libavcodec.xcframework
    libavdevice.xcframework
    libavfilter.xcframework
    libavformat.xcframework
    libavutil.xcframework
    libswresample.xcframework
    libswscale.xcframework
  ]

  s.module_name = 'ffmpegkit'

  s.user_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/AinoteFFmpegKitIOS/ffmpegkit.xcframework/ios-arm64/ffmpegkit.framework/Headers" "${PODS_ROOT}/AinoteFFmpegKitIOS/ffmpegkit.xcframework/ios-arm64-simulator/ffmpegkit.framework/Headers"'
  }
end
