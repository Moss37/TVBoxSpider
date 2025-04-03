//
//  Hongxujixie.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/13.
//

#import "Crqz.h"
#import <GDataXML_HTML/GDataXMLNode.h>
#import "SpiderUrl.h"
#import "SpiderReq.h"
#import "SpiderDebug.h"
#import "GDataXMLNode+Extension.h"
@interface Crqz ()
{
    NSDictionary *_playerConfig;
    NSDictionary *_filterConfig;
}

@property (nonatomic, copy) NSString *siteUrl;
@property (nonatomic, copy) NSString *siteHost;

@end

@implementation Crqz

- (instancetype)init
{
    self = [super init];
    if (self) {
        _siteUrl = @"https://crqzzl.szstsh.org";
        _siteHost = @"crqzzl.szstsh.org";
    }
    return self;
}

- (NSRegularExpression *)regexCategory {
    
    return [NSRegularExpression regularExpressionWithPattern:@"/crq-(.*?)/" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexVid {
    return [NSRegularExpression regularExpressionWithPattern:@"/v/(.*?)/" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexUrl {
    return [NSRegularExpression regularExpressionWithPattern:@"url(.*?);" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexDetailVid {
    return [NSRegularExpression regularExpressionWithPattern:@"/v/(.*?)/(\\d+)-(\\d+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexCurrentPage {
    return [NSRegularExpression regularExpressionWithPattern:@"(.*?) / (.*?)" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexPage {
    return [NSRegularExpression regularExpressionWithPattern:@"/crq-(.*?)/____(\\d+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexDetailUrl {
    return [NSRegularExpression regularExpressionWithPattern:@"__plying(.*?)" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexPlay {
    return [NSRegularExpression regularExpressionWithPattern:@"/v/(.*?)/(\\d+)-(\\d+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (void)homeContent:(BOOL)filter completion:(void(^)(NSString *))completion {
    @try {
        NSString *url = [self.siteUrl stringByAppendingString:@"/"];
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
            // 分类处理
            NSMutableArray *classes = [NSMutableArray new];
            NSMutableSet *existingCategories = [NSMutableSet new];
            NSArray *categoryNodes = [doc nodesForXPath:@"//ul[@class='hl-nav hl-text-site swiper-wrapper clearfix']/li/a" error:nil];
            
            for (GDataXMLElement *node in categoryNodes) {
                NSString *name = [node firstNodeForXPath:@".//text()" error:nil].stringValue;
                NSString *href = [[node firstNodeForXPath:@".//@href" error:nil] stringValue];
                NSTextCheckingResult *match = [self.regexCategory firstMatchInString:href
                                                                             options:0
                                                                               range:NSMakeRange(0, href.length)];
                if (match) {
                    NSString *typeID = [href substringWithRange:[match rangeAtIndex:0]];
                    typeID = [typeID stringByReplacingOccurrencesOfString:@"/" withString:@""];
                    [classes addObject:@{
                        @"type_id": [typeID stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet],
                        @"type_name": name
                    }];
                    [existingCategories addObject:name];
                }
            }
            // 构建结果
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            if (filter) result[@"filters"] = self->_filterConfig;
            result[@"class"] = classes;
            // 处理视频列表
            NSArray *vodNodes = [doc nodesForXPath:@"//div[@class='container']//ul[contains(@class,'hl-vod-list clearfix')]/li[@class='hl-list-item hl-col-xs-4 hl-col-sm-3 hl-col-md-20w hl-col-lg-2']/a[@class='hl-item-thumb hl-lazy']" error:nil];
            NSMutableArray *videos = [NSMutableArray arrayWithCapacity:vodNodes.count];
            
            NSArray *tuijianNodes = [doc nodesForXPath:@"//div[@class='container']//ul[contains(@class,'hl-vod-list swiper-wrapper clearfix')]/li[contains(@class,'hl-list-item hl-col-xs-4 hl-col-sm-3 hl-col-md-20w hl-col-lg-2 hl-slide-swiper')]/a[@class='hl-item-thumb hl-lazy']" error:nil];
            for (GDataXMLElement *vodNode in tuijianNodes) {

                NSString *href = [[vodNode attributeForName:@"href"] stringValue];
                
                NSTextCheckingResult *vidMatch = [self.regexVid firstMatchInString:href
                                                                           options:0
                                                                             range:NSMakeRange(0, href.length)];
                if (vidMatch) {
                    NSString *vid = [href substringWithRange:[vidMatch rangeAtIndex:1]];
                    GDataXMLNode *titleNode = [[vodNode nodesForXPath:@"@title" error:nil] firstObject];
                    GDataXMLElement *imgNode = [[vodNode nodesForXPath:@".//@data-original" error:nil] firstObject];
                    GDataXMLNode *remarkNode = [[vodNode nodesForXPath:@".//span[contains(@class,'hl-lc-1 remarks')]/text()" error:nil] firstObject];
                    
                    [videos addObject:@{
                        @"vod_id": vid,
                        @"vod_name": [titleNode stringValue] ?: @"",
                        @"vod_pic": imgNode.stringValue ?: @"",
                        @"vod_remarks": [remarkNode stringValue] ?: @""
                    }];
                }
            }
            
            for (GDataXMLElement *vodNode in vodNodes) {
                NSString *href = [[vodNode attributeForName:@"href"] stringValue];
                
                NSTextCheckingResult *vidMatch = [self.regexVid firstMatchInString:href
                                                                           options:0
                                                                             range:NSMakeRange(0, href.length)];
                if (vidMatch) {
                    NSString *vid = [href substringWithRange:[vidMatch rangeAtIndex:1]];
                    GDataXMLNode *titleNode = [[vodNode nodesForXPath:@"@title" error:nil] firstObject];
                    GDataXMLElement *imgNode = [[vodNode nodesForXPath:@".//@data-original" error:nil] firstObject];
                    GDataXMLNode *remarkNode = [[vodNode nodesForXPath:@".//span[contains(@class,'hl-lc-1 remarks')]/text()" error:nil] firstObject];
                    
                    [videos addObject:@{
                        @"vod_id": vid,
                        @"vod_name": [titleNode stringValue] ?: @"",
                        @"vod_pic": [imgNode stringValue] ?: @"",
                        @"vod_remarks": [remarkNode stringValue] ?: @""
                    }];
                }
            }
        
            result[@"list"] = videos;
            
            completion([self convertToJSONString:result]);
        }];
        
        
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (void)categoryContent:(NSString *)tid page:(NSString *)pg filter:(BOOL)filter extend:(NSDictionary<NSString *, NSString *> *)extend completion:(void(^)(NSString *))completion {
    @try {
        __block NSString *url = [self.siteUrl stringByAppendingString:@"/"];
        
        // 处理分类ID
        if (extend && extend.count > 0 && extend[@"tid"] && [extend[@"tid"] length] > 0) {
            url = [url stringByAppendingString:extend[@"tid"]];
        } else {
            url = [url stringByAppendingString:tid];
        }
        
        // 处理扩展参数
        if (extend && extend.count > 0) {
            [extend enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
                if (value.length > 0) {
                    url = [url stringByAppendingFormat:@"/%@/%@", key, [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
                }
            }];
        }
        
        // 添加页码
        url = [url stringByAppendingFormat:@"/____%@.html", pg];
        
        // 获取页面内容
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument * doc) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSInteger pageCount = 0;
            NSInteger page = -1;
            
            // 解析分页信息
            NSArray *pageInfoNodes = [doc nodesForXPath:@"//ul[@class='hl-page-wrap hl-text-center cleafix']/li" error:nil];
            if (pageInfoNodes.count == 0) {
                page = [pg integerValue];
                pageCount = page;
            } else {
                for (GDataXMLElement *a in pageInfoNodes) {
                    NSString *name = [[a firstNodeForXPath:@".//span[@class='hl-hidden-xs']" error:nil] stringValue];
                    if (page == -1 && [[a attributeForName:@"class"].stringValue containsString:@"hl-page-tip"]) {
                        NSString *href = [[a firstNodeForXPath:@".//a/text()" error:nil] stringValue];
                        NSTextCheckingResult *match = [self.regexCurrentPage firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                        if (match) {
                            page = [[href substringWithRange:[match rangeAtIndex:1]] integerValue];
                        } else {
                            page = 1;
                        }
                    }
                    if ([[a attributeForName:@"class"].stringValue isEqualToString:@"hl-hidden-xs"]) {
                        NSString *href = [[a firstNodeForXPath:@".//a/@href" error:nil] stringValue];
                        NSTextCheckingResult *match = [self.regexPage firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                        if (match) {
                            pageCount = [[href substringWithRange:[match rangeAtIndex:2]] integerValue];
                        } else {
                            pageCount = 0;
                        }
                        break;
                    }
                }
            }
            
            // 解析视频列表
            NSMutableArray *videos = [NSMutableArray array];
            NSString *content = doc.rootElement.XMLString;
            if (![content containsString:@"没有找到您想要的结果哦"]) {
                NSArray *listNodes = [doc nodesForXPath:@"//li[contains(@class, 'hl-list-item hl-col-xs-4 hl-col-sm-3 hl-col-md-20w hl-col-lg-2')]//a[contains(@class,'hl-item-thumb hl-lazy')]" error:nil];
                for (GDataXMLElement *vod in listNodes) {

                    NSString *title = [[[vod nodesForXPath:@".//@title" error:nil] firstObject] stringValue];
                    NSString *cover = [vod attributeForName:@"data-original"].stringValue;
                    NSString *remark = [[[vod nodesForXPath:@".//span[contains(@class,'hl-lc-1 remarks')]" error:nil] firstObject] stringValue];
                    NSString *href = [vod attributeForName:@"href"].stringValue;
                    
                    NSTextCheckingResult *match = [self.regexVid firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                    if (!match) continue;
                    
                    NSString *vid = [href substringWithRange:[match rangeAtIndex:1]];
                    [videos addObject:@{
                        @"vod_id": vid,
                        @"vod_name": title ?: @"",
                        @"vod_pic": cover ?: @"",
                        @"vod_remarks": remark ?: @""
                    }];
                }
            }
            
            // 构建返回结果
            result[@"page"] = @(page);
            result[@"pagecount"] = @(pageCount);
            result[@"limit"] = @48;
            result[@"total"] = @(pageCount <= 1 ? videos.count : pageCount * 48);
            result[@"list"] = videos;
            
            NSString *str = [self convertToJSONString:result];
            completion(str);
        }];
        
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (void)detailContent:(NSArray<NSString *> *)ids completion:(void(^)(NSString *))completion {
    @try {
        // 构建视频详情URL
        NSString *url = [NSString stringWithFormat:@"%@/v/%@/", self.siteUrl, ids.firstObject];
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSMutableDictionary *vodList = [NSMutableDictionary dictionary];
            
            // 获取基本信息
            NSString *href = [[[doc nodesForXPath:@"//div[contains(@class,'hl-dc-btns hl-from-buttons')]//a[@class='hl-play-btn hl-btn-gradient']" error:nil] firstObject] attributeForName:@"href"].stringValue;
            NSString *vid = @"";
            NSTextCheckingResult *match = [self.regexDetailVid firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
            if (match) {
                vid = [NSString stringWithFormat:@"%@/%@-%@", [href substringWithRange:[match rangeAtIndex:1]], [href substringWithRange:[match rangeAtIndex:2]], [href substringWithRange:[match rangeAtIndex:3]]];
            }
            NSString *cover = [[[doc nodesForXPath:@"//div[contains(@class,'hl-dc-pic')]/span[@class='hl-item-thumb hl-lazy']" error:nil] firstObject] attributeForName:@"data-original"].stringValue;
            NSString *title = [[[doc nodesForXPath:@"//div[contains(@class,'hl-dc-content')]//h2[@class='hl-dc-title hl-data-menu']/text()" error:nil] firstObject] stringValue];
            NSString *desc = [[doc firstNodeForXPath:@"//div[contains(@class,'hl-dc-content')]//li[@class='hl-col-xs-12 blurb']" error:nil].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            // 初始化详情信息
            NSString *category = @"", *area = @"", *year = @"", *remark = @"", *director = @"", *actor = @"";
            remark = [doc firstNodeForXPath:@"//div[contains(@class,'myui-content__detail')]/div[@class='score']/span[@class='branch']/text()" error:nil].stringValue;
            // 解析详情信息
            NSArray <GDataXMLNode *>*infoNodes = [doc nodesForXPath:@"//div[@class='hl-dc-content']//li[contains(@class,'hl-col-xs-12')]/em[contains(@class, 'hl-text-muted')]" error:nil];
            for (GDataXMLNode *node in infoNodes) {
                NSString *info = [node stringValue];
                if ([info isEqualToString:@"类型："]) {
                    category = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"年份："]) {
                    year = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"地区："]) {
                    area = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"导演："]) {
                    NSMutableArray *directors = [NSMutableArray array];
                    GDataXMLNode *parent = [node parent];
                    NSArray *children = [parent nodesForXPath:@".//a" error:nil];
                    for (NSInteger index = 0; index < children.count; index++) {
                        GDataXMLNode *child = children[index];
                        NSString *stringValue = [child stringValue];
                        if (stringValue.length > 0 && ![stringValue isEqualToString:@" "] && ![stringValue isEqualToString:@"导演："]) {
                            [directors addObject:stringValue];
                        }
                    }
                    [parent releaseCachedValues];
                    director = [directors componentsJoinedByString:@","];
                } else if ([info isEqualToString:@"主演："]) {
                    NSMutableArray *directors = [NSMutableArray array];
                    GDataXMLNode *parent = [node parent];
                    NSArray *children = [parent nodesForXPath:@".//a" error:nil];
                    for (NSInteger index = 0; index < children.count; index++) {
                        GDataXMLNode *child = children[index];
                        NSString *stringValue = [child stringValue];
                        if (stringValue.length > 0 && ![stringValue isEqualToString:@" "] && ![stringValue isEqualToString:@"主演："]) {
                            [directors addObject:stringValue];
                        }
                    }
                    [parent releaseCachedValues];
                    actor = [directors componentsJoinedByString:@","];
                }
            }
            
            // 填充基本信息
            vodList[@"vod_id"] = vid ?: @"";
            vodList[@"vod_name"] = title ?: @"";
            vodList[@"vod_pic"] = cover ?: @"";
            vodList[@"type_name"] = category;
            vodList[@"vod_year"] = year;
            vodList[@"vod_area"] = area;
            vodList[@"vod_remarks"] = remark ?:@"";
            vodList[@"vod_actor"] = actor;
            vodList[@"vod_director"] = director;
            vodList[@"vod_content"] = [desc stringByReplacingOccurrencesOfString:@"剧情：" withString:@""] ?: @"";
            
            // 处理播放源
            NSMutableDictionary *vodPlay = [NSMutableDictionary dictionary];
            NSArray *sourceListNodes = [doc nodesForXPath:@"//div[contains(@class,'hl-dc-content')]//ul[contains(@class,'hl-from-list')]/li" error:nil];
                        
            for (NSInteger i = 0; i < sourceListNodes.count; i++) {
                GDataXMLElement *source = sourceListNodes[i];
                NSString *sourceName = [[[source firstNodeForXPath:@".//span/text()" error:nil] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *cls = [source firstNodeForXPath:@".//@class" error:nil].stringValue;
                if ([cls hasPrefix:@"active"]) {
                    NSLog(@"");
                } else {
                    NSString *href = [[source firstNodeForXPath:@".//@data-href" error:nil] stringValue];
                    vodPlay[sourceName] = href;
                    continue;
                }
                
                NSLog(@"%@", sourceName);
                
                // 查找播放源配置
                if ([sourceName isEqualToString:@"猜你喜欢"]) continue;
                
                // 处理播放列表
                NSMutableArray *vodItems = [NSMutableArray array];
                NSArray *playListNodes = [doc nodesForXPath:@"//div[@class='hl-list-wrap']/ul/li/a" error:nil];
                
                for (GDataXMLElement *vod in playListNodes) {
                    NSString *href = [[vod attributeForName:@"href"] stringValue];
                    NSTextCheckingResult *match = [self.regexPlay firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                    if (!match) continue;
                    
                    NSString *playURL = [NSString stringWithFormat:@"%@/%@-%@",
                                       [href substringWithRange:[match rangeAtIndex:1]],
                                       [href substringWithRange:[match rangeAtIndex:2]],
                                       [href substringWithRange:[match rangeAtIndex:3]]];
                    [vodItems addObject:[NSString stringWithFormat:@"%@$%@", [[vod stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], playURL]];
                }
                
                if (vodItems.count > 0) {
                    vodPlay[sourceName] = [vodItems componentsJoinedByString:@"#"];
                }
            }
            [self recursiveGetSourceWithDic:vodPlay completion:^(NSMutableDictionary *dic) {
                if (!dic) {
                    // 合并播放源信息
                    if (vodPlay.count > 0) {
                        vodList[@"vod_play_from"] = [[vodPlay allKeys] componentsJoinedByString:@"$$$"];
                        vodList[@"vod_play_url"] = [[vodPlay allValues] componentsJoinedByString:@"$$$"];
                    }
                    result[@"list"] = @[vodList];
                    NSString *str = [self convertToJSONString:result];
                    completion(str);
                }
            }];
        }];
        
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (void)recursiveGetSourceWithDic:(NSMutableDictionary *)dic completion:(void(^)(NSMutableDictionary *))completion {
    NSString *notActiveKey;
    for (NSString *key in dic.allKeys) {
        NSString *value = dic[key];
        if (![value containsString:@"$"]) {
            notActiveKey = key;
            break;
        }
    }
    if (notActiveKey) {
        NSString *notActiveValue = dic[notActiveKey];
        [self fetchDocumentWithURL:[self.siteUrl stringByAppendingPathComponent:notActiveValue] completion:^(GDataXMLDocument * doc) {
            // 处理播放列表
            NSMutableArray *vodItems = [NSMutableArray array];
            NSArray *playListNodes = [doc nodesForXPath:@"//div[@style='display: block;']//div[@class='hl-list-wrap']/ul/li/a" error:nil];
            
            for (GDataXMLElement *vod in playListNodes) {
                NSString *href = [[vod attributeForName:@"href"] stringValue];
                NSTextCheckingResult *match = [self.regexPlay firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                if (!match) continue;
                
                NSString *playURL = [NSString stringWithFormat:@"%@/%@-%@",
                                   [href substringWithRange:[match rangeAtIndex:1]],
                                   [href substringWithRange:[match rangeAtIndex:2]],
                                   [href substringWithRange:[match rangeAtIndex:3]]];
                [vodItems addObject:[NSString stringWithFormat:@"%@$%@", [[vod stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], playURL]];
            }
            
            if (vodItems.count > 0) {
                dic[notActiveKey] = [vodItems componentsJoinedByString:@"#"];
            }
            [self recursiveGetSourceWithDic:dic completion:completion];
        }];
    } else {
        completion(nil);
    }
}

- (void)playerContent:(NSString *)flag videoId:(NSString *)videoId vipFlags:(NSArray<NSString *> *)vipFlags completion:(void(^)(NSString *))completion{
    @try {
        // 构建播放请求头
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
//        headers[@"origin"] = @"https://jumi.tv";
        headers[@"User-Agent"] = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36";
        headers[@"Accept"] = @"*/*";
        headers[@"Accept-Language"] = @"zh-CN,zh;q=0.9,en-US;q=0.3,en;q=0.7";
        headers[@"Accept-Encoding"] = @"gzip, deflate";
        
        // 构建播放页URL https://crqzzl.szstsh.org/webPlayers/jialijiawai2009/2-1
        NSString *m3u8Url = [NSString stringWithFormat:@"%@/webPlayers/%@", self.siteUrl, videoId];
        [SpiderReq get:m3u8Url headers:headers completion:^(SpiderReqResult * _Nonnull srr) {
            if (srr.content.length > 0) {
//                __plying("{\"url\":\"https:\\/\\/v7.tlkqc.com\\/wjv7\\/202309\\/12\\/X8XhMXGuxL1\\/video\\/index.m3u8\"}")
                NSMutableDictionary *result = [NSMutableDictionary dictionary];
                NSRange startRange = [srr.content rangeOfString:@"http"];
                NSRange endRange = [srr.content rangeOfString:@".m3u8" options:NSBackwardsSearch];
                if (startRange.location == NSNotFound || endRange.location == NSNotFound) return;
                
                NSRange jsonRange = NSMakeRange(startRange.location,
                                              endRange.location - startRange.location + 5);
                NSString *urlString = [srr.content substringWithRange:jsonRange];
                urlString = [urlString stringByReplacingOccurrencesOfString:@"\\\\" withString:@""];
        
                if (urlString) {
                    result[@"parse"] = @"0";
                    result[@"playUrl"] = @"";
                    result[@"url"] = urlString;
                    result[@"header"] = headers;
                    NSString *str = [self convertToJSONString:result];
                    completion(str);
                }
            } else {
                completion(@"{}");
            }
        }];
    } @catch (NSException *e) {
        completion(@"{}");
        [SpiderDebug logWithThrowable:e];
    }
}

- (void)searchContent:(NSString *)key quick:(BOOL)quick completion:(void(^)(NSString *))completion {
    @try {
        if (quick) completion(@"");
        
        // 构建搜索URL
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//        https://www.zjmzjf.com/index.php/ajax/suggest?mid=1&wd=凡人
        // 以上url为api接口，返回json数据，直接处理，速度更快
        NSString *url = [NSString stringWithFormat:@"%@/s/?wd=%@", self.siteUrl, encodedKey];
        
        
        // 获取搜索结果
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];

        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
            NSArray *nodes = [doc nodesForXPath:@"//div[@class='hl-item-pic']/a" error:nil];
            NSMutableArray *list = [NSMutableArray array];
            for (GDataXMLNode *node in nodes) {
                NSString *vid = @"";
                NSString *href = [node firstNodeForXPath:@".//@href" error:nil].stringValue;
                NSTextCheckingResult *match = [self.regexVid firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                if (match) {
                    vid = [href substringWithRange:[match rangeAtIndex:1]];
                }
                NSString *pic = [node firstNodeForXPath:@".//@data-original" error:nil].stringValue;
                NSString *name = [node firstNodeForXPath:@".//@title" error:nil].stringValue;
                NSString *remark = [node firstNodeForXPath:@".//span[@class='hl-lc-1 remarks']" error:nil].stringValue;
                [list addObject:@{
                    @"vod_id": vid ?:@"",
                    @"vod_name": name ?:@"",
                    @"vod_pic": [self.siteUrl stringByAppendingPathComponent:pic] ?:@"",
                    @"vod_remarks":remark ?:@""
                }];
            }
            resultDic[@"list"] = list;
            NSString *str = [self convertToJSONString:resultDic];
            completion(str);
        }];
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (void)recursiveFetchLuxian:(NSString *)url dic:(NSMutableDictionary *)dic  completion:(void(^)(NSMutableDictionary *))completion {
    if (dic.allKeys.count == 0) {
        NSString *fullUrl = [self.siteUrl stringByAppendingPathComponent:url];
        [self fetchDocumentWithURL:fullUrl completion:^(GDataXMLDocument * docc) {
            NSArray *jisuNodes = [docc nodesForXPath:@"//div[@class='jisu']/a" error:nil];
            NSMutableArray *vodItems = [NSMutableArray array];
            for (GDataXMLElement *node in jisuNodes) {
                NSString *rel = [node attributeForName:@"rel"].stringValue;
                if (rel.length > 0) {
                    continue;
                }
                NSString *href = [node firstNodeForXPath:@".//@href" error:nil].stringValue;
                NSTextCheckingResult *match = [self.regexDetailVid firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                if (!match) continue;
                
                NSString *playURL = [NSString stringWithFormat:@"%@-%@-%@",
                                   [href substringWithRange:[match rangeAtIndex:1]],
                                   [href substringWithRange:[match rangeAtIndex:2]],
                                   [href substringWithRange:[match rangeAtIndex:3]]];
                [vodItems addObject:[NSString stringWithFormat:@"%@$%@", [node stringValue], playURL]];
            }
            GDataXMLNode *xianluNode = [docc firstNodeForXPath:@"//div[@class='xianlu']/a[@class='active']/text()" error:nil];
            NSString *sourceName = [xianluNode stringValue];
            dic[sourceName] = [vodItems componentsJoinedByString:@"#"];
            NSArray *allXianluNodes = [docc nodesForXPath:@"//div[@class='xianlu']/a" error:nil];
            for (GDataXMLNode *node in allXianluNodes) {
                NSString *xianluName = [node firstNodeForXPath:@".//text()" error:nil].stringValue;
                NSString *cls = [node firstNodeForXPath:@".//@class" error:nil].stringValue;
                if ([cls isEqualToString:@"active"]) {
                    continue;
                }
                dic[xianluName] = [node firstNodeForXPath:@".//@href" error:nil].stringValue;
            }
            NSString *nextUrl = @"";
            for (NSString *key in dic.allKeys) {
                NSString *value = dic[key];
                if ([value hasSuffix:@".html"]) {
                    nextUrl = value;
                    break;
                }
            }
            [self recursiveFetchLuxian:nextUrl dic:dic completion:completion];
        }];
    } else {
        if (url.length > 0) {
            NSString *fullUrl = [self.siteUrl stringByAppendingPathComponent:url];
            [self fetchDocumentWithURL:fullUrl completion:^(GDataXMLDocument * docc) {
                NSArray *jisuNodes = [docc nodesForXPath:@"//div[@class='jisu']/a" error:nil];
                NSMutableArray *vodItems = [NSMutableArray array];
                for (GDataXMLElement *node in jisuNodes) {
                    NSString *rel = [node attributeForName:@"rel"].stringValue;
                    if (rel.length > 0) {
                        continue;
                    }
                    NSString *href = [node firstNodeForXPath:@".//@href" error:nil].stringValue;
                    NSTextCheckingResult *match = [self.regexDetailVid firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                    if (!match) continue;
                    
                    NSString *playURL = [NSString stringWithFormat:@"%@-%@-%@",
                                       [href substringWithRange:[match rangeAtIndex:1]],
                                       [href substringWithRange:[match rangeAtIndex:2]],
                                       [href substringWithRange:[match rangeAtIndex:3]]];
                    [vodItems addObject:[NSString stringWithFormat:@"%@$%@", [node stringValue], playURL]];
                }
                GDataXMLNode *xianluNode = [docc firstNodeForXPath:@"//div[@class='xianlu']/a[@class='active']/text()" error:nil];
                NSString *sourceName = [xianluNode stringValue];
                dic[sourceName] = [vodItems componentsJoinedByString:@"#"];
                NSString *nextUrl = @"";
                for (NSString *key in dic.allKeys) {
                    NSString *value = dic[key];
                    if ([value hasSuffix:@".html"]) {
                        nextUrl = value;
                        break;
                    }
                }
                [self recursiveFetchLuxian:nextUrl dic:dic completion:completion];
            }];
        } else {
            completion(dic);
        }
    }
}


#pragma mark - 工具方法

- (void)fetchDocumentWithURL:(NSString *)url completion:(void(^)(GDataXMLDocument *))completion {
    NSDictionary *headers = [self getHeadersWithURL:url];
    
    [SpiderReq get:url headers:headers completion:^(SpiderReqResult * _Nonnull result) {
        if (result.content.length == 0) return;
        
        GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithHTMLString:result.content error:nil];
        completion(doc);
    }];
}

- (NSString *)convertToJSONString:(NSDictionary *)dict {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";
}

- (NSDictionary *)getHeadersWithURL:(NSString *)url {
    return @{
        @"method": @"GET",
        //        @"Host": [self siteHost],
        //        @"Upgrade-Insecure-Requests": @"1",
        //        @"sec-ch-ua-platform": @"macOS",
                @"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36",
                @"Accept": @"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        //        @"Accept-Language": @"zh-CN,zh;q=0.9",
                @"Referer":[self siteUrl]
    };
}

@end
