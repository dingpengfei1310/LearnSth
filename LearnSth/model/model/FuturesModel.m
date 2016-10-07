//
//  FuturesModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/7.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "FuturesModel.h"

#import "SQLManager.h"

@implementation FuturesModel

+ (NSArray<FuturesModel *> *)futureWithArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        FuturesModel *futuresModel = [[FuturesModel alloc] init];
        [futuresModel setValuesForKeysWithDictionary:dict];
        [tempArray addObject:futuresModel];
    }
    
    return [NSArray arrayWithArray:tempArray];
}

- (void)checkFutureTable {
    FMDatabaseQueue *dbQueue = [[SQLManager manager] dbQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"create table if not exists futures_table ("
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
    }];
}

#pragma mark

- (void)saveFuturesWithFuturesModel:(FuturesModel *)futuresModel {
    [self checkFutureTable];
    
    FMDatabaseQueue *dbQueue = [[SQLManager manager] dbQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from futures_table where exchangeNo = '%@' and code= '%@' ;", futuresModel.exchangeNo,futuresModel.code];
        [db executeUpdate:sql];
        
        BOOL flag = [db executeUpdate:@"insert into futures_table (exchangeNo,commodityNo,commodityName,code,contractNo,contractName,futuresType,productDot,upperTick,regDate,expiryDate,dotNum,currencyNo,lowerTick,exchangeNo2,deposit,depositPercent,firstNoticeDay,updateDate,commodityType,pyName) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",futuresModel.exchangeNo,futuresModel.commodityNo,futuresModel.commodityName,futuresModel.code,futuresModel.contractNo,futuresModel.contractName,futuresModel.futuresType,futuresModel.productDot,futuresModel.upperTick,futuresModel.regDate,futuresModel.expiryDate,futuresModel.dotNum,futuresModel.currencyNo,futuresModel.lowerTick,futuresModel.exchangeNo2,futuresModel.deposit,futuresModel.depositPercent,futuresModel.firstNoticeDay,futuresModel.updateDate,futuresModel.commodityType,futuresModel.pyName];
        
        if (!flag) {
            NSLog(@"failure:%@ -- %@",futuresModel.exchangeNo,futuresModel.code);
        }
    }];
    
}

- (void)saveFuturesWithFuturesModelArray:(NSArray<FuturesModel *> *)futuresModelArray {
    for (FuturesModel *model in futuresModelArray) {
        [self saveFuturesWithFuturesModel:model];
    }
}

- (NSArray<FuturesModel *> *)queryFuturesWithPage:(NSInteger)page size:(NSInteger)size {
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    
    //    limit 10 offset 0
    
    NSString *sqlString = [NSString stringWithFormat:@"select * from futures_table;"];
    if (page > 0 && size > 0) {
        sqlString = [NSString stringWithFormat:@"select * from futures_table limit %ld offset %ld;",(long)size,page * size];
    }
    FMDatabaseQueue *dbQueue = [[SQLManager manager] dbQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlString];
        
        if (result) {
            while ([result next]) {
                FuturesModel *futuresModel = [[FuturesModel alloc] init];
                futuresModel.exchangeNo = [result stringForColumn:@"exchangeNo"];
                futuresModel.code = [result stringForColumn:@"code"];
                futuresModel.contractNo = [result stringForColumn:@"contractNo"];
                futuresModel.contractName = [result stringForColumn:@"contractName"];
                futuresModel.productDot = [result stringForColumn:@"productDot"];
                futuresModel.upperTick = [result stringForColumn:@"upperTick"];
                futuresModel.expiryDate = [result stringForColumn:@"expiryDate"];
                futuresModel.dotNum = [result stringForColumn:@"dotNum"];
                futuresModel.currencyNo = [result stringForColumn:@"currencyNo"];
                futuresModel.lowerTick = [result stringForColumn:@"lowerTick"];
                futuresModel.deposit = [result stringForColumn:@"deposit"];
                futuresModel.depositPercent = [result stringForColumn:@"depositPercent"];
                futuresModel.commodityType = [result stringForColumn:@"commodityType"];
                
                [modelArray addObject:futuresModel];
            }
        }
        
    }];
    
    return modelArray;
}


@end
