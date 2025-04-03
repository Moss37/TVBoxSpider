//
//  SSLSocketFactoryCompat.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "SSLSocketFactoryCompat.h"
#import <Security/Security.h>

@implementation SSLSocketFactoryCompat

+ (AFSecurityPolicy *)trustAllCertPolicy {
    static AFSecurityPolicy *policy;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        policy.allowInvalidCertificates = YES;
        policy.validatesDomainName = NO;
        
        // 设置TLS版本
//        policy.SSLPinningMode = AFSSLPinningModeNone;
//        policy.minimumTLSVersion = tls_protocol_version_TLSv12;
    });
    return policy;
}

// 禁用不安全的密码套件
+ (NSArray *)safeCipherSuites {
    return @[
        @"TLS_RSA_WITH_AES_256_GCM_SHA384",
        @"TLS_RSA_WITH_AES_128_GCM_SHA256",
        @"TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
        @"TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
        @"TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
        @"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
        @"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
        @"TLS_RSA_WITH_3DES_EDE_CBC_SHA",
        @"TLS_RSA_WITH_AES_128_CBC_SHA",
        @"TLS_RSA_WITH_AES_256_CBC_SHA",
        @"TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA",
        @"TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
        @"TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA",
        @"TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"
    ];
}

@end
