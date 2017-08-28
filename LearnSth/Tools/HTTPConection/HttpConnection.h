//
//  HttpConnection.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/28.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef void (^Success)(id responseData);
//typedef void (^Failure)(NSError *error);

typedef void (^Completion)(NSDictionary *data,NSError *error);


@interface HttpConnection : NSObject

+ (void)userRegisterWithParam:(NSDictionary *)param completion:(Completion)completion;
+ (void)userLoginWithParam:(NSDictionary *)param completion:(Completion)completion;

+ (void)uploadImageWithName:(NSString *)name data:(NSData *)data completion:(Completion)completion;

@end
