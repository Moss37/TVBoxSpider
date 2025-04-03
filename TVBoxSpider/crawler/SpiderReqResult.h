//
//  SpiderReqResult.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>

@interface SpiderReqResult : NSObject

@property (strong) NSDictionary *headers;

@property (copy) NSString *content;

+ (instancetype)empty;

@end
