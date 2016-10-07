//
//  FuturesModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/7.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "FuturesModel.h"

#import "SQLManager.h"

#import <objc/runtime.h>

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

+ (void)checkFutureTable {
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
         "createDate varchar(20),"
         "currencyName varchar(64),"
         "exchangeName varchar(64),"
         "updateBy varchar(64),"
         "createBy varchar(64),"
         "PRIMARY KEY (exchangeNo,code)"
         ");"];
    }];
}

#pragma mark

+ (void)saveFuturesWithFuturesModel:(FuturesModel *)futuresModel {
    [self checkFutureTable];
    
    FMDatabaseQueue *dbQueue = [[SQLManager manager] dbQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"delete from futures_table where exchangeNo = '%@' and code= '%@' ;", futuresModel.exchangeNo,futuresModel.code];
        [db executeUpdate:sql];
        
        BOOL flag = [db executeUpdate:@"insert into futures_table ("
                     "exchangeNo,commodityNo,commodityName,code,contractNo,"
                     "contractName,futuresType,productDot,upperTick,regDate,"
                     "expiryDate,dotNum,currencyNo,lowerTick,exchangeNo2,"
                     "deposit,depositPercent,firstNoticeDay,updateDate,commodityType,"
                     "pyName"
                     ") values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);",futuresModel.exchangeNo,futuresModel.commodityNo,futuresModel.commodityName,futuresModel.code,futuresModel.contractNo,futuresModel.contractName,futuresModel.futuresType,futuresModel.productDot,futuresModel.upperTick,futuresModel.regDate,futuresModel.expiryDate,futuresModel.dotNum,futuresModel.currencyNo,futuresModel.lowerTick,futuresModel.exchangeNo2,futuresModel.deposit,futuresModel.depositPercent,futuresModel.firstNoticeDay,futuresModel.updateDate,futuresModel.commodityType,futuresModel.pyName];
        
        if (!flag) {
            NSLog(@"failure:%@ -- %@",futuresModel.exchangeNo,futuresModel.code);
        }
    }];
    
}

+ (void)saveFuturesWithFuturesModelArray:(NSArray<FuturesModel *> *)futuresModelArray {
    for (FuturesModel *model in futuresModelArray) {
        [self saveFuturesWithFuturesModel:model];
    }
}

+ (NSArray<FuturesModel *> *)queryFuturesWithPage:(NSInteger)page size:(NSInteger)size {
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    
    NSString *sqlString = [NSString stringWithFormat:@"select * from futures_table;"];
    if (page > 0 && size > 0) {
        sqlString = [NSString stringWithFormat:@"select * from futures_table limit %ld offset %ld;",(long)size,(page - 1) * size];
    }
    FMDatabaseQueue *dbQueue = [[SQLManager manager] dbQueue];
    
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlString];
        
        if (result) {
            while ([result next]) {
                FuturesModel *futuresModel = [[FuturesModel alloc] init];
                
                unsigned int outCount;
                objc_property_t *propertities = class_copyPropertyList([FuturesModel class], &outCount);
                for (int i = 0; i < outCount; i++) {
                    objc_property_t property = propertities[i];
                    NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
                    
                    [futuresModel setValue:[result stringForColumn:propertyName] forKey:propertyName];
                }
                
                [modelArray addObject:futuresModel];
            }
        }
        
    }];
    
    return modelArray;
}


@end
