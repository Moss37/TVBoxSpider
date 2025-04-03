//
//  SpiderDebug.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpiderDebug : NSObject

+ (void)logWithThrowable:(NSException *)exception;
+ (void)logWithMsg:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
