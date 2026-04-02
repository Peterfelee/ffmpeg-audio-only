# frozen_string_literal: true

# 源码构建：pod install 时运行 Scripts/build_ffmpeg_kit_ios_xcframework.sh，
# 克隆 arthenica/ffmpeg-kit v6.0 并执行 ios.sh，将 xcframework 生成到 Artifacts/（不入库）。
# 不使用 :http zip。仓库：https://github.com/Peterfelee/ffmpeg-audio-only

Pod::Spec.new do |s|
  s.name             = 'AinoteFFmpegKitIOS'
  s.version          = '6.0.0-source.1'
  s.summary          = 'FFmpegKit iOS built from upstream ffmpeg-kit source (no prebuilt zip)'
  s.description      = 'Clones arthenica/ffmpeg-kit at v6.0 during pod install, runs ios.sh (-x, https-equivalent gmp+gnutls), vendors resulting xcframeworks from Artifacts/.'
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

  s.preserve_paths   = 'Scripts/build_ffmpeg_kit_ios_xcframework.sh'

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
