//
//  HttpConnection.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/28.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionArray)(NSArray *list,NSError *error);
typedef void (^Completion)(NSDictionary *data,NSError *error);


@interface HttpConnection : NSObject

+ (instancetype)defaultConnection;

#pragma mark
///获取验证码
- (void)userGetSMSCodeWithParam:(NSDictionary *)param completion:(Completion)completion;
///验证码登录第一次默认注册)
- (void)userLoginWithSMSCode:(NSDictionary *)param completion:(Completion)completion;
///自动登录(token)
- (void)userLoginWithTokenCompletion:(Completion)completion;
///重置Token
- (void)userResetTokenCompletion:(Completion)completion;
///找回密码(验证码找回)
- (void)userFindPasswordWithParam:(NSDictionary *)param Completion:(Completion)completion;

///注册
- (void)userRegisterWithParam:(NSDictionary *)param completion:(Completion)completion;
///登录
- (void)userLoginWithParam:(NSDictionary *)param completion:(Completion)completion;
///修改信息
- (void)userUpdate:(NSString *)objectId WithParam:(NSDictionary *)param completion:(Completion)completion;
///上传头像
- (void)uploadImageWithName:(NSString *)name data:(NSData *)data completion:(Completion)completion;
//- (void)uploadImageWithUserInfo:(NSDictionary *)info data:(NSData *)imageData completion:(Completion)completion;

@end
