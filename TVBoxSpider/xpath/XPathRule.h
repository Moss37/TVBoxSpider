//
//  XPathRule.h
//  TVBoxSpider
//
//  Created by Moss37 on 2025/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPathRule : NSObject

// 基础属性
@property (copy, nonatomic) NSString *ua;
@property (copy, nonatomic) NSString *homeUrl;
@property (copy, nonatomic) NSString *cateNode;
@property (copy, nonatomic) NSString *cateName;
@property (strong, nonatomic, nullable) NSRegularExpression *cateNameR;
@property (copy, nonatomic) NSString *cateId;
@property (strong, nonatomic, nullable) NSRegularExpression *cateIdR;
@property (copy, nonatomic) NSDictionary<NSString *, NSString *> *cateManual;
@property (copy, nonatomic) NSDictionary *filter;

// 首页推荐属性
@property (copy, nonatomic) NSString *homeVodNode;
@property (copy, nonatomic) NSString *homeVodName;
@property (strong, nonatomic, nullable) NSRegularExpression *homeVodNameR;
@property (copy, nonatomic) NSString *homeVodId;
@property (strong, nonatomic, nullable) NSRegularExpression *homeVodIdR;
@property (copy, nonatomic) NSString *homeVodImg;
@property (strong, nonatomic, nullable) NSRegularExpression *homeVodImgR;
@property (copy, nonatomic) NSString *homeVodMark;
@property (strong, nonatomic, nullable) NSRegularExpression *homeVodMarkR;

// 分类页属性
@property (copy, nonatomic) NSString *cateUrl;
@property (copy, nonatomic) NSString *cateVodNode;
@property (copy, nonatomic) NSString *cateVodName;
@property (strong, nonatomic, nullable) NSRegularExpression *cateVodNameR;
@property (copy, nonatomic) NSString *cateVodId;
@property (strong, nonatomic, nullable) NSRegularExpression *cateVodIdR;
@property (copy, nonatomic) NSString *cateVodImg;
@property (strong, nonatomic, nullable) NSRegularExpression *cateVodImgR;
@property (copy, nonatomic) NSString *cateVodMark;
@property (strong, nonatomic, nullable) NSRegularExpression *cateVodMarkR;

// 详情页属性
@property (copy, nonatomic) NSString *dtUrl;
@property (copy, nonatomic) NSString *dtNode;
@property (copy, nonatomic) NSString *dtName;
@property (strong, nonatomic, nullable) NSRegularExpression *dtNameR;
@property (copy, nonatomic) NSString *dtImg;
@property (strong, nonatomic, nullable) NSRegularExpression *dtImgR;
@property (copy, nonatomic) NSString *dtCate;
@property (strong, nonatomic, nullable) NSRegularExpression *dtCateR;
@property (copy, nonatomic) NSString *dtYear;
@property (strong, nonatomic, nullable) NSRegularExpression *dtYearR;
@property (copy, nonatomic) NSString *dtArea;
@property (strong, nonatomic, nullable) NSRegularExpression *dtAreaR;
@property (copy, nonatomic) NSString *dtMark;
@property (strong, nonatomic, nullable) NSRegularExpression *dtMarkR;
@property (copy, nonatomic) NSString *dtActor;
@property (strong, nonatomic, nullable) NSRegularExpression *dtActorR;
@property (copy, nonatomic) NSString *dtDirector;
@property (strong, nonatomic, nullable) NSRegularExpression *dtDirectorR;
@property (copy, nonatomic) NSString *dtDesc;
@property (strong, nonatomic, nullable) NSRegularExpression *dtDescR;

// 播放来源属性
@property (copy, nonatomic) NSString *dtFromNode;
@property (copy, nonatomic) NSString *dtFromName;
@property (strong, nonatomic, nullable) NSRegularExpression *dtFromNameR;
@property (copy, nonatomic) NSString *dtUrlNode;
@property (copy, nonatomic) NSString *dtUrlSubNode;
@property (copy, nonatomic) NSString *dtUrlId;
@property (strong, nonatomic, nullable) NSRegularExpression *dtUrlIdR;
@property (copy, nonatomic) NSString *dtUrlName;
@property (strong, nonatomic, nullable) NSRegularExpression *dtUrlNameR;

// 播放属性
@property (copy, nonatomic) NSString *playUrl;
@property (copy, nonatomic) NSString *playUa;

// 搜索属性
@property (copy, nonatomic) NSString *searchUrl;
@property (copy, nonatomic) NSString *scVodNode;
@property (copy, nonatomic) NSString *scVodName;
@property (strong, nonatomic, nullable) NSRegularExpression *scVodNameR;
@property (copy, nonatomic) NSString *scVodId;
@property (strong, nonatomic, nullable) NSRegularExpression *scVodIdR;
@property (copy, nonatomic) NSString *scVodImg;
@property (strong, nonatomic, nullable) NSRegularExpression *scVodImgR;
@property (copy, nonatomic) NSString *scVodMark;
@property (strong, nonatomic, nullable) NSRegularExpression *scVodMarkR;

+ (instancetype)fromJson:(NSString *)json;

// 正则处理方法群
- (NSString *)getCateNameR:(NSString *)src;
- (NSString *)getCateIdR:(NSString *)src;
- (NSString *)getHomeVodNameR:(NSString *)src;
- (NSString *)getHomeVodIdR:(NSString *)src;
- (NSString *)getHomeVodImgR:(NSString *)src;
- (NSString *)getHomeVodMarkR:(NSString *)src;
- (NSString *)getCateVodNameR:(NSString *)src;
- (NSString *)getCateVodIdR:(NSString *)src;
- (NSString *)getCateVodImgR:(NSString *)src;
- (NSString *)getCateVodMarkR:(NSString *)src;
// 详情页相关
- (NSString *)getDetailNameR:(NSString *)src;
- (NSString *)getDetailImgR:(NSString *)src;
- (NSString *)getDetailCateR:(NSString *)src;
- (NSString *)getDetailYearR:(NSString *)src;
- (NSString *)getDetailAreaR:(NSString *)src;
- (NSString *)getDetailMarkR:(NSString *)src;
- (NSString *)getDetailActorR:(NSString *)src;
- (NSString *)getDetailDirectorR:(NSString *)src;
- (NSString *)getDetailDescR:(NSString *)src;
// 播放来源相关
- (NSString *)getDetailFromNameR:(NSString *)src;
- (NSString *)getDetailUrlIdR:(NSString *)src;
- (NSString *)getDetailUrlNameR:(NSString *)src;
// 搜索相关
- (NSString *)getSearchVodNameR:(NSString *)src;
- (NSString *)getSearchVodIdR:(NSString *)src;
- (NSString *)getSearchVodImgR:(NSString *)src;
- (NSString *)getSearchVodMarkR:(NSString *)src;


@end

NS_ASSUME_NONNULL_END
