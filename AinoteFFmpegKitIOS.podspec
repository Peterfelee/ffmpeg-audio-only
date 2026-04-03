# frozen_string_literal: true

# 源码构建：pod install 时运行 Scripts/build_ffmpeg_kit_ios_xcframework.sh，
# 解压内置的 Sources/ffmpeg-kit-v6.0.zip 并执行 ios.sh，将 xcframework 生成到 Artifacts/（不入库）。
# 不使用 :http zip，不依赖运行时网络。仓库：https://github.com/Peterfelee/ffmpeg-audio-only

Pod::Spec.new do |s|
  s.name             = 'AinoteFFmpegKitIOS'
  s.version          = '6.0.0-source.3'
  s.summary          = 'FFmpegKit iOS from embedded source zip (local audio/files; min-equivalent, fully offline build)'
  s.description      = 'Extracts bundled Sources/ffmpeg-kit-v6.0.zip during pod install, runs ios.sh -x without gmp/gnutls (local media / min-style). No network required at build time. For ffmpeg-side HTTPS inputs add those enables in the build script.'
  s.homepage         = 'https://github.com/Peterfelee/ffmpeg-audio-only'
  s.license          = { :type => 'LGPL-3.0' }
  s.author           = { 'Peterfelee' => 'https://github.com/Peterfelee' }

  s.platform         = :ios, '12.1'
  s.requires_arc     = true

  s.source           = {
    :git => 'https://github.com/Peterfelee/ffmpeg-audio-only.git',
    :branch => 'main'
  }

  s.prepare_command  = 'bash ./Scripts/build_ffmpeg_kit_ios_xcframework.sh'

  # 保留脚本和内置 zip，防止 CocoaPods 在安装阶段清理这些文件
  s.preserve_paths   = [
    'Scripts/build_ffmpeg_kit_ios_xcframework.sh',
    'Sources/ffmpeg-kit-v6.0.zip'
  ]

  s.libraries        = 'z', 'bz2', 'c++', 'iconv'
  s.frameworks       = 'AudioToolbox', 'AVFoundation', 'CoreMedia', 'VideoToolbox'

  s.vendored_frameworks = %w[
    Artifacts/ffmpegkit.xcframework
    Artifacts/libavcodec.xcframework
    Artifacts/libavdevice.xcframework
    Artifacts/libavfilter.xcframework
    Artifacts/libavformat.xcframework
    Artifacts/libavutil.xcframework
    Artifacts/libswresample.xcframework
    Artifacts/libswscale.xcframework
  ]

  s.module_name = 'ffmpegkit'

  s.user_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/AinoteFFmpegKitIOS/Artifacts/ffmpegkit.xcframework/ios-arm64/ffmpegkit.framework/Headers" "${PODS_ROOT}/AinoteFFmpegKitIOS/Artifacts/ffmpegkit.xcframework/ios-arm64-simulator/ffmpegkit.framework/Headers"'
  }
end
