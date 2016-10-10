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


@interface HttpRequestManager : NSObject

+ (instancetype)shareManager;

- (void)getStockDataWithParamer:(NSDictionary *)paramer success:(Success)success failure:(Failure)failure;

- (void)getFutureDataWithParamer:(NSDictionary *)paramer success:(Success)success failure:(Failure)failure;

///直播
- (void)getHotLiveListWithParamer:(NSDictionary *)paramer success:(Success)success failure:(Failure)failure;

@end
