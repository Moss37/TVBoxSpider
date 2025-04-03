//
//  SSLSocketFactoryCompat.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>
#import "AFSecurityPolicy.h"

@interface SSLSocketFactoryCompat : NSObject

+ (AFSecurityPolicy *)trustAllCertPolicy;

+ (NSArray *)safeCipherSuites;

@end
