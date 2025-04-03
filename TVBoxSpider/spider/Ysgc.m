//
//  Ysgc.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/13.
//

#import "Ysgc.h"
#import "SpiderDebug.h"
#import "SpiderReq.h"
#import "SpiderUrl.h"
#import "GDataXMLNode+XPathExtensions.h"

@interface Ysgc ()

@property (nonatomic, strong) NSString *siteUrl;
@property (nonatomic, strong) NSString *siteHost;
@property (nonatomic, strong) NSMutableDictionary *playerConfig;

@end

@implementation Ysgc

- (instancetype)init {
    self = [super init];
    if (self) {
        _siteUrl = @"http://www.ysgc.cc";
        _siteHost = @"www.ysgc.cc";
        _playerConfig = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)getHeaders:(NSString *)url {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"platform_version"] = @"LMY47I";
    headers[@"user-agent"] = @"Dart/2.12 (dart:io)";
    headers[@"version"] = @"1.6.4";
    headers[@"copyright"] = @"xiaogui";
    headers[@"host"] = self.siteHost;
    headers[@"platform"] = @"android";
    headers[@"client_name"] = @"6L+95Ymn6L6+5Lq6";
    return headers;
}

- (void)homeContent:(BOOL)filter completion:(void(^)(NSString *))completion {
    @try {
        NSString *url = [NSString stringWithFormat:@"%@/api.php/app/nav?token=", self.siteUrl];
        SpiderUrl *su = [[SpiderUrl alloc] initWithURL:url headers:[self getHeaders:url]];
        [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull srr) {
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[srr.content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSArray *jsonArray = jsonObject[@"list"];
            NSMutableArray *classes = [NSMutableArray array];
            NSMutableDictionary *filterConfig = [NSMutableDictionary dictionary];
            
            for (NSDictionary *jObj in jsonArray) {
                NSString *typeName = jObj[@"type_name"];
                if ([typeName isEqualToString:@"电视直播"]) {
                    continue;
                }
                
                NSString *typeId = jObj[@"type_id"];
                NSMutableDictionary *newCls = [NSMutableDictionary dictionary];
                newCls[@"type_id"] = typeId;
                newCls[@"type_name"] = typeName;
                [classes addObject:newCls];
                
                @try {
                    NSDictionary *typeExtend = jObj[@"type_extend"];
                    NSArray *typeExtendKeys = [typeExtend allKeys];
                    NSMutableArray *extendsAll = [NSMutableArray array];
                    
                    for (NSString *typeExtendKey in typeExtendKeys) {
                        NSString *typeExtendName = nil;
                        if ([typeExtendKey isEqualToString:@"class"]) {
                            typeExtendName = @"类型";
                        } else if ([typeExtendKey isEqualToString:@"area"]) {
                            typeExtendName = @"地区";
                        } else if ([typeExtendKey isEqualToString:@"lang"]) {
                            typeExtendName = @"语言";
                        } else if ([typeExtendKey isEqualToString:@"year"]) {
                            typeExtendName = @"年代";
                        }
                        
                        if (typeExtendName == nil) {
                            [SpiderDebug logWithMsg:typeExtendName];
                            continue;
                        }
                        
                        NSString *typeExtendStr = typeExtend[typeExtendKey];
                        if (typeExtendStr.length == 0) {
                            continue;
                        }
                        
                        NSArray *newTypeExtendKeys = [typeExtendStr componentsSeparatedByString:@","];
                        NSMutableDictionary *newTypeExtend = [NSMutableDictionary dictionary];
                        newTypeExtend[@"key"] = typeExtendKey;
                        newTypeExtend[@"name"] = typeExtendName;
                        NSMutableArray *newTypeExtendKV = [NSMutableArray array];
                        
                        {
                            NSMutableDictionary *kvAll = [NSMutableDictionary dictionary];
                            kvAll[@"n"] = @"全部";
                            kvAll[@"v"] = @"";
                            [newTypeExtendKV addObject:kvAll];
                        }
                        
                        for (NSString *k in newTypeExtendKeys) {
                            if ([typeExtendName isEqualToString:@"伦理"]) {
                                continue;
                            }
                            NSMutableDictionary *kv = [NSMutableDictionary dictionary];
                            kv[@"n"] = k;
                            kv[@"v"] = k;
                            [newTypeExtendKV addObject:kv];
                        }
                        
                        newTypeExtend[@"value"] = newTypeExtendKV;
                        [extendsAll addObject:newTypeExtend];
                    }
                    
                    filterConfig[typeId] = extendsAll;
                } @catch (NSException *e) {
                    [SpiderDebug logWithThrowable:e];
                }
            }
            
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            result[@"class"] = classes;
            
            if (filter) {
                result[@"filters"] = filterConfig;
            }
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
            NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            completion(str);
        }];
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (void)homeVideoContentCompletion:(void(^)(NSString *))completion {
    @try {
        NSString *url = [NSString stringWithFormat:@"%@/api.php/app/index_video?token=", self.siteUrl];
        SpiderUrl *su = [[SpiderUrl alloc] initWithURL:url headers:[self getHeaders:url]];
        [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull srr) {
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[srr.content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSArray *jsonArray = jsonObject[@"list"];
            NSMutableArray *videos = [NSMutableArray array];
            
            for (NSDictionary *jObj in jsonArray) {
                NSArray *videoList = jObj[@"vlist"];
                for (NSInteger j = 0; j < MIN(videoList.count, 6); j++) {
                    NSDictionary *vObj = videoList[j];
                    NSMutableDictionary *v = [NSMutableDictionary dictionary];
                    v[@"vod_id"] = vObj[@"vod_id"];
                    v[@"vod_name"] = vObj[@"vod_name"];
                    v[@"vod_pic"] = vObj[@"vod_pic"];
                    v[@"vod_remarks"] = vObj[@"vod_remarks"];
                    [videos addObject:v];
                }
            }
            
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            result[@"list"] = videos;
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            completion(str);
        }];
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (void)categoryContent:(NSString *)tid page:(NSString *)pg filter:(BOOL)filter extend:(NSDictionary<NSString *, NSString *> *)extend completion:(void(^)(NSString *))completion {
    @try {
        NSString *url = [NSString stringWithFormat:@"%@/api.php/app/video?tid=%@&pg=%@&token=", self.siteUrl, tid, pg];
        
        for (NSString *key in extend.allKeys) {
            NSString *value = extend[key];
            url = [url stringByAppendingFormat:@"&%@=%@", key, [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        }
        
        SpiderUrl *su = [[SpiderUrl alloc] initWithURL:url headers:[self getHeaders:url]];
        [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull srr) {
            NSDictionary *dataObject = [NSJSONSerialization JSONObjectWithData:[srr.content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSArray *jsonArray = dataObject[@"list"];
            NSMutableArray *videos = [NSMutableArray array];
            
            for (NSDictionary *vObj in jsonArray) {
                NSMutableDictionary *v = [NSMutableDictionary dictionary];
                v[@"vod_id"] = vObj[@"vod_id"];
                v[@"vod_name"] = vObj[@"vod_name"];
                v[@"vod_pic"] = vObj[@"vod_pic"];
                v[@"vod_remarks"] = vObj[@"vod_remarks"];
                [videos addObject:v];
            }
            
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSInteger limit = 20;
            NSInteger page = [dataObject[@"page"] integerValue];
            NSInteger total = [dataObject[@"total"] integerValue];
            NSInteger pageCount = [dataObject[@"pagecount"] integerValue];
            
            result[@"page"] = @(page);
            result[@"pagecount"] = @(pageCount);
            result[@"limit"] = @(limit);
            result[@"total"] = @(total);
            result[@"list"] = videos;
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            completion(str);
        }];
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (void)detailContent:(NSArray<NSString*> *)ids completion:(void(^)(NSString *))completion {
    @try {
        NSString *url = [NSString stringWithFormat:@"%@/api.php/app/video_detail?id=%@&token=", self.siteUrl, ids.firstObject];
        SpiderUrl *su = [[SpiderUrl alloc] initWithURL:url headers:[self getHeaders:url]];
        [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull srr) {
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[srr.content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *dataObject = jsonObject[@"data"];
            NSMutableDictionary *vodList = [NSMutableDictionary dictionary];
            
            vodList[@"vod_id"] = dataObject[@"vod_id"];
            vodList[@"vod_name"] = dataObject[@"vod_name"];
            vodList[@"vod_pic"] = dataObject[@"vod_pic"];
            vodList[@"type_name"] = dataObject[@"vod_class"];
            vodList[@"vod_year"] = dataObject[@"vod_year"];
            vodList[@"vod_area"] = dataObject[@"vod_area"];
            vodList[@"vod_remarks"] = dataObject[@"vod_remarks"];
            vodList[@"vod_actor"] = dataObject[@"vod_actor"];
            vodList[@"vod_director"] = dataObject[@"vod_director"];
            vodList[@"vod_content"] = dataObject[@"vod_content"];
            
            NSArray *playerList = dataObject[@"vod_url_with_player"];
            NSMutableArray *playFlags = [NSMutableArray array];
            
            for (NSDictionary *playerListObj in playerList) {
                NSString *from = playerListObj[@"code"];
                NSMutableDictionary *playerObj = [playerListObj mutableCopy];
                [playerObj removeObjectForKey:@"url"];
                self.playerConfig[from] = playerObj;
                [playFlags addObject:from];
            }
            
            NSMutableDictionary *vod_play = [NSMutableDictionary dictionary];
            NSArray *vod_play_from_list = [dataObject[@"vod_play_from"] componentsSeparatedByString:@"$$$"];
            NSArray *vod_play_url_list = [dataObject[@"vod_play_url"] componentsSeparatedByString:@"$$$"];
            
            for (NSInteger i = 0; i < vod_play_from_list.count; i++) {
                vod_play[vod_play_from_list[i]] = vod_play_url_list[i];
            }
            
            // 按照playFlags排序
            NSArray *sortedKeys = [vod_play.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *o1, NSString *o2) {
                NSInteger sort1 = [playFlags indexOfObject:o1];
                NSInteger sort2 = [playFlags indexOfObject:o2];
                
                if (sort1 == sort2) {
                    return NSOrderedSame;
                }
                return sort1 > sort2 ? NSOrderedDescending : NSOrderedAscending;
            }];
            
            NSMutableArray *sortedValues = [NSMutableArray array];
            for (NSString *key in sortedKeys) {
                [sortedValues addObject:vod_play[key]];
            }
            
            NSString *vod_play_from = [sortedKeys componentsJoinedByString:@"$$$"];
            NSString *vod_play_url = [sortedValues componentsJoinedByString:@"$$$"];
            
            vodList[@"vod_play_from"] = vod_play_from;
            vodList[@"vod_play_url"] = vod_play_url;
            
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSMutableArray *list = [NSMutableArray array];
            [list addObject:vodList];
            result[@"list"] = list;
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            completion(str);
        }];
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (NSDictionary *)getHeaderJxs:(NSString *)url {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"platform_version"] = @"LMY47I";
    headers[@"user-agent"] = @"Dart/2.12 (dart:io)";
    headers[@"version"] = @"1.6.4";
    headers[@"copyright"] = @"xiaogui";
    headers[@"platform"] = @"android";
    headers[@"client_name"] = @"6L+95Ymn6L6+5Lq6";
    return headers;
}

- (void)playerContent:(NSString *)flag videoId:(NSString *)videoId vipFlags:(NSArray<NSString*> *)vipFlags completion:(void(^)(NSString *))completion {
    @try {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        
        if ([videoId containsString:@"hsl.ysgc.xyz"]) {
            NSString *uuu = [NSString stringWithFormat:@"https://www.ysgc.cc/static/player/dplayer.php?url=%@", videoId];
            NSMutableDictionary *headers = [NSMutableDictionary dictionary];
            headers[@"referer"] = @"https://www.ysgc.cc/";
            SpiderUrl *su = [[SpiderUrl alloc] initWithURL:uuu headers:headers];
            [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull srr) {
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"url: url\\+'(.+?)'," options:0 error:nil];
                NSTextCheckingResult *match = [regex firstMatchInString:srr.content options:0 range:NSMakeRange(0, srr.content.length)];
                
                if (match) {
                    result[@"parse"] = @0;
                    result[@"playUrl"] = @"";
                    result[@"url"] = [NSString stringWithFormat:@"%@%@", videoId, [srr.content substringWithRange:[match rangeAtIndex:1]]];
                    result[@"header"] = @"{\"Referer\":\" https://www.ysgc.cc\"}";
                } else {
                    result[@"parse"] = @1;
                    result[@"playUrl"] = @"";
                    result[@"url"] = uuu;
                    result[@"header"] = @"{\"Referer\":\"https://www.ysgc.cc/\"}";
                }
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                completion(str);
            }];
        } else if ([videoId containsString:@"duoduozy.com"]) {
            NSString *uuu = [NSString stringWithFormat:@"https://player.duoduozy.com/ddplay/?url=%@", videoId];
            NSMutableDictionary *headers = [NSMutableDictionary dictionary];
            headers[@"referer"] = @"https://www.duoduozy.com/";
            SpiderUrl *su = [[SpiderUrl alloc] initWithURL:uuu headers:headers];
            [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull srr) {
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"var urls.+?\"(.+?)\"" options:0 error:nil];
                NSTextCheckingResult *match = [regex firstMatchInString:srr.content options:0 range:NSMakeRange(0, srr.content.length)];
                
                if (match) {
                    result[@"parse"] = @0;
                    result[@"playUrl"] = @"";
                    result[@"url"] = [srr.content substringWithRange:[match rangeAtIndex:1]];
                } else {
                    result[@"parse"] = @1;
                    result[@"playUrl"] = @"";
                    result[@"url"] = videoId;
                    result[@"header"] = @"{\"Referer\":\"https://www.duoduozy.com/\"}";
                }
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                completion(str);
            }];
        }
        
        if ([vipFlags containsObject:flag]) {
            @try {
                result[@"parse"] = @1;
                result[@"playUrl"] = @"";
                result[@"url"] = videoId;
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                completion(str);
            } @catch (NSException *ee) {
                completion(@"");
                [SpiderDebug logWithThrowable:ee];
            }
        }
        
        NSDictionary *playerObj = self.playerConfig[flag];
        NSString *parseUrl = [NSString stringWithFormat:@"%@%@", playerObj[@"parse_api"], videoId];
        SpiderUrl *su = [[SpiderUrl alloc] initWithURL:parseUrl headers:[self getHeaderJxs:parseUrl]];
        [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull srr) {
            NSDictionary *playerData = [NSJSONSerialization JSONObjectWithData:[srr.content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSMutableDictionary *headers = [NSMutableDictionary dictionary];
            
            NSString *ua = playerData[@"user-agent"];
            if (ua && ua.length > 0) {
                headers[@"User-Agent"] = [NSString stringWithFormat:@" %@", ua];
            }
            
            NSString *referer = playerData[@"referer"];
            if (referer && referer.length > 0) {
                headers[@"Referer"] = [NSString stringWithFormat:@" %@", referer];
            }
            
            result[@"parse"] = @0;
            result[@"header"] = [self serializeJSON:headers];
            result[@"playUrl"] = @"";
            result[@"url"] = playerData[@"url"];
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            completion(str);
        }];
    } @catch (NSException *e) {
        [SpiderDebug logWithThrowable:e];
        if ([vipFlags containsObject:flag]) {
            @try {
                NSMutableDictionary *result = [NSMutableDictionary dictionary];
                result[@"parse"] = @1;
                result[@"playUrl"] = @"";
                result[@"url"] = videoId;
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                completion(str);
            } @catch (NSException *ee) {
                completion(@"");
                [SpiderDebug logWithThrowable:ee];
            }
        }
    }
}

- (void)searchContent:(NSString *)key quick:(BOOL)quick completion:(void(^)(NSString *))completion {
    if (quick) completion(@"");
    
    @try {
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *url = [NSString stringWithFormat:@"%@/api.php/app/search?text=%@&pg=1", self.siteUrl, encodedKey];
        SpiderUrl *su = [[SpiderUrl alloc] initWithURL:url headers:[self getHeaders:url]];
        [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull srr) {
            NSDictionary *dataObject = [NSJSONSerialization JSONObjectWithData:[srr.content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSArray *jsonArray = dataObject[@"list"];
            NSMutableArray *videos = [NSMutableArray array];
            
            for (NSDictionary *vObj in jsonArray) {
                NSMutableDictionary *v = [NSMutableDictionary dictionary];
                v[@"vod_id"] = vObj[@"vod_id"];
                v[@"vod_name"] = vObj[@"vod_name"];
                v[@"vod_pic"] = vObj[@"vod_pic"];
                v[@"vod_remarks"] = vObj[@"vod_remarks"];
                [videos addObject:v];
            }
            
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            result[@"list"] = videos;
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            completion(str);
        }];
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

// 辅助方法：将字典序列化为JSON字符串
- (NSString *)serializeJSON:(NSDictionary *)dict {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error) {
        [SpiderDebug logWithMsg:error.localizedDescription];
        return @"{}";
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
