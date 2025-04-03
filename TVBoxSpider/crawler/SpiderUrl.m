//
//  SpiderUrl.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "SpiderUrl.h"

@implementation SpiderUrl

+ (instancetype)empty {
    static SpiderUrl *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SpiderUrl alloc] init];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithURL:@"" headers:nil];
}

- (instancetype)initWithURL:(NSString *)url headers:(NSDictionary<NSString *, NSString *> *)headers {
    self = [super init];
    if (self) {
        _url = url ?: @"";
        _headers = headers ? [NSMutableDictionary dictionaryWithDictionary:headers] : [NSMutableDictionary new];
    }
    return self;
}

@end
