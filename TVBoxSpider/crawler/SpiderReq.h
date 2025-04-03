//
//  SpiderReq.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>
#import "SpiderReqResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpiderReq : NSObject

+ (void)cancel:(NSString *)tag;
+ (void)get:(NSString *)url headers:(NSDictionary<NSString *, NSString *> *)headers completion:(void(^)(SpiderReqResult *))completion;
+ (void)postForm:(NSString *)url form:(NSDictionary<NSString *, NSString *> *)headers headers:(NSDictionary<NSString *, NSString *> *)headers completion:(void(^)(SpiderReqResult *))completion;
+ (void)postJson:(NSString *)url json:(NSDictionary<NSString *, NSString *> *)json headers:(NSDictionary<NSString *, NSString *> *)headers completion:(void(^)(SpiderReqResult *))completion;

@end

NS_ASSUME_NONNULL_END
