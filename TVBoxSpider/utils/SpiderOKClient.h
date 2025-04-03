//
//  SpiderOKClient.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>

@interface SpiderOKClient : NSObject

+ (NSURLSession *)noRedirectClient;
+ (NSString *)getRedirectLocation:(NSDictionary<NSString *, NSArray<NSString *> *> *)headers;

@end
