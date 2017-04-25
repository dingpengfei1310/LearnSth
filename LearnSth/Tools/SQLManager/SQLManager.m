//
//  SQLManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/6.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "SQLManager.h"

#import <FMDatabase.h>
#import <FMDatabaseQueue.h>

@interface SQLManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

static SQLManager *manager = nil;

@implementation SQLManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQLManager alloc] init];
    });
    
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
//    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *path = [document stringByAppendingPathComponent:@"temp.db"];
    
    NSString *resouncePath = [[NSBundle mainBundle] pathForResource:@"province.db" ofType:nil];
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:resouncePath];
}

- (FMDatabaseQueue *)dbQueue {
    return _dbQueue;
}

#pragma mark
- (NSArray *)getProvinces {
    return [self getCitiesWithProvinceId:@"0"];
}

- (NSArray *)getCitiesWithProvinceId:(NSString *)provinceId {
    NSMutableArray *mutArray = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from t_address where parent_id = '%@'",provinceId];
        
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSString *cityId = [result stringForColumn:@"id"];
            NSString *cityName = [result stringForColumn:@"name"];
            NSString *parentId = [result stringForColumn:@"parent_id"];
            NSDictionary *province = @{@"id":cityId,
                                       @"name":cityName,
                                       @"parent_id":parentId};
            
            [mutArray addObject:province];
        }
    }];
    
    return [NSArray arrayWithArray:mutArray];
}

- (NSArray *)searchResultWith:(NSString *)text {
    NSMutableArray *mutArray = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from t_address where name like '%%%@%%'",text];
        
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSString *cityId = [result stringForColumn:@"id"];
            NSString *cityName = [result stringForColumn:@"name"];
            NSString *parentId = [result stringForColumn:@"parent_id"];
            NSDictionary *province = @{@"id":cityId,
                                       @"name":cityName,
                                       @"parent_id":parentId};
            
            [mutArray addObject:province];
        }
    }];
//    select * from t_address t1 left join t_address t2 on t1.id = t2.parent_id ;
    return [NSArray arrayWithArray:mutArray];
}

@end
