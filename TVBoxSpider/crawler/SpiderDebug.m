//
//  SpiderDebug.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "SpiderDebug.h"

@implementation SpiderDebug

+ (void)logWithThrowable:(NSException *)exception {
    @try {
        NSString *errorMsg = [NSString stringWithFormat:@"%@: %@", exception.name, exception.reason];
        NSLog(@"[SpiderLog] %@\nCall stack:\n%@", errorMsg, [exception callStackSymbols]);
    } @catch (NSException *exception) {}
}

+ (void)logWithMsg:(NSString *)message {
    @try {
        NSLog(@"[SpiderLog] %@", message);
    } @catch (NSException *exception) {}
}

@end
