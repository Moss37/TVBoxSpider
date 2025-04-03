//
//  XPath.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/10.
//

#import <Foundation/Foundation.h>
#import "Spider.h"
#import "XPathRule.h"
#import "GDataXML_HTML/GDataXMLNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPath : NSObject<Spider>

// 配置属性
@property (nonatomic, strong, nullable) NSString *ext;
@property (nonatomic, strong, nullable) XPathRule *rule;
@property (nonatomic, strong, readonly) NSArray<NSString *> *videoFormats;

// 初始化方法
- (instancetype)initWithExt:(NSString *)ext;

// 加载规则
- (void)loadRuleExt:(NSString *)json;
- (void)fetchRule;

// 网络请求方法
- (NSDictionary<NSString *, NSString *> *)getHeadersForUrl:(NSString *)url;
- (NSString *)convertToJSON:(NSDictionary *)dict;
- (void)fetchGDataDocumentWithUrl:(NSString *)url completion:(void(^)(GDataXMLDocument *))completion;

@end

NS_ASSUME_NONNULL_END
