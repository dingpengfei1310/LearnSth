//
//  HttpConnection.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/28.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "HttpConnection.h"
#import "CustomiseTool.h"
#import "UserManager.h"

//static NSString *HttpUrl = @"https://api.bmob.cn/1/";
//static NSString *FileUrl = @"https://api.bmob.cn/2/";
//
//static NSString *App_Id = @"0be470c9a422cb420388bd703898ee16";
//static NSString *App_Key = @"70331dfe7b1a72c57dfcba0dff017b12";

static NSString *HttpUrl = @"https://api.leancloud.cn/1.1/";
static NSString *FileUrl = @"https://api.leancloud.cn/1.1/";

static NSString *App_Id = @"OWeFHFMxQw86Jivizz0B6jcE-gzGzoHsz";
static NSString *App_Key = @"064JmjwmQF0tcLaF7BBPJWxL";

static NSString *App_Id_Filed = @"X-LC-Id";
static NSString *App_Key_Field = @"X-LC-Key";

@interface HttpConnection ()

@property (nonatomic, strong) NSURLSession *URLSession;

@end

@implementation HttpConnection

+ (instancetype)defaultConnection {
    static HttpConnection *connection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connection = [[HttpConnection alloc] init];
    });
    
    return connection;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _URLSession = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}

- (NSMutableURLRequest *)mutableRequestWithUrl:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    [requestM setValue:App_Id forHTTPHeaderField:App_Id_Filed];
    [requestM setValue:App_Key forHTTPHeaderField:App_Key_Field];
    [requestM setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([CustomiseTool loginToken]) {
        [requestM setValue:[CustomiseTool loginToken] forHTTPHeaderField:@"X-LC-Session"];
    }
    return requestM;
}

- (void)getDataWithString:(NSString *)URLString
                    param:(NSDictionary *)param
               completion:(Completion)completion {
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@",HttpUrl,URLString,[self stringWithDictionary:param]];
    NSMutableURLRequest *requestM = [self mutableRequestWithUrl:urlString];
    
    NSURLSessionDataTask *task = [_URLSession dataTaskWithRequest:requestM completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                completion(nil,error);
            } else {
                NSError *jsonError;
                NSDictionary *dataInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                
                if (dataInfo) {
                    completion(dataInfo,nil);
                } else {
                    completion(nil,jsonError);
                }
            }
        });
        
    }];
    [task resume];
}

- (void)postDataWithString:(NSString *)URLString
                  param:(NSDictionary *)param
                completion:(Completion)completion {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HttpUrl,URLString];
    
    NSMutableURLRequest *requestM = [self mutableRequestWithUrl:urlString];
    requestM.HTTPMethod = @"POST";
    if (param) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
        requestM.HTTPBody = data;
    }
    
    NSURLSessionDataTask *task = [_URLSession dataTaskWithRequest:requestM completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                completion(nil,error);
            } else {
                NSError *jsonError;
                NSDictionary *dataInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                
                if (dataInfo) {
                    completion(dataInfo,nil);
                } else {
                    completion(nil,jsonError);
                }
            }
        });
        
    }];
    [task resume];
}

- (void)putDataWithString:(NSString *)URLString
                     param:(NSDictionary *)param
                completion:(Completion)completion {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HttpUrl,URLString];
    
    NSMutableURLRequest *requestM = [self mutableRequestWithUrl:urlString];
    requestM.HTTPMethod = @"PUT";
    if (param) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
        requestM.HTTPBody = data;
    }
    
    NSURLSessionDataTask *task = [_URLSession dataTaskWithRequest:requestM completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                completion(nil,error);
            } else {
                NSError *jsonError;
                NSDictionary *dataInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                
                if (dataInfo) {
                    completion(dataInfo,nil);
                } else {
                    completion(nil,jsonError);
                }
            }
        });
        
    }];
    [task resume];
}

#pragma mark -
- (void)userGetSMSCodeWithParam:(NSDictionary *)param completion:(Completion)completion {
    [self postDataWithString:@"requestSmsCode" param:param completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else {
            completion(data,nil);
        }
    }];
}

- (void)userLoginWithSMSCode:(NSDictionary *)param completion:(Completion)completion {
    [self postDataWithString:@"usersByMobilePhone" param:param completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else if (data[@"code"]) {
            NSString *message = @"验证码错误";
            NSInteger code = 0;
            NSDictionary *info = @{@"message":message};
            
            NSError *jsonError = [NSError errorWithDomain:message code:code userInfo:info];
            completion(nil,jsonError);
        } else {
            completion(data,nil);
        }
    }];
}

