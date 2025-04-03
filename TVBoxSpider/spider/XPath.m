//
//  XPath.m
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/10.
//

#import "XPath.h"
#import "SpiderDebug.h"
#import "SpiderReq.h"
#import "SpiderUrl.h"
#import "Misc.h"
#import "GDataXMLNode+XPathExtensions.h"

@implementation XPath

#pragma mark - 初始化方法

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoFormats = @[@".m3u8", @".mp4", @".mpeg", @".flv"];
    }
    return self;
}

- (instancetype)initWithExt:(NSString *)ext {
    self = [self init];
    if (self) {
        _ext = ext;
    }
    return self;
}

- (void)loadRuleExt:(NSString *)json {
    // 实现规则加载逻辑
}

#pragma mark - Spider 方法重写

- (void)homeVideoContentCompletion:(void(^)(NSString *))completion {
    [self fetchRule];
    completion(@"");
}

- (void)homeContent:(BOOL)flag completion:(void(^)(NSString *))completion {
    [self fetchRule];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableArray *classes = [NSMutableArray array];
    
    if (self.rule && self.rule.cateManual.count > 0) {
        [self.rule.cateManual enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            [classes addObject:@{@"type_name": key, @"type_id": value}];
            result[@"class"] = classes;
            
            if (flag && self.rule.filter) {
                result[@"filters"] = self.rule.filter;
            }
            
            NSString *str = [self convertToJSON:result];
            completion(str);
        }];
    } else if (self.rule.homeUrl.length > 0) {
        [self fetchGDataDocumentWithUrl:self.rule.homeUrl completion:^(GDataXMLDocument * _Nonnull doc) {
            if (doc) {
                @try {
                    NSArray *navNodes = [doc.rootElement nodesForXPath:self.rule.cateNode error:nil];
                    for (GDataXMLElement *element in navNodes) {
                        NSString *name = [[element firstNodeForXPath:self.rule.cateName.subNodeText error:nil] stringValue];
                        NSString *typeId = [[element firstNodeForXPath:self.rule.cateId.subNodeText error:nil] stringValue];
                        [classes addObject:@{
                            @"type_id": [self.rule getCateIdR:typeId],
                            @"type_name": [self.rule getCateNameR:name]
                        }];
                    }
                    
                    if (self.rule.homeVodNode.length > 0) {
                        NSArray *vodNodes = [doc.rootElement nodesForXPath:self.rule.homeVodNode error:nil];
                        NSMutableArray *videos = [NSMutableArray array];
                        
                        for (GDataXMLElement *vodNode in vodNodes) {
                            NSString *homeVodName = [[vodNode firstNodeForXPath:self.rule.homeVodName.subNodeText error:nil] stringValue];
                            NSString *homeVodId = [[vodNode firstNodeForXPath:self.rule.homeVodId.subNodeText error:nil] stringValue];
                            NSString *homeVodImg = [[vodNode firstNodeForXPath:self.rule.homeVodImg.subNodeText error:nil] stringValue];
                            homeVodImg = [Misc fixUrl:self.rule.homeUrl src:homeVodImg];
                            
                            NSString *mark = @"";
                            if (self.rule.homeVodMark.length > 0) {
                                mark = [[vodNode firstNodeForXPath:self.rule.homeVodMark.subNodeText error:nil] stringValue];
                            }
                            
                            [videos addObject:@{
                                @"vod_id": homeVodId,
                                @"vod_name": homeVodName,
                                @"vod_pic": homeVodImg,
                                @"vod_remarks": mark
                            }];
                        }
                        
                        result[@"list"] = videos;
                    }
                } @catch (NSException *exception) {
                    [SpiderDebug logWithMsg:exception.description];
                }
            }
            result[@"class"] = classes;
            
            if (flag && self.rule.filter) {
                result[@"filters"] = self.rule.filter;
            }
            
            NSString *str = [self convertToJSON:result];
            completion(str);
        }];
    }
}

