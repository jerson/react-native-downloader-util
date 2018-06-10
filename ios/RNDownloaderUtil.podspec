
Pod::Spec.new do |s|
  s.name         = "RNDownloaderUtil"
  s.version      = "1.0.0"
  s.summary      = "RNDownloaderUtil"
  s.description  = <<-DESC
                  RNDownloaderUtil single downloader for **iOS** using `TCBlobDownload` compatible with `react-native-fs`
                   DESC
  s.homepage     = "https://github.com/jerson/react-native-downloader-util"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "jeral17@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/jerson/react-native-downloader-util.git", :tag => "master" }
  s.source_files  = "RNDownloaderUtil/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "TCBlobDownload", "~> 2.1.1"

end

  