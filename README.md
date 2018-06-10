
# react-native-downloader-util

single downloader for **iOS** using `TCBlobDownload` compatible with `react-native-fs`

## Getting started

`$ npm install react-native-downloader-util --save`

### Mostly automatic installation

`$ react-native link react-native-downloader-util`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-downloader-util` and add `RNDownloaderUtil.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNDownloaderUtil.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Go to `Podfile` and add `"TCBlobDownload", "~> 2.1.1"` 
5. Run your project (`Cmd+R`)<


## Usage
```javascript
import DownloaderUtil from 'react-native-downloader-util';


type DownloadFileOptions = {
  fromUrl: string, // URL to download file from
  toFile: string, // Local filesystem path to save the file to
  headers?: Headers, // An object of headers to be passed to the server
  background?: boolean,
  progressDivider?: number,
  begin?: (res: DownloadBeginCallbackResult) => void,
  progress?: (res: DownloadProgressCallbackResult) => void
};

type DownloadBeginCallbackResult = {
  jobId: number, // The download job ID, required if one wishes to cancel the download. See `stopDownload`.
  statusCode: number, // The HTTP status code
  contentLength: number, // The total size in bytes of the download resource
  headers: Headers // The HTTP response headers from the server
};

type DownloadProgressCallbackResult = {
  jobId: number, // The download job ID, required if one wishes to cancel the download. See `stopDownload`.
  contentLength: number, // The total size in bytes of the download resource
  bytesWritten: number // The number of bytes written to the file so far
};

type DownloadResult = {
  jobId: number, // The download job ID, required if one wishes to cancel the download. See `stopDownload`.
  statusCode: number, // The HTTP status code
  bytesWritten: number // The number of bytes written to the file
};

DownloaderUtil.stopDownload(jobId: number): void;
DownloaderUtil.downloadFile(jobId: DownloadFileOptions
  ): { jobId: number, promise: Promise<DownloadResult> }
```
  