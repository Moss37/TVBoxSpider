//
//  Jumi.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/7.
//

#import "Jumi.h"
#import <GDataXML_HTML/GDataXMLNode.h>
#import "SpiderUrl.h"
#import "SpiderReq.h"
#import "SpiderDebug.h"
#import "GDataXMLNode+Extension.h"

@implementation Jumi {
    NSDictionary *_playerConfig;
    NSDictionary *_filterConfig;
}

+ (NSString *)siteUrl {
    return @"https://jumi.tv/";
}

+ (NSString *)siteHost {
    return @"jumi.tv";
}

- (NSRegularExpression *)regexCategory {
    
    return [NSRegularExpression regularExpressionWithPattern:@"/type/(\\S+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexVid {
    return [NSRegularExpression regularExpressionWithPattern:@"/vod/(\\d+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexPlay {
    return [NSRegularExpression regularExpressionWithPattern:@"/play/(\\d+)-(\\d+)-(\\d+).html" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (NSRegularExpression *)regexPage {
    return [NSRegularExpression regularExpressionWithPattern:@"\\S+/page/(\\d+)\\S+" options:NSRegularExpressionCaseInsensitive error:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupConfigurations];
    }
    return self;
}

- (instancetype)initWithExt:(NSString *)ext {
    self = [super init];
    if (self) {
        _ext = ext;
        [self setupConfigurations];
    }
    return self;
}

- (void)setupConfigurations {
    NSError *error = nil;
        NSString *playerConfigString = @"{\"mlm3u8\":{\"sh\":\"極速①線\",\"sn\":0,\"pu\":\"\",\"or\":999},\"jsm3u8\":{\"sh\":\"極速雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"hw8\":{\"sh\":\"華爲雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"wolong\":{\"sh\":\"卧龍雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"snm3u8\":{\"sh\":\"索尼雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"1080zyk\":{\"sh\":\"優質雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"sdm3u8\":{\"sh\":\"閃電雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"wjm3u8\":{\"sh\":\"無盡雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"modum3u8\":{\"sh\":\"魔都雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"kbm3u8\":{\"sh\":\"秒播雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"bjm3u8\":{\"sh\":\"八戒雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"hnm3u8\":{\"sh\":\"紅牛雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"bdxm3u8\":{\"sh\":\"北鬥雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"youku\":{\"sh\":\"優酷雲\",\"sn\":1,\"pu\":\"https://titan.mgtv.com.jumi.tv/player/?url=\",\"or\":999},\"mgtv\":{\"sh\":\"芒果雲\",\"sn\":1,\"pu\":\"https://titan.mgtv.com.jumi.tv/player/?url=\",\"or\":999},\"88zym3u8\":{\"sh\":\"88雲\",\"sn\":0,\"pu\":\"\",\"or\":999},\"qiyi\":{\"sh\":\"奇藝雲\",\"sn\":1,\"pu\":\"https://titan.mgtv.com.jumi.tv/player/?url=\",\"or\":999},\"dplayer\":{\"sh\":\"動漫專線\",\"sn\":0,\"pu\":\"\",\"or\":999},\"qq\":{\"sh\":\"騰訊雲\",\"sn\":1,\"pu\":\"https://titan.mgtv.com.jumi.tv/player/?url=\",\"or\":999}}";
        NSData *playerConfigData = [playerConfigString dataUsingEncoding:NSUTF8StringEncoding];
        _playerConfig = [NSJSONSerialization JSONObjectWithData:playerConfigData options:0 error:&error];
        if (error) {
            NSLog(@"Error parsing playerConfig: %@", error);
        }
    NSString *filterConfig = @"{\"1\":[{\"key\":\"tid\",\"name\":\"类型\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"動作片\",\"v\":\"6\"},{\"n\":\"喜劇片\",\"v\":\"7\"},{\"n\":\"愛情片\",\"v\":\"8\"},{\"n\":\"科幻片\",\"v\":\"9\"},{\"n\":\"恐怖片\",\"v\":\"10\"},{\"n\":\"劇情片\",\"v\":\"11\"},{\"n\":\"戰爭片\",\"v\":\"12\"},{\"n\":\"紀錄片\",\"v\":\"20\"}]},{\"key\":\"class\",\"name\":\"剧情\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"驚悚\",\"v\":\"驚悚\"},{\"n\":\"懸疑\",\"v\":\"懸疑\"},{\"n\":\"魔幻\",\"v\":\"魔幻\"},{\"n\":\"罪案\",\"v\":\"罪案\"},{\"n\":\"災難\",\"v\":\"災難\"},{\"n\":\"動畫\",\"v\":\"動畫\"},{\"n\":\"古裝\",\"v\":\"古裝\"},{\"n\":\"青春\",\"v\":\"青春\"},{\"n\":\"歌舞\",\"v\":\"歌舞\"},{\"n\":\"文藝\",\"v\":\"文藝\"},{\"n\":\"生活\",\"v\":\"生活\"},{\"n\":\"歷史\",\"v\":\"歷史\"},{\"n\":\"勵志\",\"v\":\"勵志\"},{\"n\":\"搞笑\",\"v\":\"搞笑\"},{\"n\":\"愛情\",\"v\":\"愛情\"},{\"n\":\"喜劇\",\"v\":\"喜劇\"},{\"n\":\"恐怖\",\"v\":\"恐怖\"},{\"n\":\"動作\",\"v\":\"動作\"},{\"n\":\"科幻\",\"v\":\"科幻\"},{\"n\":\"劇情\",\"v\":\"劇情\"},{\"n\":\"戰爭\",\"v\":\"戰爭\"},{\"n\":\"犯罪\",\"v\":\"犯罪\"},{\"n\":\"奇幻\",\"v\":\"奇幻\"},{\"n\":\"武俠\",\"v\":\"武俠\"},{\"n\":\"冒險\",\"v\":\"冒險\"},{\"n\":\"經典\",\"v\":\"經典\"},{\"n\":\"兒童\",\"v\":\"兒童\"}]},{\"key\":\"area\",\"name\":\"地区\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"大陸\",\"v\":\"大陸\"},{\"n\":\"香港\",\"v\":\"香港\"},{\"n\":\"台灣\",\"v\":\"台灣\"},{\"n\":\"美國\",\"v\":\"美國\"},{\"n\":\"法國\",\"v\":\"法國\"},{\"n\":\"英國\",\"v\":\"英國\"},{\"n\":\"日本\",\"v\":\"日本\"},{\"n\":\"韓國\",\"v\":\"韓國\"},{\"n\":\"德國\",\"v\":\"德國\"},{\"n\":\"泰國\",\"v\":\"泰國\"},{\"n\":\"印度\",\"v\":\"印度\"},{\"n\":\"意大利\",\"v\":\"意大利\"},{\"n\":\"西班牙\",\"v\":\"西班牙\"},{\"n\":\"加拿大\",\"v\":\"加拿大\"},{\"n\":\"其他\",\"v\":\"其他\"}]},{\"key\":\"year\",\"name\":\"年份\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"2021\",\"v\":\"2021\"},{\"n\":\"2020\",\"v\":\"2020\"},{\"n\":\"2019\",\"v\":\"2019\"},{\"n\":\"2018\",\"v\":\"2018\"},{\"n\":\"2017\",\"v\":\"2017\"},{\"n\":\"2016\",\"v\":\"2016\"},{\"n\":\"2015\",\"v\":\"2015\"},{\"n\":\"2014\",\"v\":\"2014\"},{\"n\":\"2013\",\"v\":\"2013\"},{\"n\":\"2012\",\"v\":\"2012\"},{\"n\":\"2011\",\"v\":\"2011\"},{\"n\":\"2010\",\"v\":\"2010\"}]},{\"key\":\"by\",\"name\":\"排序\",\"value\":[{\"n\":\"时间\",\"v\":\"\"},{\"n\":\"人气\",\"v\":\"hits\"},{\"n\":\"评分\",\"v\":\"score\"}]}],\"2\":[{\"key\":\"tid\",\"name\":\"类型\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"陸劇\",\"v\":\"13\"},{\"n\":\"港劇\",\"v\":\"14\"},{\"n\":\"台劇\",\"v\":\"22\"},{\"n\":\"日劇\",\"v\":\"15\"},{\"n\":\"韓劇\",\"v\":\"23\"},{\"n\":\"美劇\",\"v\":\"16\"},{\"n\":\"海外劇\",\"v\":\"24\"}]},{\"key\":\"class\",\"name\":\"剧情\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"言情\",\"v\":\"言情\"},{\"n\":\"都市\",\"v\":\"都市\"},{\"n\":\"家庭\",\"v\":\"家庭\"},{\"n\":\"生活\",\"v\":\"生活\"},{\"n\":\"偶像\",\"v\":\"偶像\"},{\"n\":\"喜劇\",\"v\":\"喜劇\"},{\"n\":\"歷史\",\"v\":\"歷史\"},{\"n\":\"古裝\",\"v\":\"古裝\"},{\"n\":\"武俠\",\"v\":\"武俠\"},{\"n\":\"刑偵\",\"v\":\"刑偵\"},{\"n\":\"戰爭\",\"v\":\"戰爭\"},{\"n\":\"神話\",\"v\":\"神話\"},{\"n\":\"軍旅\",\"v\":\"軍旅\"},{\"n\":\"諜戰\",\"v\":\"諜戰\"},{\"n\":\"商戰\",\"v\":\"商戰\"},{\"n\":\"校園\",\"v\":\"校園\"},{\"n\":\"穿越\",\"v\":\"穿越\"},{\"n\":\"懸疑\",\"v\":\"懸疑\"},{\"n\":\"犯罪\",\"v\":\"犯罪\"},{\"n\":\"科幻\",\"v\":\"科幻\"},{\"n\":\"愛情\",\"v\":\"愛情\"},{\"n\":\"其他\",\"v\":\"其他\"}]},{\"key\":\"area\",\"name\":\"地区\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"大陸\",\"v\":\"大陸\"},{\"n\":\"香港\",\"v\":\"香港\"},{\"n\":\"台灣\",\"v\":\"台灣\"},{\"n\":\"美國\",\"v\":\"美國\"},{\"n\":\"法國\",\"v\":\"法國\"},{\"n\":\"英國\",\"v\":\"英國\"},{\"n\":\"日本\",\"v\":\"日本\"},{\"n\":\"韓國\",\"v\":\"韓國\"},{\"n\":\"德國\",\"v\":\"德國\"},{\"n\":\"泰國\",\"v\":\"泰國\"},{\"n\":\"印度\",\"v\":\"印度\"},{\"n\":\"意大利\",\"v\":\"意大利\"},{\"n\":\"西班牙\",\"v\":\"西班牙\"},{\"n\":\"加拿大\",\"v\":\"加拿大\"},{\"n\":\"其他\",\"v\":\"其他\"}]},{\"key\":\"year\",\"name\":\"年份\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"2021\",\"v\":\"2021\"},{\"n\":\"2020\",\"v\":\"2020\"},{\"n\":\"2019\",\"v\":\"2019\"},{\"n\":\"2018\",\"v\":\"2018\"},{\"n\":\"2017\",\"v\":\"2017\"},{\"n\":\"2016\",\"v\":\"2016\"},{\"n\":\"2015\",\"v\":\"2015\"},{\"n\":\"2014\",\"v\":\"2014\"},{\"n\":\"2013\",\"v\":\"2013\"},{\"n\":\"2012\",\"v\":\"2012\"},{\"n\":\"2011\",\"v\":\"2011\"},{\"n\":\"2010\",\"v\":\"2010\"},{\"n\":\"2009\",\"v\":\"2009\"},{\"n\":\"2008\",\"v\":\"2008\"},{\"n\":\"2007\",\"v\":\"2007\"},{\"n\":\"2006\",\"v\":\"2006\"},{\"n\":\"2005\",\"v\":\"2005\"},{\"n\":\"2004\",\"v\":\"2004\"}]},{\"key\":\"by\",\"name\":\"排序\",\"value\":[{\"n\":\"时间\",\"v\":\"\"},{\"n\":\"人气\",\"v\":\"hits\"},{\"n\":\"评分\",\"v\":\"score\"}]}],\"3\":[{\"key\":\"class\",\"name\":\"剧情\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"选秀\",\"v\":\"选秀\"},{\"n\":\"情感\",\"v\":\"情感\"},{\"n\":\"访谈\",\"v\":\"访谈\"},{\"n\":\"播报\",\"v\":\"播报\"},{\"n\":\"旅游\",\"v\":\"旅游\"},{\"n\":\"音乐\",\"v\":\"音乐\"},{\"n\":\"美食\",\"v\":\"美食\"},{\"n\":\"纪实\",\"v\":\"纪实\"},{\"n\":\"曲艺\",\"v\":\"曲艺\"},{\"n\":\"生活\",\"v\":\"生活\"},{\"n\":\"游戏互动\",\"v\":\"游戏互动\"},{\"n\":\"财经\",\"v\":\"财经\"},{\"n\":\"求职\",\"v\":\"求职\"}]},{\"key\":\"area\",\"name\":\"地区\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"中国大陆\",\"v\":\"中国大陆\"},{\"n\":\"大陆\",\"v\":\"大陆\"},{\"n\":\"港台\",\"v\":\"港台\"},{\"n\":\"日韩\",\"v\":\"日韩\"},{\"n\":\"欧美\",\"v\":\"欧美\"}]},{\"key\":\"year\",\"name\":\"年份\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"2021\",\"v\":\"2021\"},{\"n\":\"2020\",\"v\":\"2020\"},{\"n\":\"2019\",\"v\":\"2019\"},{\"n\":\"2018\",\"v\":\"2018\"},{\"n\":\"2017\",\"v\":\"2017\"},{\"n\":\"2016\",\"v\":\"2016\"},{\"n\":\"2015\",\"v\":\"2015\"},{\"n\":\"2014\",\"v\":\"2014\"},{\"n\":\"2013\",\"v\":\"2013\"},{\"n\":\"2012\",\"v\":\"2012\"},{\"n\":\"2011\",\"v\":\"2011\"},{\"n\":\"2010\",\"v\":\"2010\"},{\"n\":\"2009\",\"v\":\"2009\"},{\"n\":\"2008\",\"v\":\"2008\"},{\"n\":\"2007\",\"v\":\"2007\"},{\"n\":\"2006\",\"v\":\"2006\"},{\"n\":\"2005\",\"v\":\"2005\"},{\"n\":\"2004\",\"v\":\"2004\"}]},{\"key\":\"by\",\"name\":\"排序\",\"value\":[{\"n\":\"时间\",\"v\":\"\"},{\"n\":\"人气\",\"v\":\"hits\"},{\"n\":\"评分\",\"v\":\"score\"}]}],\"4\":[{\"key\":\"class\",\"name\":\"剧情\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"情感\",\"v\":\"情感\"},{\"n\":\"科幻\",\"v\":\"科幻\"},{\"n\":\"热血\",\"v\":\"热血\"},{\"n\":\"推理\",\"v\":\"推理\"},{\"n\":\"搞笑\",\"v\":\"搞笑\"},{\"n\":\"冒险\",\"v\":\"冒险\"},{\"n\":\"萝莉\",\"v\":\"萝莉\"},{\"n\":\"校园\",\"v\":\"校园\"},{\"n\":\"动作\",\"v\":\"动作\"},{\"n\":\"机战\",\"v\":\"机战\"},{\"n\":\"运动\",\"v\":\"运动\"},{\"n\":\"战争\",\"v\":\"战争\"},{\"n\":\"少年\",\"v\":\"少年\"},{\"n\":\"少女\",\"v\":\"少女\"},{\"n\":\"社会\",\"v\":\"社会\"},{\"n\":\"原创\",\"v\":\"原创\"},{\"n\":\"亲子\",\"v\":\"亲子\"},{\"n\":\"益智\",\"v\":\"益智\"},{\"n\":\"励志\",\"v\":\"励志\"},{\"n\":\"其他\",\"v\":\"其他\"}]},{\"key\":\"area\",\"name\":\"地区\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"国产\",\"v\":\"国产\"},{\"n\":\"日本\",\"v\":\"日本\"},{\"n\":\"欧美\",\"v\":\"欧美\"},{\"n\":\"其他\",\"v\":\"其他\"}]},{\"key\":\"year\",\"name\":\"年份\",\"value\":[{\"n\":\"全部\",\"v\":\"\"},{\"n\":\"2021\",\"v\":\"2021\"},{\"n\":\"2020\",\"v\":\"2020\"},{\"n\":\"2019\",\"v\":\"2019\"},{\"n\":\"2018\",\"v\":\"2018\"},{\"n\":\"2017\",\"v\":\"2017\"},{\"n\":\"2016\",\"v\":\"2016\"},{\"n\":\"2015\",\"v\":\"2015\"},{\"n\":\"2014\",\"v\":\"2014\"},{\"n\":\"2013\",\"v\":\"2013\"},{\"n\":\"2012\",\"v\":\"2012\"},{\"n\":\"2011\",\"v\":\"2011\"},{\"n\":\"2010\",\"v\":\"2010\"},{\"n\":\"2009\",\"v\":\"2009\"},{\"n\":\"2008\",\"v\":\"2008\"},{\"n\":\"2007\",\"v\":\"2007\"},{\"n\":\"2006\",\"v\":\"2006\"},{\"n\":\"2005\",\"v\":\"2005\"},{\"n\":\"2004\",\"v\":\"2004\"}]},{\"key\":\"by\",\"name\":\"排序\",\"value\":[{\"n\":\"时间\",\"v\":\"\"},{\"n\":\"人气\",\"v\":\"hits\"},{\"n\":\"评分\",\"v\":\"score\"}]}]}";
    NSData *filterConfigData = [filterConfig dataUsingEncoding:NSUTF8StringEncoding];
    _filterConfig = [NSJSONSerialization JSONObjectWithData:filterConfigData options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing playerConfig: %@", error);
    }

}

- (void)homeContent:(BOOL)filter completion:(void(^)(NSString *))completion {
    @try {
        NSString *url = [Jumi.siteUrl stringByAppendingString:@"/"];
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
            // 分类处理
            NSMutableArray *classes = [NSMutableArray new];
            NSMutableSet *existingCategories = [NSMutableSet new];
            NSArray *categoryNodes = [doc nodesForXPath:@"//ul[contains(@class, 'item nav-list')]/li[contains(@class,'col-lg-5 col-md-5 col-sm-5 col-xs-3')]/a" error:nil];
            
            for (GDataXMLElement *node in categoryNodes) {
                NSString *name = [node stringValue];
                NSString *href = [[node attributeForName:@"href"] stringValue];
                
                // 分类过滤逻辑
                BOOL shouldShow = !filter || ([name isEqualToString:@"電影"] ||
                                           [name isEqualToString:@"劇集"] ||
                                           [name isEqualToString:@"綜藝"] ||
                                           [name isEqualToString:@"動漫"]);
                
                if (shouldShow && ![existingCategories containsObject:name]) {
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
            }
            
            // 构建结果
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            if (filter) result[@"filters"] = self->_filterConfig;
            result[@"class"] = classes;
            // 处理视频列表
            NSArray *vodNodes = [doc nodesForXPath:@"//div[contains(@class, 'col-lg-wide-75')]//ul[contains(@class,'myui-vodlist')]/li" error:nil];
            NSMutableArray *videos = [NSMutableArray arrayWithCapacity:vodNodes.count];
            
            for (GDataXMLNode *vodNode in vodNodes) {
                GDataXMLElement *thumbNode = [[vodNode nodesForXPath:@".//div[@class='myui-vodlist__box']/a" error:nil] firstObject];
                NSString *href = [[thumbNode attributeForName:@"href"] stringValue];
                
                NSTextCheckingResult *vidMatch = [self.regexVid firstMatchInString:href
                                                                          options:0
                                                                            range:NSMakeRange(0, href.length)];
                if (vidMatch) {
                    NSString *vid = [href substringWithRange:[vidMatch rangeAtIndex:1]];
                    GDataXMLNode *titleNode = [[thumbNode nodesForXPath:@"@title" error:nil] firstObject];
                    GDataXMLElement *imgNode = [[thumbNode nodesForXPath:@"@data-original" error:nil] firstObject];
                    GDataXMLNode *remarkNode = [[thumbNode nodesForXPath:@".//span[contains(@class,'pic-text')]/text()" error:nil] firstObject];
                    
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
        __block NSString *url = [Jumi.siteUrl stringByAppendingString:@"show/"];
        
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
        url = [url stringByAppendingFormat:@"/page/%@.html", pg];
        
        // 获取页面内容
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument * doc) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSInteger pageCount = 0;
            NSInteger page = -1;
            
            // 解析分页信息
            NSArray *pageInfoNodes = [doc nodesForXPath:@"//ul[contains(@class,'myui-page')]//li/a" error:nil];
            if (pageInfoNodes.count == 0) {
                page = [pg integerValue];
                pageCount = page;
            } else {
                for (GDataXMLElement *a in pageInfoNodes) {
                    NSString *name = [a stringValue];
                    if (page == -1 && [[a attributeForName:@"class"].stringValue containsString:@"btn-warm"]) {
                        NSString *href = [[a attributeForName:@"href"] stringValue];
                        NSTextCheckingResult *match = [self.regexPage firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                        if (match) {
                            page = [[href substringWithRange:[match rangeAtIndex:1]] integerValue];
                        } else {
                            page = 0;
                        }
                    }
                    if ([name isEqualToString:@"尾頁"]) {
                        NSString *href = [[a attributeForName:@"href"] stringValue];
                        NSTextCheckingResult *match = [self.regexPage firstMatchInString:href options:0 range:NSMakeRange(0, href.length)];
                        if (match) {
                            pageCount = [[href substringWithRange:[match rangeAtIndex:1]] integerValue];
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
                NSArray *listNodes = [doc nodesForXPath:@"//ul[contains(@class,'myui-vodlist')]//div[contains(@class,'myui-vodlist__box')]" error:nil];
                for (GDataXMLElement *vod in listNodes) {
                    NSString *title = [[[vod nodesForXPath:@".//a[contains(@class,'myui-vodlist__thumb')]/@title" error:nil] firstObject] stringValue];
                    NSString *cover = [[[vod nodesForXPath:@".//a[contains(@class,'myui-vodlist__thumb')]" error:nil] firstObject] attributeForName:@"data-original"].stringValue;
                    NSString *remark = [[[vod nodesForXPath:@".//span[contains(@class,'pic-text')]" error:nil] firstObject] stringValue];
                    NSString *href = [[[vod nodesForXPath:@".//a[contains(@class,'myui-vodlist__thumb')]" error:nil] firstObject] attributeForName:@"href"].stringValue;
                    
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
        NSString *url = [NSString stringWithFormat:@"%@vod/%@.html", Jumi.siteUrl, ids.firstObject];
        [self fetchDocumentWithURL:url completion:^(GDataXMLDocument *doc) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            NSMutableDictionary *vodList = [NSMutableDictionary dictionary];
            
            // 获取基本信息
            NSString *vid = [[[doc nodesForXPath:@"//span[contains(@class,'mac_hits')]" error:nil] firstObject] attributeForName:@"data-id"].stringValue;
            NSString *cover = [[[doc nodesForXPath:@"//a[contains(@class,'myui-vodlist__thumb')]//img" error:nil] firstObject] attributeForName:@"data-original"].stringValue;
            NSString *title = [[[doc nodesForXPath:@"//div[@class='myui-content__detail']//h1[@class='title']" error:nil] firstObject] stringValue];
            NSString *desc = [doc firstNodeForXPath:@"//div[contains(@class, 'myui-panel_bd')]/div[contains(@class, 'col-pd text-collapse content')]/span[contains(@class, 'data')]/text()" error:nil].stringValue;
            
            // 初始化详情信息
            NSString *category = @"", *area = @"", *year = @"", *remark = @"", *director = @"", *actor = @"";
            
            // 解析详情信息
            NSArray *infoNodes = [doc nodesForXPath:@"//div[@class='myui-content__detail']//span[contains(@class,'text-muted')]" error:nil];
            for (GDataXMLElement *node in infoNodes) {
                NSString *info = [node stringValue];
                if ([info isEqualToString:@"分類："]) {
                    category = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"年份："]) {
                    year = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"地區："]) {
                    area = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"更新："]) {
                    remark = [[[node nextSibling] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else if ([info isEqualToString:@"導演："]) {
                    NSMutableArray *directors = [NSMutableArray array];
                    GDataXMLNode *parent = [node parent];
                    NSArray *children = parent.children;
                    for (NSInteger index = 0; index < children.count; index++) {
                        GDataXMLNode *child = children[index];
                        NSString *stringValue = [child stringValue];
                        if (stringValue.length > 0 && ![stringValue isEqualToString:@" "] && ![stringValue isEqualToString:@"導演："]) {
                            [directors addObject:stringValue];
                        }
                    }
                    [parent releaseCachedValues];
                    director = [directors componentsJoinedByString:@","];
                } else if ([info isEqualToString:@"主演："]) {
                    NSMutableArray *actors = [NSMutableArray array];
                    GDataXMLNode *parent = [node parent];
                    NSArray *children = parent.children;
                    for (NSInteger index = 0; index < children.count; index++) {
                        GDataXMLNode *child = children[index];
                        NSString *stringValue = [child stringValue];
                        if (stringValue.length > 0 && ![stringValue isEqualToString:@" "] && ![stringValue isEqualToString:@"主演："]) {
                            [actors addObject:stringValue];
                        }
                    }
                    [parent releaseCachedValues];
                    actor = [actors componentsJoinedByString:@","];
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
            NSArray *h3Nodes = [doc nodesForXPath:@"//div[contains(@class,'myui-panel__head')]/h3[@class='title']" error:nil];
            GDataXMLElement *playSourceNode;
            for (GDataXMLElement *h3 in h3Nodes) {
                if ([[h3 stringValue] containsString:@"播放地址"]) {
                    playSourceNode = h3;
                    break;
                }
            }
            NSArray *sourceNodes = [[playSourceNode parent] nodesForXPath:@".//ul/li" error:nil];
            NSArray *sourceListNodes = [doc nodesForXPath:@"//div[contains(@class,'tab-content')]/div[contains(@class,'tab-pane')]" error:nil];
            
            for (NSInteger i = 0; i < sourceNodes.count; i++) {
                GDataXMLElement *source = sourceNodes[i];
                NSString *sourceName = [source stringValue];
                
                NSLog(@"%@", sourceName);
                
                // 查找播放源配置
                BOOL found = NO;
                for (NSString *flag in [self->_playerConfig allKeys]) {
                    if ([self->_playerConfig[flag][@"sh"] isEqualToString:sourceName]) {
                        sourceName = flag;
                        found = YES;
                        break;
                    }
                }
                if (!found) continue;
                
                // 处理播放列表
                NSMutableArray *vodItems = [NSMutableArray array];
                NSArray *playListNodes = [[sourceListNodes objectAtIndex:i] nodesForXPath:@".//ul/li/a" error:nil];
                
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
        headers[@"origin"] = @"https://jumi.tv";
        headers[@"User-Agent"] = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36";
        headers[@"Accept"] = @"*/*";
        headers[@"Accept-Language"] = @"zh-CN,zh;q=0.9,en-US;q=0.3,en;q=0.7";
        headers[@"Accept-Encoding"] = @"gzip, deflate";
        
        // 构建播放页URL
        NSString *url = [NSString stringWithFormat:@"%@play/%@.html", Jumi.siteUrl, videoId];
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
                    if (fromKey && [self->_playerConfig objectForKey:fromKey]) {
                        NSDictionary *playerCfg = self->_playerConfig[fromKey];
                        NSString *videoUrl = player[@"url"];
                        NSString *playUrl = playerCfg[@"pu"];
                        
                        result[@"parse"] = playerCfg[@"sn"];
                        result[@"playUrl"] = playUrl;
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
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *url = [NSString stringWithFormat:@"%@index.php/ajax/suggest?mid=1&wd=%@&limit=10&timestamp=%.0f",
                         Jumi.siteUrl, encodedKey, currentTime];
        
        // 获取搜索结果
        [SpiderReq get:url headers:[self getHeadersWithURL:url] completion:^(SpiderReqResult * _Nonnull srr) {
            NSString *content = srr.content;
            if (!content || content.length == 0) {
                completion(@"");
                return;
            }
            
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
                        v[@"vod_pic"] = vod[@"pic"];
                        v[@"vod_remarks"] = @"";
                        [videos addObject:v];
                    }
                }
            }
            
            result[@"list"] = videos;
            NSString *str = [self convertToJSONString:result];
            completion(str);
        }];
    } @catch (NSException *e) {
        completion(@"");
        [SpiderDebug logWithThrowable:e];
    }
}

- (NSString *)fetchContentFromUrl:(NSString *)url {
    @try {
        // 构建请求头
        NSDictionary *headers = [self getHeadersWithURL:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        // 设置请求头
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            [request setValue:value forHTTPHeaderField:key];
        }];
        
        // 发送同步请求
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&response
                                                        error:&error];
        
        if (error || !data) {
            [SpiderDebug logWithThrowable:error];
            return nil;
        }
        
        // 处理响应数据
        NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!content || content.length == 0) {
            // 尝试其他编码
            content = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        }
        
        return content;
        
    } @catch (NSException *e) {
        [SpiderDebug logWithThrowable:e];
    }
    return nil;
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
        @"Host": [Jumi siteHost],
        @"Upgrade-Insecure-Requests": @"1",
        @"DNT": @"1",
        @"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)...",
        @"Accept": @"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        @"Accept-Language": @"zh-CN,zh;q=0.8,zh-TW;q=0.7,en-US;q=0.3"
    };
}

@end
