//
//  Misc.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "Misc.h"
#import "SpiderDebug.h"

@implementation Misc

+ (BOOL)isVip:(NSString *)url {
    @try {
        NSURL *parsedUrl = [NSURL URLWithString:url];
        NSString *host = parsedUrl.host;
        NSArray *vipWebsites = @[@"iqiyi.com", @"v.qq.com", @"youku.com", @"le.com", @"tudou.com",
                                @"mgtv.com", @"sohu.com", @"acfun.cn", @"bilibili.com", @"baofeng.com", @"pptv.com"];
        
        for (NSString *website in vipWebsites) {
            if ([host containsString:website]) {
                if ([website isEqualToString:@"iqiyi.com"]) {
                    NSString *path = parsedUrl.path;
                    return [path containsString:@"/a_"] || [path containsString:@"/w_"] || [path containsString:@"/v_"];
                }
                return YES;
            }
        }
    } @catch (NSException *e) {}
    return NO;
}

+ (BOOL)isVideoFormat:(NSString *)url {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pattern = @"http((?!http).){26,}?\\.(m3u8|mp4)\\?.*|http((?!http).){26,}\\.(m3u8|mp4)|http((?!http).){26,}?/m3u8\\?pt=m3u8.*|http((?!http).)*?default\\.ixigua\\.com/.*|http((?!http).)*?cdn-tos[^\\?]*|http((?!http).)*?/obj/tos[^\\?]*|http.*?/player/m3u8play\\.php\\?url=.*|http.*?/player/.*?[pP]lay\\.php\\?url=.*|http.*?/playlist/m3u8/\\?vid=.*|http.*?\\.php\\?type=m3u8&.*|http.*?/download.aspx\\?.*|http.*?/api/up_api.php\\?.*|https.*?\\.66yk\\.cn.*";
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    });
    return [regex numberOfMatchesInString:url options:0 range:NSMakeRange(0, url.length)] > 0;
}

+ (NSString *)fixUrl:(NSString *)base src:(NSString *)src {
    @try {
        if ([src hasPrefix:@"//"]) {
            NSURLComponents *components = [NSURLComponents componentsWithString:base];
            return [NSString stringWithFormat:@"%@:%@", components.scheme, src];
        } else if (![src containsString:@"://"]) {
            NSURLComponents *components = [NSURLComponents componentsWithString:base];
            return [NSString stringWithFormat:@"%@://%@%@", components.scheme, components.host, src];
        }
    } @catch (NSException *e) {
        [SpiderDebug logWithThrowable:e];
    }
    return src;
}

@end