- (void)categoryContent:(NSString *)tid page:(NSString *)pg filter:(BOOL)filter extend:(NSDictionary<NSString *, NSString *> *)extend completion:(void(^)(NSString *))completion {
    [self fetchRule];
    if (!self.rule) {
        completion(@"{}");
        return;
    }
    
    NSString *webUrl = [self.rule.cateUrl stringByReplacingOccurrencesOfString:@"{cateId}" withString:tid];
    webUrl = [webUrl stringByReplacingOccurrencesOfString:@"{catePg}" withString:pg];
    
    [self fetchGDataDocumentWithUrl:webUrl completion:^(GDataXMLDocument * _Nonnull doc) {
        if (!doc) {
            completion(@"{}");
        }
        
        NSMutableArray *videos = [NSMutableArray array];
        @try {
            NSArray *vodNodes = [doc.rootElement nodesForXPath:self.rule.cateVodNode error:nil];
            for (GDataXMLElement *node in vodNodes) {
                NSString *name = [[node firstNodeForXPath:self.rule.cateVodName.subNodeText error:nil] stringValue];
                NSString *id = [[node firstNodeForXPath:self.rule.cateVodId.subNodeText error:nil] stringValue];
                NSString *pic = [Misc fixUrl:webUrl src:[[node firstNodeForXPath:self.rule.cateVodImg.subNodeText error:nil] stringTrimmed]];
                
                NSString *mark = @"";
                if (self.rule.cateVodMark.length > 0) {
                    mark = [[node firstNodeForXPath:self.rule.cateVodMark.subNodeText error:nil] stringValue];
                }
                
                [videos addObject:@{
                    @"vod_id": [self.rule getCateVodIdR:id],
                    @"vod_name": [self.rule getCateVodNameR:name],
                    @"vod_pic": pic,
                    @"vod_remarks": [self.rule getCateVodMarkR:mark]
                }];
            }
        } @catch (NSException *exception) {
            [SpiderDebug logWithMsg:exception.description];
        }
        
        NSString *str = [self convertToJSON:@{
            @"page": pg,
            @"pagecount": @(NSIntegerMax),
            @"limit": @90,
            @"total": @(NSIntegerMax),
            @"list": videos
        }];
        completion(str);
    }];
}

- (void)detailContent:(NSArray<NSString *> *)ids completion:(void(^)(NSString *))completion {
    [self fetchRule];
    if (!self.rule || ids.count == 0) {
        completion(@"{}");
        return;
    }
    
    NSString *webUrl = [self.rule.dtUrl stringByReplacingOccurrencesOfString:@"{vid}" withString:ids[0]];
    [self fetchGDataDocumentWithUrl:webUrl completion:^(GDataXMLDocument * _Nonnull doc) {
        if (!doc) {
            completion(@"{}");
            return;
        }
        
        NSMutableDictionary *vod = [NSMutableDictionary dictionary];
        @try {
            GDataXMLElement *vodNode = (GDataXMLElement *)[doc.rootElement firstNodeForXPath:self.rule.dtNode error:nil];
            
            vod[@"vod_id"] = ids[0];
            vod[@"vod_name"] = [self.rule getDetailNameR:[[vodNode firstNodeForXPath:self.rule.dtName error:nil] stringTrimmed]];
            vod[@"vod_pic"] = [Misc fixUrl:webUrl src:[[vodNode firstNodeForXPath:self.rule.dtImg error:nil] stringTrimmed]];
            
            if (self.rule.dtCate.length > 0) {
                vod[@"type_name"] = [self.rule getDetailCateR:[[vodNode firstNodeForXPath:self.rule.dtCate error:nil] stringTrimmed]];
            }
            if (self.rule.dtYear.length > 0) {
                vod[@"vod_year"] = [self.rule getDetailYearR:[[vodNode firstNodeForXPath:self.rule.dtYear error:nil] stringTrimmed]];
            }
            if (self.rule.dtArea.length > 0) {
                vod[@"vod_area"] = [self.rule getDetailAreaR:[[vodNode firstNodeForXPath:self.rule.dtArea error:nil] stringTrimmed]];
            }
            if (self.rule.dtMark.length > 0) {
                vod[@"vod_remarks"] = [self.rule getDetailMarkR:[[vodNode firstNodeForXPath:self.rule.dtMark error:nil] stringTrimmed]];
            }
            if (self.rule.dtActor.length > 0) {
                vod[@"vod_actor"] = [self.rule getDetailActorR:[[vodNode firstNodeForXPath:self.rule.dtActor error:nil] stringTrimmed]];
            }
            if (self.rule.dtDirector.length > 0) {
                vod[@"vod_director"] = [self.rule getDetailDirectorR:[[vodNode firstNodeForXPath:self.rule.dtDirector error:nil] stringTrimmed]];
            }
            if (self.rule.dtDesc.length > 0) {
                vod[@"vod_content"] = [self.rule getDetailDescR:[[vodNode firstNodeForXPath:self.rule.dtDesc error:nil] stringTrimmed]];
            }
        } @catch (NSException *exception) {
            [SpiderDebug logWithMsg:exception.description];
        }
        
        NSString *str = [self convertToJSON:@{@"list": @[vod]}];
        completion(str);
    }];
}

