//
//  HttpConnection.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/28.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "HttpConnection.h"
#import "CustomiseTool.h"

static NSString *HttpUrl = @"https://api.bmob.cn/1/";
static NSString *FileUrl = @"https://api.bmob.cn/2/";

static NSString *App_Id = @"0be470c9a422cb420388bd703898ee16";
static NSString *App_Key = @"70331dfe7b1a72c57dfcba0dff017b12";

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
    [requestM setValue:App_Id forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [requestM setValue:App_Key forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    return requestM;
}

- (void)getDataWithString:(NSString *)URLString
                    param:(NSDictionary *)param
               completion:(Completion)completion {
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@",HttpUrl,URLString,[self stringWithDictionary:param]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    [requestM setValue:App_Id forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [requestM setValue:App_Key forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    
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
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    requestM.HTTPMethod = @"POST";
    requestM.HTTPBody = data;
    [requestM setValue:App_Id forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [requestM setValue:App_Key forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    [requestM setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
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
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    requestM.HTTPMethod = @"PUT";
    requestM.HTTPBody = data;
    [requestM setValue:App_Id forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [requestM setValue:App_Key forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    [requestM setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([CustomiseTool isLogin]) {
        [requestM setValue:[CustomiseTool loginToken] forHTTPHeaderField:@"X-Bmob-Session-Token"];
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
- (void)userRegisterWithParam:(NSDictionary *)param completion:(Completion)completion {
    [self postDataWithString:@"users" param:param completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else {
            if ([data[@"code"] integerValue] == 202) {
                NSString *message = @"手机号已被注册";
                NSInteger code = 0;
                NSDictionary *info = @{@"message":message};
                
                NSError *jsonError = [NSError errorWithDomain:message code:code userInfo:info];
                completion(nil,jsonError);
            } else {
                completion(data,nil);
            }
        }
    }];
}

- (void)userLoginWithParam:(NSDictionary *)param completion:(Completion)completion {
    [self getDataWithString:@"login" param:param completion:^(NSDictionary *data, NSError *error) {
        if (error) {
            completion(nil,error);
        } else {
            if ([data[@"code"] integerValue] == 101) {
                NSString *message = @"用户名或密码错误";
                NSInteger code = 0;
                NSDictionary *info = @{@"message":message};
                
                NSError *jsonError = [NSError errorWithDomain:message code:code userInfo:info];
                completion(nil,jsonError);
            } else {
                completion(data,nil);
            }
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

#pragma mark
- (void)uploadImageWithName:(NSString *)name data:(NSData *)data completion:(Completion)completion; {
    NSString *urlString = [NSString stringWithFormat:@"%@files/8_28.png",FileUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    requestM.HTTPMethod = @"POST";
    [requestM setValue:App_Id forHTTPHeaderField:@"X-Bmob-Application-Id"];
    [requestM setValue:App_Key forHTTPHeaderField:@"X-Bmob-REST-API-Key"];
    [requestM setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    
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
