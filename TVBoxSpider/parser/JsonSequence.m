//
//  JsonSequence.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "JsonSequence.h"
#import "SpiderDebug.h"

@implementation JsonSequence

+ (NSDictionary *)parse:(NSDictionary<NSString *, NSString *> *)jx url:(NSString *)url {
    if (jx.count == 0) return @{};
    
    for (NSString *jxName in jx) {
        NSString *parseUrl = [NSString stringWithFormat:@"%@%@", jx[jxName], url];
        [SpiderDebug logWithMsg:parseUrl];
        
        @try {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:parseUrl]];
            NSHTTPURLResponse *response;
            NSError *error;
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (error) @throw [NSException exceptionWithName:@"NetworkError" reason:error.localizedDescription userInfo:nil];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSMutableDictionary *headers = [NSMutableDictionary new];
            
            NSString *ua = [jsonDict[@"user-agent"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] ?: @"";
            if (ua.length > 0) headers[@"User-Agent"] = [@" " stringByAppendingString:ua];
            
            NSString *referer = [jsonDict[@"referer"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] ?: @"";
            if (referer.length > 0) headers[@"Referer"] = [@" " stringByAppendingString:referer];
            
            if (jsonDict[@"url"]) {
                return @{
                    @"header": headers,
                    @"url": jsonDict[@"url"],
                    @"jxFrom": jxName
                };
            }
        } @catch (NSException *e) {
            [SpiderDebug logWithThrowable:e];
        }
    }
    return @{};
}

@end
