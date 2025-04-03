//
//  SpiderOKClient.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "SpiderOKClient.h"
//#import <AFNetworking/AFSecurityPolicy.h>

@implementation SpiderOKClient

static NSURLSession *_noRedirectSession = nil;

+ (NSURLSession *)noRedirectClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPShouldSetCookies = YES;
        config.HTTPShouldUsePipelining = NO;
        config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        config.timeoutIntervalForRequest = 15;
        config.timeoutIntervalForResource = 15;
        config.HTTPMaximumConnectionsPerHost = 10;
        
        // 禁用重定向
//        config.HTTPShouldFollowRedirects = NO;
        
        // SSL配置
//        AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//        policy.allowInvalidCertificates = YES;
//        policy.validatesDomainName = NO;
        
        _noRedirectSession = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    });
    return _noRedirectSession;
}

+ (NSString *)getRedirectLocation:(NSDictionary<NSString *, NSArray<NSString *> *> *)headers {
    if (!headers) return nil;
    
    for (NSString *key in @[@"location", @"Location"]) {
        NSArray<NSString *> *values = headers[key];
        if (values.count > 0) {
            return values.firstObject;
        }
    }
    return nil;
}

@end
