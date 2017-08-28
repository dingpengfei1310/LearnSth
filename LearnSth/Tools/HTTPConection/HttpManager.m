//
//  HttpManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "HttpManager.h"
#import <AFNetworking.h>

const NSTimeInterval timeoutInterval = 10.0;

static NSString *HttpUrl = @"https://api.leancloud.cn/1.1/";
static NSString *App_Id = @"OWeFHFMxQw86Jivizz0B6jcE-gzGzoHsz";
static NSString *App_Key = @"064JmjwmQF0tcLaF7BBPJWxL";

@interface HttpManager ()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

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

- (instancetype)init {
    if (self = [super init]) {
        _sessionManager = [AFHTTPSessionManager manager];
        
        NSMutableSet *multSet = [NSMutableSet setWithSet:_sessionManager.responseSerializer.acceptableContentTypes];
        [multSet addObject:@"text/html"];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithSet:multSet];
        _sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
        
        [_sessionManager.requestSerializer setValue:App_Id forHTTPHeaderField:@"X-LC-Id"];
        [_sessionManager.requestSerializer setValue:App_Key forHTTPHeaderField:@"X-LC-Key"];
    }
    return self;
}

#pragma mark
- (void)cancelAllRequest {
    [self.sessionManager.dataTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask * obj, NSUInteger idx, BOOL * stop) {
        if (obj.state != NSURLSessionTaskStateCompleted) {
            [obj cancel];
        }
    }];
}

- (void)getDataWithString:(NSString *)urlString
                 paramets:(NSDictionary *)paramets
                  success:(Success)success
                  failure:(Failure)failure {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (![urlString hasPrefix:@"http"]) {
        urlString = [NSString stringWithFormat:@"%@%@",HttpUrl,urlString];
    }
    
    [self.sessionManager GET:urlString
                  parameters:paramets
                    progress:^(NSProgress * uploadProgress) {}
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         success(responseObject);
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                         if ([error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"已取消"]) {
                             NSDictionary *info = @{@"message":@"您已取消"};
                             NSError *error = [NSError errorWithDomain:@"用户取消" code:HttpErrorCodeCancel userInfo:info];
                             failure(error);
                         } else {
                             failure(error);
                         }
                     }];
}

- (void)postDataWithString:(NSString *)urlString
                 paramets:(NSDictionary *)paramets
                  success:(Success)success
                  failure:(Failure)failure {
    
    [self.sessionManager POST:urlString
                   parameters:paramets
                     progress:^(NSProgress * _Nonnull uploadProgress) {}
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          success(responseObject);
                      }
                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                          failure(error);
                      }];
}

- (NSError *)errorWithResponse:(NSDictionary *)dict {
    //    NSString *message = [dict objectForKey:@"msg"];
    //    NSInteger code = [[dict objectForKey:@"code"] integerValue];
    //    message = message ?: @"网络错误";
    //    code = code ?: HttpErrorCodeDefault;
    //    NSDictionary *info = @{@"message":message};
    
    NSString *message = @"暂无数据";
    NSInteger code = HttpErrorCodeNodata;
    NSDictionary *info = @{@"message":message};
    
    return [NSError errorWithDomain:message code:code userInfo:info];
}

