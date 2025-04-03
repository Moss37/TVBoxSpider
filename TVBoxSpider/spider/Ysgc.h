//
//  Ysgc.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/13.
//

#import <Foundation/Foundation.h>
#import "Spider.h"

@interface Ysgc : NSObject<Spider>

- (void)homeContent:(BOOL)filter completion:(void(^)(NSString *))completion;
- (void)homeVideoContentCompletion:(void(^)(NSString *))completion;
- (void)categoryContent:(NSString *)tid page:(NSString *)pg filter:(BOOL)filter extend:(NSDictionary<NSString *, NSString *> *)extend completion:(void(^)(NSString *))completion;
- (void)detailContent:(NSArray<NSString*> *)ids completion:(void(^)(NSString *))completion;
- (void)searchContent:(NSString *)key quick:(BOOL)quick completion:(void(^)(NSString *))completion;
- (void)playerContent:(NSString *)flag videoId:(NSString *)videoId vipFlags:(NSArray<NSString*> *)vipFlags completion:(void(^)(NSString *))completion;

@end
