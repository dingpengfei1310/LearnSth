//
//  HttpManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessArray)(NSArray *list,NSError *error);
typedef void (^Success)(id responseData);
typedef void (^Failure)(NSError *error);

@interface HttpManager : NSObject

+ (instancetype)shareManager;

#pragma mark
/// 广告
- (void)getAdBannerListCompletion:(SuccessArray)completion;

///热门直播
- (void)getHotLiveListWithParamers:(NSDictionary *)paramers
                        completion:(SuccessArray)completion;

///
- (void)getUserListWithParamers:(NSDictionary *)paramers
                     completion:(SuccessArray)completion;

@end
