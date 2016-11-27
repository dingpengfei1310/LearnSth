//
//  SQLManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/6.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "SQLManager.h"

#import "FMDB.h"

@interface SQLManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

//@property (nonatomic, copy) NSString *dbPath;

@end

@implementation SQLManager

+ (instancetype)manager {
    static SQLManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQLManager alloc] init];
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
//    NSLog(@"%@",document);
//    NSString *path = [document stringByAppendingPathComponent:@"temp.db"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"province.db" ofType:nil];
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
}

- (FMDatabaseQueue *)dbQueue {
    return _dbQueue;
}

#pragma mark
- (NSArray *)getProvinces {
    NSMutableArray *mutArray = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"select * from t_address where parent_id = '0'";
        
        FMResultSet *result = [db executeQuery:sql];
        while (result.next) {
            NSString *provinceId = [result stringForColumn:@"id"];
            NSString *provinceName = [result stringForColumn:@"name"];
            NSString *parentId = [result stringForColumn:@"parent_id"];
            NSDictionary *province = @{@"id":provinceId,
                                       @"name":provinceName,
                                       @"parent_id":parentId};
            
            [mutArray addObject:province];
        }
        
    }];
    
    return [NSArray arrayWithArray:mutArray];
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



@end