- (void)userLoginWithTokenCompletion:(Completion)completion {
    [self getDataWithString:@"users/me" param:nil completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else if (data[@"code"]) {
            NSString *message = @"Token错误";
            NSInteger code = [data[@"code"] integerValue];
            NSDictionary *info = @{@"message":message};
            
            NSError *jsonError = [NSError errorWithDomain:message code:code userInfo:info];
            completion(nil,jsonError);
        } else {
            completion(data,nil);
        }
    }];
}
- (void)userResetTokenCompletion:(Completion)completion {
    NSString *urlString = [NSString stringWithFormat:@"users/%@/refreshSessionToken",[UserManager shareManager].objectId];
    [self putDataWithString:urlString param:nil completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else if (data[@"code"]) {
            NSString *message = @"重置Token错误";
            NSInteger code = [data[@"code"] integerValue];
            NSDictionary *info = @{@"message":message};
            
            NSError *jsonError = [NSError errorWithDomain:message code:code userInfo:info];
            completion(nil,jsonError);
        } else {
            completion(data,nil);
        }
    }];
}

- (void)userFindPasswordWithParam:(NSDictionary *)param Completion:(Completion)completion {
    NSString *urlString = [NSString stringWithFormat:@"resetPasswordBySmsCode/%@",param[@"code"]];
//    NSDictionary *par = @{}:
    
    [self putDataWithString:urlString param:param completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else {
            completion(data,nil);
        }
    }];
}

#pragma mark
- (void)userRegisterWithParam:(NSDictionary *)param completion:(Completion)completion {
    [self postDataWithString:@"users" param:param completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else if (data[@"code"]) {
            NSString *message = @"注册失败";
            NSInteger code = 0;
            NSDictionary *info = @{@"message":message};
            
            NSError *jsonError = [NSError errorWithDomain:message code:code userInfo:info];
            
            if ([data[@"code"] integerValue] == 202) {
                NSString *message = @"手机号已被注册";
                NSInteger code = 0;
                NSDictionary *info = @{@"message":message};
                
                jsonError = [NSError errorWithDomain:message code:code userInfo:info];
                completion(nil,jsonError);
            } else {
                completion(nil,jsonError);
            }
        } else {
            completion(data,nil);
        }
    }];
}

- (void)userLoginWithParam:(NSDictionary *)param completion:(Completion)completion {
    [self getDataWithString:@"login" param:param completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else if (data[@"code"]) {
            NSString *message = @"用户名或密码错误";
            NSInteger code = 0;
            NSDictionary *info = @{@"message":message};
            
            NSError *jsonError = [NSError errorWithDomain:message code:code userInfo:info];
            completion(nil,jsonError);
            
        } else {
            completion(data,nil);
        }
    }];
}

- (void)userUpdate:(NSString *)objectId WithParam:(NSDictionary *)param completion:(Completion)completion {
    NSString *urlS = [NSString stringWithFormat:@"users/%@",objectId];
    [self putDataWithString:urlS param:param completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else {
            if (data[@"error"]) {
                completion(nil,error);
            } else {
                completion(data,nil);
            }
        }
    }];
}

#pragma mark -  上传图片
- (void)uploadImageWithName:(NSString *)name data:(NSData *)data completion:(Completion)completion; {
    NSString *urlString = [NSString stringWithFormat:@"%@files/%@",FileUrl,name];
    
    NSMutableURLRequest *requestM = [self mutableRequestWithUrl:urlString];
    requestM.HTTPMethod = @"POST";
    [requestM setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
//    [requestM setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];//图片格式
    
    NSURLSessionDataTask *task = [_URLSession uploadTaskWithRequest:requestM fromData:data completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,error);
            });
            
        } else {
            NSError *jsonError;
            NSDictionary *dataInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            if (!jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(dataInfo,nil);
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,jsonError);
                });
                
            }
        }
    }];
    [task resume];
}

- (void)operationTestCompletion:(Completion)completion {
    [self getDataWithString:@"files" param:nil completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            NSLog(@"%@",data);
        }
    }];
}

#pragma mark
- (NSString *)stringWithDictionary:(NSDictionary *)dict {
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (NSString *key in dict.allKeys) {
        NSString *keyAndValue = [NSString stringWithFormat:@"%@=%@",key,dict[key]];
        [arrayM addObject:keyAndValue];
    }
    
    return [arrayM componentsJoinedByString:@"&"];
}

@end
