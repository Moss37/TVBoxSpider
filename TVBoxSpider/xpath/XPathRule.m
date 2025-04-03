//
//  XPathRule.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import "XPathRule.h"
#import "SpiderDebug.h"

@implementation XPathRule

#pragma mark - 初始化方法
+ (instancetype)fromJson:(NSString *)jsonStr {
    @try {
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        XPathRule *rule = [[XPathRule alloc] init];
        
        // 基础属性
        rule.ua = json[@"ua"] ?: @"";
        rule.homeUrl = [json[@"homeUrl"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateNode = [json[@"cateNode"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateName = [json[@"cateName"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateNameR = [self regexFromJson:json key:@"cateNameR"];
        rule.cateId = [json[@"cateId"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateIdR = [self regexFromJson:json key:@"cateIdR"];
        
        // 手动分类
        NSDictionary *cateManual = json[@"cateManual"];
        NSMutableDictionary *manualDict = [NSMutableDictionary new];
        [cateManual enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *_) {
            manualDict[[key stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet]] =
                [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        }];
        rule.cateManual = [manualDict copy];
        
        // 首页推荐
        rule.homeVodNode = [json[@"homeVodNode"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.homeVodName = [json[@"homeVodName"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.homeVodNameR = [self regexFromJson:json key:@"homeVodNameR"];
        rule.homeVodId = [json[@"homeVodId"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.homeVodIdR = [self regexFromJson:json key:@"homeVodIdR"];
        rule.homeVodImg = [json[@"homeVodImg"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.homeVodImgR = [self regexFromJson:json key:@"homeVodImgR"];
        rule.homeVodMark = [json[@"homeVodMark"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.homeVodMarkR = [self regexFromJson:json key:@"homeVodMarkR"];
        
        // 分类页属性
        rule.cateUrl = [json[@"cateUrl"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateVodNode = [json[@"cateVodNode"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateVodName = [json[@"cateVodName"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateVodNameR = [self regexFromJson:json key:@"cateVodNameR"];
        rule.cateVodId = [json[@"cateVodId"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateVodIdR = [self regexFromJson:json key:@"cateVodIdR"];
        rule.cateVodImg = [json[@"cateVodImg"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateVodImgR = [self regexFromJson:json key:@"cateVodImgR"];
        rule.cateVodMark = [json[@"cateVodMark"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.cateVodMarkR = [self regexFromJson:json key:@"cateVodMarkR"];
        
        // 详情页属性
        rule.dtUrl = json[@"dtUrl"];
        rule.dtNode = json[@"dtNode"];
        rule.dtName = json[@"dtName"];
        rule.dtNameR = [self regexFromJson:json key:@"dtNameR"];
        rule.dtImg = json[@"dtImg"];
        rule.dtImgR = [self regexFromJson:json key:@"dtImgR"];
        rule.dtCate = json[@"dtCate"];
        rule.dtCateR = [self regexFromJson:json key:@"dtCateR"];
        rule.dtYear = json[@"dtYear"];
        rule.dtYearR = [self regexFromJson:json key:@"dtYearR"];
        rule.dtArea = json[@"dtArea"];
        rule.dtAreaR = [self regexFromJson:json key:@"dtAreaR"];
        rule.dtMark = json[@"dtMark"];
        rule.dtMarkR = [self regexFromJson:json key:@"dtMarkR"];
        rule.dtActor = json[@"dtActor"];
        rule.dtActorR = [self regexFromJson:json key:@"dtActorR"];
        rule.dtDirector = json[@"dtDirector"];
        rule.dtDirectorR = [self regexFromJson:json key:@"dtDirectorR"];
        rule.dtDesc = json[@"dtDesc"];
        rule.dtDescR = [self regexFromJson:json key:@"dtDescR"];
        
        // 播放来源
        rule.dtFromNode = json[@"dtFromNode"];
        rule.dtFromName = json[@"dtFromName"];
        rule.dtFromNameR = [self regexFromJson:json key:@"dtFromNameR"];
        rule.dtUrlNode = json[@"dtUrlNode"];
        rule.dtUrlSubNode = json[@"dtUrlSubNode"];
        rule.dtUrlId = json[@"dtUrlId"];
        rule.dtUrlIdR = [self regexFromJson:json key:@"dtUrlIdR"];
        rule.dtUrlName = json[@"dtUrlName"];
        rule.dtUrlNameR = [self regexFromJson:json key:@"dtUrlNameR"];
        
        // 播放配置
        rule.playUrl = json[@"playUrl"];
        rule.playUa = json[@"playUa"];
        
        // 搜索配置
        rule.searchUrl = json[@"searchUrl"];
        rule.scVodNode = [json[@"scVodNode"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.scVodName = [json[@"scVodName"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.scVodNameR = [self regexFromJson:json key:@"scVodNameR"];
        rule.scVodId = [json[@"scVodId"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.scVodIdR = [self regexFromJson:json key:@"scVodIdR"];
        rule.scVodImg = [json[@"scVodImg"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.scVodImgR = [self regexFromJson:json key:@"scVodImgR"];
        rule.scVodMark = [json[@"scVodMark"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        rule.scVodMarkR = [self regexFromJson:json key:@"scVodMarkR"];
        
        return rule;
    } @catch (NSException *e) {
        [SpiderDebug logWithThrowable:e];
    }
    return nil;
}

#pragma mark - 工具方法
+ (NSRegularExpression *)regexFromJson:(NSDictionary *)json key:(NSString *)key {
    NSString *pattern = [json[key] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (pattern.length == 0) return nil;
    
    @try {
        return [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    } @catch (NSException *e) {
        [SpiderDebug logWithThrowable:e];
    }
    return nil;
}

- (NSString *)doReplaceRegex:(NSRegularExpression *)regex src:(NSString *)src {
    if (!regex) return src;
    
    @try {
        NSTextCheckingResult *result = [regex firstMatchInString:src options:0 range:NSMakeRange(0, src.length)];
        if (result && result.range.location != NSNotFound && [regex numberOfCaptureGroups] >= 1) {
            NSRange range = [result rangeAtIndex:1];
            return range.location != NSNotFound ?
                [[src substringWithRange:range] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] : src;
        }
    } @catch (NSException *e) {
        [SpiderDebug logWithThrowable:e];
    }
    return src;
}

#pragma mark - Getter方法实现
// 分类相关
- (NSString *)getCateNameR:(NSString *)src { return [self doReplaceRegex:self.cateNameR src:src]; }
- (NSString *)getCateIdR:(NSString *)src { return [self doReplaceRegex:self.cateIdR src:src]; }

// 首页推荐相关
- (NSString *)getHomeVodNameR:(NSString *)src { return [self doReplaceRegex:self.homeVodNameR src:src]; }
- (NSString *)getHomeVodIdR:(NSString *)src { return [self doReplaceRegex:self.homeVodIdR src:src]; }
- (NSString *)getHomeVodImgR:(NSString *)src { return [self doReplaceRegex:self.homeVodImgR src:src]; }
- (NSString *)getHomeVodMarkR:(NSString *)src { return [self doReplaceRegex:self.homeVodMarkR src:src]; }

// 分类页相关
- (NSString *)getCateVodNameR:(NSString *)src { return [self doReplaceRegex:self.cateVodNameR src:src]; }
- (NSString *)getCateVodIdR:(NSString *)src { return [self doReplaceRegex:self.cateVodIdR src:src]; }
- (NSString *)getCateVodImgR:(NSString *)src { return [self doReplaceRegex:self.cateVodImgR src:src]; }
- (NSString *)getCateVodMarkR:(NSString *)src { return [self doReplaceRegex:self.cateVodMarkR src:src]; }

// 详情页相关
- (NSString *)getDetailNameR:(NSString *)src { return [self doReplaceRegex:self.dtNameR src:src]; }
- (NSString *)getDetailImgR:(NSString *)src { return [self doReplaceRegex:self.dtImgR src:src]; }
- (NSString *)getDetailCateR:(NSString *)src { return [self doReplaceRegex:self.dtCateR src:src]; }
- (NSString *)getDetailYearR:(NSString *)src { return [self doReplaceRegex:self.dtYearR src:src]; }
- (NSString *)getDetailAreaR:(NSString *)src { return [self doReplaceRegex:self.dtAreaR src:src]; }
- (NSString *)getDetailMarkR:(NSString *)src { return [self doReplaceRegex:self.dtMarkR src:src]; }
- (NSString *)getDetailActorR:(NSString *)src { return [self doReplaceRegex:self.dtActorR src:src]; }
- (NSString *)getDetailDirectorR:(NSString *)src { return [self doReplaceRegex:self.dtDirectorR src:src]; }
- (NSString *)getDetailDescR:(NSString *)src { return [self doReplaceRegex:self.dtDescR src:src]; }

// 播放来源相关
- (NSString *)getDetailFromNameR:(NSString *)src { return [self doReplaceRegex:self.dtFromNameR src:src]; }
- (NSString *)getDetailUrlIdR:(NSString *)src { return [self doReplaceRegex:self.dtUrlIdR src:src]; }
- (NSString *)getDetailUrlNameR:(NSString *)src { return [self doReplaceRegex:self.dtUrlNameR src:src]; }

// 搜索相关
- (NSString *)getSearchVodNameR:(NSString *)src { return [self doReplaceRegex:self.scVodNameR src:src]; }
- (NSString *)getSearchVodIdR:(NSString *)src { return [self doReplaceRegex:self.scVodIdR src:src]; }
- (NSString *)getSearchVodImgR:(NSString *)src { return [self doReplaceRegex:self.scVodImgR src:src]; }
- (NSString *)getSearchVodMarkR:(NSString *)src { return [self doReplaceRegex:self.scVodMarkR src:src]; }

@end
