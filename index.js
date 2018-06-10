import { NativeEventEmitter, NativeModules, Platform } from "react-native";

const { RNDownloaderUtil } = NativeModules;

const TAG = "[DownloaderUtil]";
export default class DownloaderUtil {
  static stopDownload(jobId) {
    __DEV__ && console.debug(TAG, "stopDownload", jobId);
    if (Platform.OS !== "ios") {
      __DEV__ && console.warn(TAG, "not supported on", Platform.OS);
      return;
    }
    RNDownloaderUtil.stopDownload(jobId);
  }

  static downloadFile(options) {
    __DEV__ && console.debug(TAG, "downloadFile", options);
    if (Platform.OS !== "ios") {
      __DEV__ && console.warn(TAG, "not supported on", Platform.OS);
      return;
    }

    if (typeof options !== "object")
      throw new Error("downloadFile: Invalid value for argument `options`");
    if (typeof options.fromUrl !== "string")
      throw new Error("downloadFile: Invalid value for property `fromUrl`");
    if (typeof options.toFile !== "string")
      throw new Error("downloadFile: Invalid value for property `toFile`");
    if (options.headers && typeof options.headers !== "object")
      throw new Error("downloadFile: Invalid value for property `headers`");
    if (options.background && typeof options.background !== "boolean")
      throw new Error("downloadFile: Invalid value for property `background`");
    if (options.progressDivider && typeof options.progressDivider !== "number")
      throw new Error(
        "downloadFile: Invalid value for property `progressDivider`"
      );

    let jobId = getJobId();
    let subscriptions = [];

    let eventEmitter = new NativeEventEmitter(RNDownloaderUtil);

    if (typeof options.begin === "function") {
      subscriptions.push(
        eventEmitter.addListener("DownloadBegin", data => {
          __DEV__ && console.debug(TAG, "downloadFile", "DownloadBegin", data);
          if (data.jobId === jobId) {
            options.begin && options.begin(data);
          }
        })
      );
    }

    if (typeof options.progress === "function") {
      subscriptions.push(
        eventEmitter.addListener("DownloadProgress", data => {
          __DEV__ &&
            console.debug(TAG, "downloadFile", "DownloadProgress", data);
          if (data.jobId === jobId) {
            options.progress && options.progress(data);
          }
        })
      );
    }

    let bridgeOptions = {
      jobId: jobId,
      fromUrl: options.fromUrl,
      toFile: options.toFile,
      headers: options.headers || {},
      background: !!options.background,
      progressDivider: options.progressDivider || 0
    };

    return {
      jobId,
      promise: RNDownloaderUtil.downloadFile(bridgeOptions).then(res => {
        __DEV__ && console.debug(TAG, "downloadFile", "finish", res);
        subscriptions.forEach(sub => sub.remove());
        return res;
      })
    };
  }
}
