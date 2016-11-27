//
//  SQLManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/6.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface SQLManager : NSObject

+ (instancetype)manager;

- (FMDatabaseQueue *)dbQueue;

#pragma mark
- (NSArray *)getProvinces;
- (NSArray *)getCitiesWithProvinceId:(NSString *)provinceId;

@end
