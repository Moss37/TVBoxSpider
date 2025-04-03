//
//  Misc.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>

@interface Misc : NSObject

+ (BOOL)isVip:(NSString *)url;
+ (BOOL)isVideoFormat:(NSString *)url;
+ (NSString *)fixUrl:(NSString *)base src:(NSString *)src;

@end
