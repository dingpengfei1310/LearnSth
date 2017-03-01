//
//  HttpManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HttpManager.h"

#import "AFNetworking.h"
#import "SQLManager.h"

const NSInteger errorCodeDefault = 999;
const NSTimeInterval timeoutInterval = 20.0;

@implementation HttpManager

+ (instancetype)shareManager {
    static HttpManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HttpManager alloc] init];
    });
    
    return manager;
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
    
    [manager GET:urlString
      parameters:paramets
        progress:^(NSProgress * _Nonnull uploadProgress) {}
         success:^(NSURLSessionDataTask *task, id responseObject) {
             success(responseObject);
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             failure(error);
         }];
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
        NSArray *array = [responseData objectForKey:@"data"];
        completion(array,nil);
        
    } failure:^(NSError *error) {
        completion(nil,error);
    }];
}

- (void)getHotLiveListWithParamers:(NSDictionary *)paramers
                        completion:(SuccessArray)completion {
//    NSString * urlString = @"http://live.9158.com/Fans/GetHotLive";
    NSString * urlString = @"https://live.9158.com/Fans/GetHotLive";
    [self getDataWithString:urlString paramets:paramers success:^(id responseData) {
        
        NSArray *array = [[responseData objectForKey:@"data"] objectForKey:@"list"];
        completion(array,nil);
    } failure:^(NSError *error) {
        
        completion(nil,error);
    }];
}

- (void)getUserListWithParamers:(NSDictionary *)paramers
                     completion:(SuccessArray)completion {
    
    NSString *BASEURl = @"http://192.168.1.212:8080/sctd/";
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BASEURl,@"operate/scgroup/getrank"];
    
    NSDictionary *dict = @{@"pageno":@"1",@"size":@"20",@"groupName":@""};
    NSString *jsonString = [self jsonModel:dict];
    NSDictionary *params = @{@"jsonText": jsonString};
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:urlString parameters:params progress:^(NSProgress * uploadProgress) {
    } success:^(NSURLSessionDataTask * task, id  _Nullable responseObject) {
        
        if ([responseObject[@"result"] integerValue] == 1) {
            NSArray *userArray = [responseObject objectForKey:@"data"];
            completion(userArray,nil);
        } else {
            NSString *message = [responseObject objectForKey:@"resp"];
            NSDictionary *info = @{@"message":message};
            NSError *error = [NSError errorWithDomain:@"getrank" code:errorCodeDefault userInfo:info];
            
            completion(nil,error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * error) {
        completion(nil,error);
    }];
}


#pragma mark
- (NSString *)jsonModel:(NSDictionary *)dictModel {
    if ([NSJSONSerialization isValidJSONObject:dictModel]) {
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictModel
                                                            options:NSJSONWritingPrettyPrinted error:nil];
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData
                                                   encoding:NSUTF8StringEncoding];
        return jsonStr;
    }
    return nil;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    NSDictionary *dict;
    if (jsonString) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
    }
    
    return dict;
}

@end




