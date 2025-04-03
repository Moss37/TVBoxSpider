//
//  JsonSequence.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>

@interface JsonSequence : NSObject

+ (NSDictionary *)parse:(NSDictionary<NSString *, NSString *> *)jx url:(NSString *)url;

@end
