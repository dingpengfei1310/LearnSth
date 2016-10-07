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

@property (nonatomic, copy) NSString *dbPath;

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

- (FMDatabaseQueue *)dbQueue {
    return _dbQueue;
}

- (void)initialize {
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@",document);
    NSString *path = [document stringByAppendingPathComponent:@"temp.db"];
    
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
}



@end
