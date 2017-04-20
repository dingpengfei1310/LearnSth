//
//  HttpManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HttpManager.h"
#import "AFNetworking.h"

const NSInteger errorCodeDefault = 99999;
const NSTimeInterval timeoutInterval = 15.0;

@interface HttpManager ()

@property (strong, nonatomic) NSMutableArray *currentTasks;

@end

@implementation HttpManager
+ (instancetype)shareManager {
    static HttpManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpManager alloc] init];
    });
    return manager;
}

- (void)cancelAllRequest {
    [self.currentTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask * obj, NSUInteger idx, BOOL * stop) {
        if (obj.state != NSURLSessionTaskStateCompleted) {
            [obj cancel];
        }
    }];
    [self.currentTasks removeAllObjects];
}

- (void)cancelRequestWithUrl:(NSURL *)url {
    [self.currentTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask * obj, NSUInteger idx, BOOL * stop) {
        BOOL isCurrentUrl = [obj.currentRequest.URL.absoluteString isEqualToString:url.absoluteString];
        if (isCurrentUrl && obj.state != NSURLSessionTaskStateCompleted) {
            [obj cancel];
            [self.currentTasks removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
}

- (void)getDataWithString:(NSString *)urlString
                 paramets:(NSDictionary *)paramets
                  success:(Success)success
                  failure:(Failure)failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableSet *multSet = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [multSet addObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:multSet];
    manager.requestSerializer.timeoutInterval = timeoutInterval;
    
    NSURLSessionDataTask *task;
    task = [manager GET:urlString
             parameters:paramets
               progress:^(NSProgress * uploadProgress) {}
                success:^(NSURLSessionDataTask *task, id responseObject) {
                    [self.currentTasks removeObject:task];
                    success(responseObject);
                }
                failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [self.currentTasks removeObject:task];
                    if ([error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"已取消"]) {
                        NSDictionary *info = @{@"message":@"您已取消"};
                        NSError *error = [NSError errorWithDomain:@"用户取消"
                                                             code:errorCodeDefault
                                                         userInfo:info];
                        failure(error);
                    } else {
                        failure(error);
                    }
                }];
    
    [self.currentTasks addObject:task];
}

- (void)postDataWithString:(NSString *)urlString
                 paramets:(NSDictionary *)paramets
                  success:(Success)success
                  failure:(Failure)failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableSet *multSet = [NSMutableSet setWithSet:manager.responseSerializer.acceptableContentTypes];
    [multSet addObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:multSet];
    manager.requestSerializer.timeoutInterval = timeoutInterval;
    
    [manager POST:urlString
      parameters:paramets
        progress:^(NSProgress * _Nonnull uploadProgress) {}
         success:^(NSURLSessionDataTask *task, id responseObject) {
             success(responseObject);
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             failure(error);
         }];
}

#pragma mark
- (void)getAdBannerListCompletion:(SuccessArray)completion {
    NSString * urlString = @"https://live.9158.com/Living/GetAD";
    [self getDataWithString:urlString paramets:nil success:^(id responseData) {
        //code,data,msg
        NSArray *array = [responseData objectForKey:@"data"];
        if (array.count == 0) {
            NSError *error = [self errorWithResponse:responseData];
            completion(nil,error);
        } else {
            completion(array,nil);
        }
        
    } failure:^(NSError *error) {
        completion(nil,error);
    }];
}

- (void)getHotLiveListWithParamers:(NSDictionary *)paramers
                        completion:(SuccessArray)completion {
    NSString * urlString = @"https://live.9158.com/Fans/GetHotLive";
    [self getDataWithString:urlString paramets:paramers success:^(id responseData) {
        NSArray *array = [[responseData objectForKey:@"data"] objectForKey:@"list"];
        if (array.count == 0) {
            NSError *error = [self errorWithResponse:responseData];
            completion(nil,error);
        } else {
            completion(array,nil);
        }
        
    } failure:^(NSError *error) {
        completion(nil,error);
    }];
}

- (NSError *)errorWithResponse:(NSDictionary *)dict {
    NSString *message = [dict objectForKey:@"msg"];
    NSInteger code = [[dict objectForKey:@"code"] integerValue];
    message = message ?: @"网络错误";
    code = code ?: errorCodeDefault;
    NSDictionary *info = @{@"message":message};
    NSError *error = [NSError errorWithDomain:message code:code userInfo:info];
    return error;
}

#pragma mark
- (NSString *)jsonModel:(NSDictionary *)dictModel {
    if ([NSJSONSerialization isValidJSONObject:dictModel]) {
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictModel options:NSJSONWritingPrettyPrinted error:nil];
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonStr;
    }
    return @"";
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    NSDictionary *dict = [NSDictionary dictionary];
    if (jsonString) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
    }
    return dict;
}

#pragma mark
- (NSMutableArray *)currentTasks {
    if (!_currentTasks) {
        _currentTasks = [NSMutableArray array];
    }
    return _currentTasks;
}

@end