- (void)playerContent:(NSString *)flag videoId:(NSString *)videoId vipFlags:(NSArray<NSString *> *)vipFlags completion:(void(^)(NSString *))completion {
    [self fetchRule];
    if (!self.rule) {
        completion(@"{}");
        return;
    }
    
    NSString *webUrl = self.rule.playUrl.length == 0 ? videoId : [self.rule.playUrl stringByReplacingOccurrencesOfString:@"{playUrl}" withString:videoId];
    NSString * str = [self convertToJSON:@{
        @"parse": @1,
        @"playUrl": @"",
        @"ua": self.rule.playUa,
        @"url": webUrl
    }];
    completion(str);
}

- (void)searchContent:(NSString *)key quick:(BOOL)quick completion:(void(^)(NSString *))completion {
    @try {
        [self fetchRule];
        NSString *searchUrl = self.rule.searchUrl;
        if (searchUrl.length == 0) {
            completion(@"{\"list\":[]}");
        }
        
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *webUrl = [searchUrl stringByReplacingOccurrencesOfString:@"{wd}" withString:encodedKey];
        
        SpiderUrl *spiderUrl = [[SpiderUrl alloc] initWithURL:webUrl headers:[self getHeadersForUrl:webUrl]];
        [SpiderReq get:spiderUrl.url headers:spiderUrl.headers completion:^(SpiderReqResult * _Nonnull srr) {
            NSMutableArray *videos = [NSMutableArray array];
            NSString *searchNode = self.rule.scVodNode;
            
            // JSON格式的搜索结果处理
            if ([searchNode hasPrefix:@"json:"]) {
                NSString *nodePath = [searchNode substringFromIndex:5];
                NSArray *pathComponents = [nodePath componentsSeparatedByString:@">"];
                
                NSData *jsonData = [srr.content dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                
                if (error) {
                    completion(@"{\"list\":[]}");
                }
                
                id currentObj = jsonObj;
                for (NSInteger i = 0; i < pathComponents.count; i++) {
                    NSString *component = pathComponents[i];
                    if (i == pathComponents.count - 1) {
                        NSArray *items = currentObj[component];
                        for (NSDictionary *item in items) {
                            NSMutableDictionary *vod = [NSMutableDictionary dictionary];
                            if (item[self.rule.scVodName]) {
                                vod[@"vod_name"] = [self.rule getSearchVodNameR:item[self.rule.scVodName]];
                            }
                            if (item[self.rule.scVodId]) {
                                vod[@"vod_id"] = [self.rule getSearchVodIdR:item[self.rule.scVodId]];
                            }
                            if (item[self.rule.scVodImg]) {
                                vod[@"vod_pic"] = [self.rule getSearchVodImgR:[Misc fixUrl:webUrl src:item[self.rule.scVodImg]]];
                            }
                            if (item[self.rule.scVodMark]) {
                                vod[@"vod_remarks"] = [self.rule getSearchVodMarkR:item[self.rule.scVodMark]];
                            }
                            [videos addObject:vod];
                        }
                    } else {
                        currentObj = currentObj[component];
                        if (!currentObj) {
                            break;
                        }
                    }
                }
            } else {
                // HTML格式的搜索结果处理
                GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:srr.content error:nil];
                if (!doc) {
                    completion(@"{\"list\":[]}");
                }
                
                NSArray *vodNodes = [doc.rootElement nodesForXPath:self.rule.scVodNode error:nil];
                for (GDataXMLElement *element in vodNodes) {
                    NSMutableDictionary *vod = [NSMutableDictionary dictionary];
                    
                    @try {
                        if (self.rule.scVodName.length > 0) {
                            GDataXMLNode *nameNode = [element firstNodeForXPath:self.rule.scVodName error:nil];
                            if (nameNode) {
                                vod[@"vod_name"] = [self.rule getSearchVodNameR:[nameNode stringValue]];
                            }
                        }
                        
                        if (self.rule.scVodId.length > 0) {
                            GDataXMLNode *idNode = [element firstNodeForXPath:self.rule.scVodId error:nil];
                            if (idNode) {
                                vod[@"vod_id"] = [self.rule getSearchVodIdR:[idNode stringValue]];
                            }
                        }
                        
                        if (self.rule.scVodImg.length > 0) {
                            GDataXMLNode *imgNode = [element firstNodeForXPath:self.rule.scVodImg error:nil];
                            if (imgNode) {
                                NSString *imgUrl = [Misc fixUrl:webUrl src:[imgNode stringValue]];
                                vod[@"vod_pic"] = [self.rule getSearchVodImgR:imgUrl];
                            }
                        }
                        
                        if (self.rule.scVodMark.length > 0) {
                            GDataXMLNode *markNode = [element firstNodeForXPath:self.rule.scVodMark error:nil];
                            if (markNode) {
                                vod[@"vod_remarks"] = [self.rule getSearchVodMarkR:[markNode stringValue]];
                            }
                        }
                    } @catch (NSException *exception) {
                        [SpiderDebug logWithMsg:exception.description];
                    }
                    
                    if (vod.count > 0) {
                        [videos addObject:vod];
                    }
                }
            }
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"list": videos} options:0 error:&error];
            if (error) {
                completion(@"{\"list\":[]}");
            }
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            completion(jsonString ?: @"{\"list\":[]}");
        }];
    } @catch (NSException *exception) {
        [SpiderDebug logWithMsg:[NSString stringWithFormat:@"搜索失败: %@", exception.description]];
        completion(@"{\"list\":[]}");
    }
}