#pragma mark
- (void)getAdBannerListCompletion:(CompletionArray)completion {
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

- (void)getHotLiveListWithParam:(NSDictionary *)paramers completion:(CompletionArray)completion {
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

#pragma mark
- (void)getPDF {
//    NSURL *url = [NSURL URLWithString:@"http://192.168.1.203:6080/zdkh/show/futuresoption.pdf"];
//    NSURL *url = [NSURL URLWithString:@"http://192.168.1.203:6080/zdkh/show/optionstate.pdf"];
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.203:6080/zdkh/show/security.pdf"];
    
    NSURLSessionDownloadTask *dd = [self.sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:url] progress:^(NSProgress * downloadProgress) {
        NSLog(@"downloadProgress");
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *ss = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
        return [NSURL fileURLWithPath:[ss stringByAppendingPathComponent:@"p.pdf"]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"completionHandler");
    }];
    [dd resume];
}

- (void)getLoacalTestDataCompletion:(CompletionArray)completion {
    NSString *localIP = @"http://192.168.1.146:80/test.json";
    [self getDataWithString:localIP paramets:nil success:^(id responseData) {
        completion(responseData[@"data"],nil);
    } failure:^(NSError *error) {
//        NSLog(@"%@",error);
    }];
}

#pragma mark
- (void)userRegisterWithParam:(NSDictionary *)param completion:(Completion)completion {
    [self postDataWithString:@"users" paramets:param success:^(id responseData) {
        completion(responseData,nil);
    } failure:^(NSError *error) {
        completion(nil,error);
    }];
    
//    NSString *url = [NSString stringWithFormat:@"%@users",HttpUrl];
//    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//    requestM.HTTPMethod = @"POST";
//    
//    [requestM setValue:App_Id forHTTPHeaderField:@"X-LC-Id"];
//    [requestM setValue:App_Key forHTTPHeaderField:@"X-LC-Key"];
//    [requestM setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
//    
//    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
//    [requestM setHTTPBody:data];
//    
//    NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:requestM completionHandler:^(NSURLResponse * response, id responseObject, NSError * error) {
////        NSString *ss = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",responseObject);
//    }];
//    [task resume];
    
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
//    
//    NSString *url = [NSString stringWithFormat:@"%@users",HttpUrl];
//    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//    requestM.HTTPMethod = @"POST";
//    
//    [requestM setValue:App_Id forHTTPHeaderField:@"X-LC-Id"];
//    [requestM setValue:App_Key forHTTPHeaderField:@"X-LC-Key"];
//    
////    @"username":@"15381026458",@"password":@"123456"
////    NSData *data = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
////    NSData *data = [@"username=15381026458&password=123456" dataUsingEncoding:NSUTF8StringEncoding];
////    [requestM setHTTPBody:data];
//    
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:requestM completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
//        NSString *ss = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",ss);
//    }];
//    [task resume];
    
}

- (void)userLoginWithParam:(NSDictionary *)param completion:(Completion)completion {
    [self getDataWithString:@"login" paramets:param success:^(id responseData) {
        completion(responseData,nil);
    } failure:^(NSError *error) {
        completion(nil,error);
    }];
}

- (void)uploadImage:(NSData *)data {
//    NSString *urlString = [NSString stringWithFormat:@"%@files/8_28.png",HttpUrl];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSMutableURLRequest *requestM = [self mutableURLRequest];
//    requestM.URL = url;
//    [requestM setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
//    //    [requestM setValue:data forKey:@"--data-binary"];
//    
//    NSURLSession *session = [self session];
//    //    NSURLSessionDataTask *task = [session dataTaskWithRequest:requestM completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
//    //        if (error) {
//    //            NSLog(@"%@",error);
//    //        } else {
//    //            NSError *jsonError;
//    //            NSDictionary *dataInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
//    //            NSLog(@"%@",dataInfo);
//    //        }
//    //
//    //    }];
//    //    [task resume];
//    
//    NSURLSessionDataTask *task = [session uploadTaskWithRequest:requestM fromData:data completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
//        if (error) {
//            NSLog(@"%@",error);
//        } else {
//            NSError *jsonError;
//            NSDictionary *dataInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
//            NSLog(@"%@",dataInfo);
//        }
//    }];
//    [task resume];
//    
//    
//    
//    
//    [self.sessionManager uploadTaskWithRequest:<#(nonnull NSURLRequest *)#> fromData:<#(nullable NSData *)#> progress:<#^(NSProgress * _Nonnull uploadProgress)uploadProgressBlock#> completionHandler:<#^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error)completionHandler#>];
}

#pragma mark
- (NSString *)jsonStringWithDictionary:(NSDictionary *)dictModel {
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

@end
