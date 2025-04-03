//
//  SpiderUrl.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpiderUrl : NSObject

@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *headers;

+ (instancetype)empty;
- (instancetype)initWithURL:(NSString *)url headers:(NSDictionary<NSString *, NSString *> *)headers;

@end

NS_ASSUME_NONNULL_END
