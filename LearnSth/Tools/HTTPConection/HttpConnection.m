//
//  HttpConnection.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/28.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "HttpConnection.h"

static NSString *HttpUrl = @"https://api.leancloud.cn/1.1/";
static NSString *App_Id = @"OWeFHFMxQw86Jivizz0B6jcE-gzGzoHsz";
static NSString *App_Key = @"064JmjwmQF0tcLaF7BBPJWxL";

@interface HttpConnection ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation HttpConnection

#pragma mark -
+ (NSURLSession *)session {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    return [NSURLSession sessionWithConfiguration:configuration];
}

+ (NSMutableURLRequest *)mutableURLRequest {
    NSMutableURLRequest *requestM = [[NSMutableURLRequest alloc] init];
    [requestM setValue:App_Id forHTTPHeaderField:@"X-LC-Id"];
    [requestM setValue:App_Key forHTTPHeaderField:@"X-LC-Key"];
    
    return requestM;
}

#pragma mark -
+ (void)userRegisterWithParam:(NSDictionary *)param completion:(Completion)completion {
    NSString *urlString = [NSString stringWithFormat:@"%@users",HttpUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *requestM = [self mutableURLRequest];
    requestM.URL = url;
    requestM.HTTPMethod = @"POST";
    
    NSString *paramString = [self stringWithDictionary:param];
    NSData *data = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    [requestM setHTTPBody:data];
    
    NSURLSession *session = [self session];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requestM completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,error);
            });
        } else {
            NSError *jsonError;
            NSDictionary *dataInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (dataInfo) {
                if (dataInfo[@"error"]) {
                    NSString *message = @"用户名或密码错误";
                    NSInteger code = 0;
                    NSDictionary *info = @{@"message":message};
                    
                    jsonError = [NSError errorWithDomain:message code:code userInfo:info];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil,jsonError);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(dataInfo,nil);
                    });
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,jsonError);
                });
            }
        }
        
    }];
    [task resume];
    
}

+ (void)userLoginWithParam:(NSDictionary *)param completion:(Completion)completion {
//    NSString *urlString = [NSString stringWithFormat:@"%@login?%@",HttpUrl,[self stringWithDictionary:param]];
    NSString *urlString = [NSString stringWithFormat:@"%@stats/appinfo",HttpUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *requestM = [self mutableURLRequest];
    requestM.URL = url;
    
    NSURLSession *session = [self session];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requestM completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil,error);
            });
        } else {
            NSError *jsonError;
            NSDictionary *dataInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (dataInfo) {
                if (dataInfo[@"error"]) {
                    NSString *message = @"用户名或密码错误";
                    NSInteger code = 0;
                    NSDictionary *info = @{@"message":message};
                    
                    jsonError = [NSError errorWithDomain:message code:code userInfo:info];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil,jsonError);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(dataInfo,nil);
                    });
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil,jsonError);
                });
            }
        }
        
    }];
    [task resume];
}

+ (void)uploadImageWithName:(NSString *)name data:(NSData *)data completion:(Completion)completion; {
    NSString *urlString = [NSString stringWithFormat:@"%@files/8_28.png",HttpUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *requestM = [self mutableURLRequest];
    requestM.URL = url;
    requestM.HTTPMethod = @"POST";
    [requestM setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [self session];
    
    NSURLSessionDataTask *task = [session uploadTaskWithRequest:requestM fromData:data completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        
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
+ (NSString *)stringWithDictionary:(NSDictionary *)dict {
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (NSString *key in dict.allKeys) {
        NSString *keyAndValue = [NSString stringWithFormat:@"%@=%@",key,dict[key]];
        [arrayM addObject:keyAndValue];
    }
    
    return [arrayM componentsJoinedByString:@"&"];
}

@end
