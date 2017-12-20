//
//  HttpManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Success)(id responseData);
typedef void (^Failure)(NSError *error);

typedef void (^CompletionArray)(NSArray *list,NSError *error);
typedef void (^Completion)(NSDictionary *data,NSError *error);

typedef NS_ENUM(NSInteger, HttpErrorCode) {
    HttpErrorCodeDefault,
    HttpErrorCodeCancel,
    HttpErrorCodeNodata,
    HttpErrorCodeUnknown
};

@interface HttpManager : NSObject

+ (instancetype)shareManager;
- (void)cancelAllRequest;

#pragma mark
/// 广告
- (void)getAdBannerListCompletion:(CompletionArray)completion;

///热门
- (void)getHotLiveListWithParam:(NSDictionary *)paramers
                     completion:(CompletionArray)completion;

///列表
- (void)getYingKeLiveListCompletion:(CompletionArray)completion;

@end
