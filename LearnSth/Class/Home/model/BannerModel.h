//
//  BannerModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BannerModel : NSObject

//@property (nonatomic, copy) NSString *addTime;
//@property (nonatomic, copy) NSString *adsmallpic;
//@property (nonatomic, copy) NSString *bigpic;
//
//@property (nonatomic, copy) NSString *contents;
//@property (nonatomic, copy) NSString *flv;
//@property (nonatomic, copy) NSString *gps;
//
//@property (nonatomic, strong) NSNumber *hiddenVer;
//@property (nonatomic, strong) NSNumber *lrCurrent;
//
//@property (nonatomic, copy) NSString *myname;
//@property (nonatomic, copy) NSString *signatures;
//@property (nonatomic, copy) NSString *smallpic;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *imageUrl;

//@property (nonatomic, strong) NSNumber *useridx;
//@property (nonatomic, strong) NSNumber *state;
//@property (nonatomic, strong) NSNumber *cutTime;
//@property (nonatomic, strong) NSNumber *orderid;
//@property (nonatomic, strong) NSNumber *roomid;
//@property (nonatomic, strong) NSNumber *serverid;

+ (NSArray *)bannerWithArray:(NSArray *)array;//转成模型数组

+ (void)cacheWithBanners:(NSArray *)banners;
+ (NSArray *)bannerWithCacheArray;

@end



