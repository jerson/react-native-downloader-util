#if __has_include("RCTEventEmitter.h")
#import "RCTEventEmitter.h"
#else
#import <React/RCTEventEmitter.h>
#endif

@interface RNDownloaderUtil : RCTEventEmitter <RCTBridgeModule>

@end
  