#pragma mark - 工具方法

- (void)fetchGDataDocumentWithUrl:(NSString *)url completion:(void(^)(GDataXMLDocument *))completion {
    NSURL *nsUrl = [NSURL URLWithString:url];
    if (!nsUrl) {
        completion(nil);
        return;
    }
    
    NSDictionary *headers = [self getHeadersForUrl:url];
    SpiderUrl *spiderURL = [[SpiderUrl alloc] initWithURL:url headers:headers];
    [SpiderReq get:spiderURL.url headers:headers completion:^(SpiderReqResult * _Nonnull result) {
        NSError *error = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:result.content error:&error];
        if (error) {
            [SpiderDebug logWithMsg:error.localizedDescription];
        }
        completion(doc);
    }];
}

- (NSDictionary<NSString *, NSString *> *)getHeadersForUrl:(NSString *)url {
    NSString *userAgent = self.rule.ua.length > 0 ? self.rule.ua : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36";
    
    return @{@"User-Agent": userAgent};
}

- (NSString *)convertToJSON:(NSDictionary *)dict {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error) {
        return @"{}";
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString ?: @"{}";
}

#pragma mark - 规则加载

- (void)fetchRule {
    if (self.rule != nil || self.ext == nil) {
        return;
    }
    
    if ([self.ext hasPrefix:@"http"]) {
        NSURL *url = [NSURL URLWithString:self.ext];
        if (!url) {
            return;
        }
        
        SpiderUrl *spiderURL = [[SpiderUrl alloc] initWithURL:self.ext headers:@{}];
        [SpiderReq get:spiderURL.url headers:[self getHeadersForUrl:self.ext] completion:^(SpiderReqResult * _Nonnull result) {
            XPathRule *rule = [XPathRule fromJson:result.content];
            if (rule) {
                self.rule = rule;
            }
        }];
    } else {
        self.rule = [XPathRule fromJson:self.ext];
    }
}

- (void)fetchWithWebUrl:(NSString *)webUrl completion:(void(^)(SpiderReqResult *))completion {
    [SpiderDebug logWithMsg:webUrl];
    SpiderUrl *su = [[SpiderUrl alloc] initWithURL:webUrl headers:[self getHeadersForUrl:webUrl]];
    [SpiderReq get:su.url headers:su.headers completion:^(SpiderReqResult * _Nonnull result) {
        completion(result);
    }];
}

@end
        
        
