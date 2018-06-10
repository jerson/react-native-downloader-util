
#import "RNDownloaderUtil.h"

#if __has_include("TCBlobDownloader.h")
#import "TCBlobDownloader.h"
#else
#import <TCBlobDownload/TCBlobDownloader.h>
#endif

#if __has_include("TCBlobDownloadManager.h")
#import "TCBlobDownloadManager.h"
#else
#import <TCBlobDownload/TCBlobDownloadManager.h>
#endif


@interface RNDownloaderUtil ()

@property(nonatomic, strong) TCBlobDownloadManager *manager;
@property(nonatomic, strong) NSMutableDictionary *tasks;

@end

@implementation RNDownloaderUtil
static int lastId;
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();


- (RNDownloaderUtil *)init {
  
  self = [super init];
  if (self) {
    
    NSLog(@"[Downloader] init");
    self.manager = [TCBlobDownloadManager sharedInstance];
    [self.manager setMaxConcurrentDownloads:1];
    lastId = 1;
    
    if(self.tasks==nil){
      self.tasks = [[NSMutableDictionary alloc] initWithDictionary: @{}];
    }

    
  }
  return self;
}

- (void)dealloc {
  NSLog(@"[Downloader] dealloc");
   [self.manager cancelAllDownloadsAndRemoveFiles:NO];
}

- (dispatch_queue_t)methodQueue {
   return dispatch_get_main_queue();
  //return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
  
//   return dispatch_queue_create("sb.downloader", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - Pubic API


RCT_EXPORT_METHOD(stopDownload:
                   (nonnull NSNumber *) jobId) {
  
  if(self.tasks[jobId]!=nil){
    [self.tasks[jobId] cancelDownloadAndRemoveFile:YES];
  }
  
}

RCT_EXPORT_METHOD(downloadFile:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  
  NSNumber * jobId = options[@"jobId"];
  NSString * fromUrl = options[@"fromUrl"];
  NSString * toFile = options[@"toFile"];
  NSNumber* progressDivider = options[@"progressDivider"];
  
  NSArray * parts = [toFile componentsSeparatedByString:@"/"];
  NSString * fileName = parts[[parts count] - 1];
  NSString * toPath = [toFile stringByReplacingOccurrencesOfString:fileName withString:@""];
  
  __block int lastProgress = -1;
  __block BOOL finished = NO;
  
  self.tasks[jobId] = [self.manager startDownloadWithURL:[NSURL URLWithString:fromUrl]
                                              customPath:toPath
                       firstResponse:^(NSURLResponse *response) {
                         
                              [self sendEvent:@"DownloadBegin"
                                    body:@{
                                           @"jobId": jobId,
                                           @"contentLength": @([response expectedContentLength]),
                                           }];
                         
                                             NSLog(@"[Downloader] firstResponse");
                                             NSLog(@"[Downloader] %@", response);
                                             
                       } progress:^(uint64_t receivedLength, uint64_t totalLength, NSInteger remainingTime, float progress) {
                         
                         if([progressDivider intValue] < 1){
                           
                           [self sendEvent:@"DownloadProgress"
                                      body:@{
                                             @"jobId": jobId,
                                             @"contentLength": @(totalLength),
                                             @"bytesWritten": @(receivedLength),
                                             }];
                           
                         }else {
                          
                           
                           int progressInt = ((int) (progress*100));
                           
                           if(lastProgress!= progressInt && progressInt % [progressDivider intValue] == 0){
                             lastProgress = progressInt;
                             [self sendEvent:@"DownloadProgress"
                                      body:@{
                                             @"jobId": jobId,
                                             @"contentLength": @(totalLength),
                                             @"bytesWritten": @(receivedLength),
                                             }];
                           }
                         
                         }
                         
                         
                                             
                      } error:^(NSError *error) {
                                             
                                             NSLog(@"[Downloader] Fle cancel");
                                             NSLog(@"[Downloader] %@", error);
                        
                       // [self reject:reject withError:error];
                        reject(@"300",@"ss",error);
                        
                      }  complete:^(BOOL downloadFinished, NSString *pathToFile) {
                        
                        long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:pathToFile error:nil] fileSize];
                        
                        if(downloadFinished && !finished){
                          finished = YES;
                          NSError *error = nil;
                          [[NSFileManager defaultManager] moveItemAtPath:pathToFile toPath:toFile error:&error];
                          
                          
                          
                          NSMutableDictionary* result =
                          [[NSMutableDictionary alloc] initWithDictionary: @{
                                                                             @"jobId": jobId,
                                                                             @"statusCode": @(200),
                                                                             @"bytesWritten": @(fileSize),
                                                                             @"body": toFile
                                                                             }];
                          
                          return resolve(result);
                        }
                        
                        
                        
                     }];

}


- (void)reject:(RCTPromiseRejectBlock)reject withError:(NSError *)error
{
  NSString *codeWithDomain = [NSString stringWithFormat:@"E%@%zd", error.domain.uppercaseString, error.code];
  reject(codeWithDomain, error.localizedDescription, error);
}

- (void)sendEvent:(NSString *)name body:(id)body {
  [self sendEventWithName:name body:body];
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"DownloadBegin",
           @"DownloadProgress"];
}


@end
