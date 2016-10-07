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

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation SQLManager

+ (instancetype)manager {
    static SQLManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQLManager alloc] init];
        [self initialize];
    });
    
    return manager;
}

- (void)initialize {
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@",document);
    NSString *path = [NSString stringWithFormat:@"temp.db"];
    
    _db = [FMDatabase databaseWithPath:path];
    
    [_db executeUpdate:@"create table if not exists futures_table ("
     "exchangeNo varchar(64),"
     "commodityNo varchar(10),"
     "commodityName varchar(40),"
     "code varchar(64),"
     "contractNo varchar(50),"
     "contractName varchar(50),"
     "futuresType varchar(2),"
     "productDot varchar(20),"
     "upperTick varchar(20),"
     "regDate varchar(8),"
     "expiryDate varchar(8),"
     "dotNum varchar(11),"
     "currencyNo varchar(10),"
     "lowerTick varchar(11),"
     "exchangeNo2 varchar(10),"
     "deposit varchar(20),"
     "depositPercent varchar(20),"
     "firstNoticeDay varchar(10),"
     "updateDate varchar(20),"
     "commodityType varchar(2),"
     "pyName varchar(64),"
     "PRIMARY KEY (exchangeNo,code)"
     ");"];
    
    
}



@end
