//
//  JsonParallel.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "JsonParallel.h"
#import "SpiderUrl.h"
#import "SpiderReq.h"
#import "SpiderDebug.h"

@implementation JsonParallel

+ (NSDictionary *)parse:(NSDictionary<NSString *, NSString *> *)jx url:(NSString *)url {
    if (jx.count == 0) return @{};
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSDictionary *result = nil;
    __block NSMutableArray<NSURLSessionDataTask *> *tasks = [NSMutableArray new];
    __block BOOL found = NO;
    
    for (NSString *jxName in jx) {
        if (found) break;
        
        NSString *parseUrl = [NSString stringWithFormat:@"%@%@", jx[jxName], url];
        [SpiderDebug logWithMsg:parseUrl];
        
        dispatch_group_enter(group);
        NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:parseUrl] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            @try {
                if (found) return;
                
                NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                NSMutableDictionary *headers = [NSMutableDictionary new];
                NSString *ua = jsonDict[@"user-agent"] ?: @"";
                if (ua.length > 0) headers[@"User-Agent"] = [@" " stringByAppendingString:ua];
                
                NSString *referer = jsonDict[@"referer"] ?: @"";
                if (referer.length > 0) headers[@"Referer"] = [@" " stringByAppendingString:referer];
                
                if (jsonDict[@"url"]) {
                    @synchronized (self) {
                        if (!found) {
                            result = @{
                                @"header": headers,
                                @"url": jsonDict[@"url"],
                                @"jxFrom": jxName
                            };
                            found = YES;
                            
                            // Cancel all tasks
                            for (NSURLSessionDataTask *t in tasks) {
                                [t cancel];
                            }
                            [tasks removeAllObjects];
                        }
                    }
                }
            } @catch (NSException *e) {
                [SpiderDebug logWithThrowable:e];
            } @finally {
                dispatch_group_leave(group);
            }
        }];
        
        @synchronized (tasks) {
            [tasks addObject:task];
        }
        [task resume];
    }
    
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC));
    return result ?: @{};
}

@end
