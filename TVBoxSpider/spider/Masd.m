//
//  Hongxujixie.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/13.
//

#import "Masd.h"
#import <GDataXML_HTML/GDataXMLNode.h>
#import "SpiderUrl.h"
#import "SpiderReq.h"
#import "SpiderDebug.h"
#import "GDataXMLNode+Extension.h"
@interface Masd ()
{
    NSDictionary *_playerConfig;
    NSDictionary *_filterConfig;
}

@property (nonatomic, copy) NSString *siteUrl;
@property (nonatomic, copy) NSString *siteHost;

@end

@implementation Masd

- (instancetype)init
{
    self = [super init];
    if (self) {
        _siteUrl = @"https://www.masdxmt.com";
        _siteHost = @"masdxmt.com";
    }
    return self;
}

- (NSRegularExpression *)regexCategory {
    
    return [NSRegularExpression regularExpressionWithPattern:@"/category/(\\S+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexVid {
    return [NSRegularExpression regularExpressionWithPattern:@"/ba/(\\d+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexDetailVid {
    return [NSRegularExpression regularExpressionWithPattern:@"/jie/(\\d+)-(\\d+)-(\\d+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexPage {
    return [NSRegularExpression regularExpressionWithPattern:@"/vodshow/(\\d+)--------(\\d+)---.html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexPlay {
    return [NSRegularExpression regularExpressionWithPattern:@"/jie/(\\d+)-(\\d+)-(\\d+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (void)homeContent:(BOOL)filter completion:(void(^)(NSString *))completion {
    @try {
        NSString *url = [self.siteUrl stringByAppendingString:@"/"];
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
            // 分类处理
            NSMutableArray *classes = [NSMutableArray new];
            NSMutableSet *existingCategories = [NSMutableSet new];
            NSArray *categoryNodes = [doc nodesForXPath:@"//ul[@class='myui-header__menu nav-menu']/li/a" error:nil];
            
            for (GDataXMLElement *node in categoryNodes) {
                NSString *name = [node firstNodeForXPath:@".//text()" error:nil].stringValue;
                NSString *href = [[node firstNodeForXPath:@".//@href" error:nil] stringValue];
                NSTextCheckingResult *match = [self.regexCategory firstMatchInString:href
                                                                             options:0
                                                                               range:NSMakeRange(0, href.length)];
                if (match) {
                    NSString *typeID = [href substringWithRange:[match rangeAtIndex:1]];
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
            NSArray *vodNodes = [doc nodesForXPath:@"//ul[@class='myui-vodlist clearfix']/li[@class='col-lg-6 col-md-6 col-sm-4 col-xs-3']/div[@class='myui-vodlist__box']" error:nil];
            NSMutableArray *videos = [NSMutableArray arrayWithCapacity:vodNodes.count];
            
            for (GDataXMLElement *vodNode in vodNodes) {
                GDataXMLElement *thumbNode = [[vodNode nodesForXPath:@".//a[@class='myui-vodlist__thumb lazyload']" error:nil] firstObject];
                NSString *href = [[thumbNode attributeForName:@"href"] stringValue];
                
                NSTextCheckingResult *vidMatch = [self.regexVid firstMatchInString:href
                                                                           options:0
                                                                             range:NSMakeRange(0, href.length)];
                if (vidMatch) {
                    NSString *vid = [href substringWithRange:[vidMatch rangeAtIndex:1]];
                    GDataXMLNode *titleNode = [[thumbNode nodesForXPath:@"@title" error:nil] firstObject];
                    GDataXMLElement *imgNode = [[thumbNode nodesForXPath:@".//@data-original" error:nil] firstObject];
                    GDataXMLNode *remarkNode = [[vodNode nodesForXPath:@".//span[contains(@class,'pic-tag pic-tag-top')]/text()" error:nil] firstObject];
                    
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
        __block NSString *url = [self.siteUrl stringByAppendingString:@"/vodshow/"];
        
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
        url = [url stringByAppendingFormat:@"--------%@---.html", pg];
        
        // 获取页面内容
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument * doc) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSInteger pageCount = 0;
            NSInteger page = -1;
            
            // 解析分页信息
            NSArray *pageInfoNodes = [doc nodesForXPath:@"//ul[@class='myui-page text-center clearfix']/li/a" error:nil];
            if (pageInfoNodes.count == 0) {
                page = [pg integerValue];
                pageCount = page;
            } else {
                for (GDataXMLElement *a in pageInfoNodes) {
                    NSString *name = [a stringValue];
                    if (page == -1 && [[a attributeForName:@"class"].stringValue containsString:@"btn  btn-warm"]) {
                        NSString *href = [[a attributeForName:@"href"] stringValue];
                        NSTextCheckingResult *match = [self.regexPage firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                        if (match) {
                            page = [[href substringWithRange:[match rangeAtIndex:1]] integerValue];
                        } else {
                            page = 1;
                        }
                    }
                    if ([name isEqualToString:@"尾页"]) {
                        NSString *href = [[a attributeForName:@"href"] stringValue];
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
                NSArray *listNodes = [doc nodesForXPath:@"//li[contains(@class, 'col-lg-6 col-md-6 col-sm-4 col-xs-3')]//div[contains(@class,'myui-vodlist__box')]" error:nil];
                for (GDataXMLElement *vod in listNodes) {
                    GDataXMLElement *thumbNode = [[vod nodesForXPath:@".//a[@class='myui-vodlist__thumb lazyload']" error:nil] firstObject];

                    NSString *title = [[[thumbNode nodesForXPath:@".//@title" error:nil] firstObject] stringValue];
                    NSString *cover = [thumbNode attributeForName:@"data-original"].stringValue;
                    NSString *remark = [[[thumbNode nodesForXPath:@".//span[contains(@class,'pic-tag pic-tag-top')]" error:nil] firstObject] stringValue];
                    NSString *href = [thumbNode attributeForName:@"href"].stringValue;
                    
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
        NSString *url = [NSString stringWithFormat:@"%@/ba/%@.html", self.siteUrl, ids.firstObject];
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSMutableDictionary *vodList = [NSMutableDictionary dictionary];
            
            // 获取基本信息
            NSString *href = [[[doc nodesForXPath:@"//div[contains(@class,'myui-content__operate')]/a[@class='btn btn-warm']" error:nil] firstObject] attributeForName:@"href"].stringValue;
            NSString *vid = @"";
            NSTextCheckingResult *match = [self.regexDetailVid firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
            if (match) {
                vid = [NSString stringWithFormat:@"%@-%@-%@", [href substringWithRange:[match rangeAtIndex:1]], [href substringWithRange:[match rangeAtIndex:2]], [href substringWithRange:[match rangeAtIndex:3]]];
            }
            NSString *cover = [[[doc nodesForXPath:@"//div[contains(@class,'myui-content__thumb')]/a[@class='myui-vodlist__thumb img-md-220 img-sm-220 img-xs-130 picture']/img" error:nil] firstObject] attributeForName:@"src"].stringValue;
            NSString *title = [[[doc nodesForXPath:@"//div[contains(@class,'myui-content__detail')]/h1[@class='title text-fff']/text()" error:nil] firstObject] stringValue];
            NSString *desc = [[doc firstNodeForXPath:@"//meta[@itemprop='description']/@content" error:nil].stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            // 初始化详情信息
            NSString *category = @"", *area = @"", *year = @"", *remark = @"", *director = @"", *actor = @"";
            remark = [doc firstNodeForXPath:@"//div[contains(@class,'myui-content__detail')]/div[@class='score']/span[@class='branch']/text()" error:nil].stringValue;
            // 解析详情信息
            NSArray <GDataXMLNode *>*infoNodes = [doc nodesForXPath:@"//div[contains(@class,'myui-content__detail')]/span[contains(@class, 'text-muted')]" error:nil];
            for (GDataXMLNode *node in infoNodes) {
                NSString *info = [node stringValue];
                if ([info isEqualToString:@"分类："]) {
                    category = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"年份："]) {
                    year = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"地区："]) {
                    area = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
            }
            NSArray <GDataXMLNode *>*updates = [doc nodesForXPath:@"//div[contains(@class,'myui-content__detail')]/p[@class='data']/span[@class='text-muted']" error:nil];
            for (GDataXMLNode *node in updates) {
                NSString *name = [node firstNodeForXPath:@".//text()" error:nil].stringValue;
                if ([name isEqualToString:@"主演："]) {
                    NSMutableArray *directors = [NSMutableArray array];
                    GDataXMLNode *parent = [node parent];
                    NSArray *children = parent.children;
                    for (NSInteger index = 0; index < children.count; index++) {
                        GDataXMLNode *child = children[index];
                        NSString *stringValue = [child stringValue];
                        if (stringValue.length > 0 && ![stringValue isEqualToString:@" "] && ![stringValue isEqualToString:@"主演："]) {
                            [directors addObject:stringValue];
                        }
                    }
                    [parent releaseCachedValues];
                    actor = [directors componentsJoinedByString:@","];
                } else if ([name isEqualToString:@"导演："]) {
                    NSMutableArray *directors = [NSMutableArray array];
                    GDataXMLNode *parent = [node parent];
                    NSArray *children = parent.children;
                    for (NSInteger index = 0; index < children.count; index++) {
                        GDataXMLNode *child = children[index];
                        NSString *stringValue = [child stringValue];
                        if (stringValue.length > 0 && ![stringValue isEqualToString:@" "] && ![stringValue isEqualToString:@"导演："]) {
                            [directors addObject:stringValue];
                        }
                    }
                    [parent releaseCachedValues];
                    director = [directors componentsJoinedByString:@","];
                }
            }
            
            // 填充基本信息
            vodList[@"vod_id"] = vid ?: @"";
            vodList[@"vod_name"] = title ?: @"";
            vodList[@"vod_pic"] = cover ?: @"";
            vodList[@"type_name"] = category;
            vodList[@"vod_year"] = year;
            vodList[@"vod_area"] = area;
            vodList[@"vod_remarks"] = remark;
            vodList[@"vod_actor"] = actor;
            vodList[@"vod_director"] = director;
            vodList[@"vod_content"] = desc ?: @"";
            
            // 处理播放源
            NSMutableDictionary *vodPlay = [NSMutableDictionary dictionary];
            NSArray *sourceListNodes = [doc nodesForXPath:@"//div[contains(@class,'myui-panel myui-panel-bg clearfix')]/div[contains(@class,'myui-panel-box clearfix')]" error:nil];
            
            for (NSInteger i = 0; i < sourceListNodes.count; i++) {
                GDataXMLElement *source = sourceListNodes[i];
                NSString *sourceName = [[source firstNodeForXPath:@".//div[@class='myui-panel_hd']/div[@class='myui-panel__head active bottom-line clearfix']/h3[@class='title']" error:nil] stringValue];
                
                NSLog(@"%@", sourceName);
                
                // 查找播放源配置
                if ([sourceName isEqualToString:@"猜你喜欢"]) continue;
                
                // 处理播放列表
                NSMutableArray *vodItems = [NSMutableArray array];
                NSArray *playListNodes = [[sourceListNodes objectAtIndex:i] nodesForXPath:@".//div[@class='tab-content myui-panel_bd']/div[@class='tab-pane fade in clearfix active']/ul/li/a" error:nil];
                
                for (GDataXMLElement *vod in playListNodes) {
                    NSString *href = [[vod attributeForName:@"href"] stringValue];
                    NSTextCheckingResult *match = [self.regexPlay firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                    if (!match) continue;
                    
                    NSString *playURL = [NSString stringWithFormat:@"%@-%@-%@",
                                       [href substringWithRange:[match rangeAtIndex:1]],
                                       [href substringWithRange:[match rangeAtIndex:2]],
                                       [href substringWithRange:[match rangeAtIndex:3]]];
                    [vodItems addObject:[NSString stringWithFormat:@"%@$%@", [vod stringValue], playURL]];
                }
                
                if (vodItems.count > 0) {
                    vodPlay[sourceName] = [vodItems componentsJoinedByString:@"#"];
                }
            }
            
            // 合并播放源信息
            if (vodPlay.count > 0) {
                vodList[@"vod_play_from"] = [[vodPlay allKeys] componentsJoinedByString:@"$$$"];
                vodList[@"vod_play_url"] = [[vodPlay allValues] componentsJoinedByString:@"$$$"];
            }
            result[@"list"] = @[vodList];
            NSString *str = [self convertToJSONString:result];
            completion(str);
        }];
        
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
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
        
        // 构建播放页URL
        NSString *url = [NSString stringWithFormat:@"%@/jie/%@.html", self.siteUrl, videoId];
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
            NSArray *scriptNodes = [doc nodesForXPath:@"//script" error:nil];
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            
            for (GDataXMLNode *script in scriptNodes) {
                NSString *scriptContent = [script stringValue];
                if ([scriptContent hasPrefix:@"var player_"]) {
                    // 提取JSON内容
                    NSRange startRange = [scriptContent rangeOfString:@"{"];
                    NSRange endRange = [scriptContent rangeOfString:@"}" options:NSBackwardsSearch];
                    if (startRange.location == NSNotFound || endRange.location == NSNotFound) continue;
                    
                    NSRange jsonRange = NSMakeRange(startRange.location,
                                                  endRange.location - startRange.location + 1);
                    NSString *jsonString = [scriptContent substringWithRange:jsonRange];
                    
                    NSError *error = nil;
                    NSDictionary *player = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options:0
                                                                           error:&error];
                    if (error) continue;
                    
                    NSString *fromKey = player[@"from"];
                    if (fromKey) {
                        NSString *videoUrl = player[@"url"];
                        result[@"parse"] = @"0";
                        result[@"playUrl"] = @"";
                        result[@"url"] = videoUrl;
                        result[@"header"] = headers;
                        break;
                    }
                }
            }
            
            NSString *str = [self convertToJSONString:result];
            completion(str);
        }];
    } @catch (NSException *e) {
        completion(@"");
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
        NSString *url = [NSString stringWithFormat:@"%@/index.php/ajax/suggest?mid=1&wd=%@", self.siteUrl, encodedKey];
        
        [SpiderReq get:url headers:[self getHeadersWithURL:url] completion:^(SpiderReqResult * _Nonnull srr) {
                    NSString *content = srr.content;
            if (!content || content.length == 0) completion(@"");return;
                    NSError *error = nil;
                    NSDictionary *searchResult = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding]
                                                                               options:0
                                                                                 error:&error];
                    if (error) completion(@"");
                    
                    NSMutableDictionary *result = [NSMutableDictionary dictionary];
                    NSMutableArray *videos = [NSMutableArray array];
                    
                    if ([searchResult[@"total"] integerValue] > 0) {
                        NSArray *lists = searchResult[@"list"];
                        if (!error) {
                            for (NSDictionary *vod in lists) {
                                NSMutableDictionary *v = [NSMutableDictionary dictionary];
                                v[@"vod_id"] = vod[@"id"];
                                v[@"vod_name"] = vod[@"name"];
                                v[@"vod_pic"] = [self.siteUrl stringByAppendingPathComponent:vod[@"pic"]];
                                v[@"vod_remarks"] = @"";
                                [videos addObject:v];
                            }
                        }
                    }
                    
                    result[@"list"] = videos;
                    NSString *str = [self convertToJSONString:result];
                    completion(str);
        }];
        
//        NSString *url = [NSString stringWithFormat:@"%@/kkwusc/-------------.html?wd=%@",
//                         self.siteUrl, encodedKey];
        
        // 获取搜索结果
//        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
//
//        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
//            NSArray *nodes = [doc nodesForXPath:@"//div[@class='block search-con mt15 mb30']/ul/li" error:nil];
//            NSMutableArray *list = [NSMutableArray array];
//            for (GDataXMLNode *node in nodes) {
//                NSString *vid = @"";
//                NSString *href = [node firstNodeForXPath:@".//div[@class='info']/p/a/@href" error:nil].stringValue;
//                NSTextCheckingResult *match = [self.regexVid firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
//                if (match) {
//                    vid = [href substringWithRange:[match rangeAtIndex:1]];
//                }
//                NSString *pic = [node firstNodeForXPath:@".//div[@class='pic']/a/img/@data-src" error:nil].stringValue;
//                NSString *name = [node firstNodeForXPath:@".//div[@class='info']/p/a/text()" error:nil].stringValue;
//                NSString *remark = @"";
//                [list addObject:@{
//                    @"vod_id": vid ?:@"",
//                    @"vod_name": name ?:@"",
//                    @"vod_pic": [self.siteUrl stringByAppendingPathComponent:pic] ?:@"",
//                    @"vod_remarks":remark ?:@""
//                }];
//            }
//            resultDic[@"list"] = list;
//            NSString *str = [self convertToJSONString:resultDic];
//            completion(str);
//        }];
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
        //        @"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36",
        //        @"Accept": @"text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
        //        @"Accept-Language": @"zh-CN,zh;q=0.9",
        //        @"Referer":[self siteUrl]
    };
}

@end
