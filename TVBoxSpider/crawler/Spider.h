//
//  Spider.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Spider <NSObject>

@optional
- (instancetype)initWithExt:(NSString *)ext;
- (void)homeContent:(BOOL)filter completion:(void(^)(NSString *))completion;
- (void)homeVideoContentCompletion:(void(^)(NSString *))completion;
- (void)categoryContent:(NSString *)tid page:(NSString *)pg filter:(BOOL)filter extend:(NSDictionary<NSString *, NSString *> *)extend completion:(void(^)(NSString *))completion;
- (void)detailContent:(NSArray<NSString*> *)ids completion:(void(^)(NSString *))completion;
- (void)searchContent:(NSString *)key quick:(BOOL)quick completion:(void(^)(NSString *))completion;
- (void)playerContent:(NSString *)flag videoId:(NSString *)videoId vipFlags:(NSArray<NSString*> *)vipFlags completion:(void(^)(NSString *))completion;
- (BOOL)isVideoFormat:(NSString *)url;
- (BOOL)manualVideoCheck;

@end

NS_ASSUME_NONNULL_END
