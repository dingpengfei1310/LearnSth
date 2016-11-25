//
//  FuturesModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/7.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FuturesModel : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *commodityName;
@property (nonatomic, copy) NSString *commodityNo;
@property (nonatomic, copy) NSString *commodityType;
@property (nonatomic, copy) NSString *contractName;
@property (nonatomic, copy) NSString *contractNo;
@property (nonatomic, copy) NSString *createBy;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, copy) NSString *currencyName;
@property (nonatomic, copy) NSString *currencyNo;
@property (nonatomic, copy) NSString *deposit;
@property (nonatomic, copy) NSString *depositPercent;
@property (nonatomic, copy) NSString *dotNum;
@property (nonatomic, copy) NSString *exchangeName;
@property (nonatomic, copy) NSString *exchangeNo;
@property (nonatomic, copy) NSString *exchangeNo2;
@property (nonatomic, copy) NSString *expiryDate;
@property (nonatomic, copy) NSString *firstNoticeDay;
@property (nonatomic, copy) NSString *futuresType;
@property (nonatomic, copy) NSString *lowerTick;
@property (nonatomic, copy) NSString *productDot;
@property (nonatomic, copy) NSString *pyName;
@property (nonatomic, copy) NSString *regDate;
@property (nonatomic, copy) NSString *updateBy;
@property (nonatomic, copy) NSString *updateDate;
@property (nonatomic, copy) NSString *upperTick;

#pragma mark 方法

+ (NSArray<FuturesModel *> *)futureWithArray:(NSArray *)array;

+ (void)saveFuturesWithFuturesModel:(FuturesModel *)futuresModel;
+ (void)saveFuturesWithFuturesModelArray:(NSArray<FuturesModel *> *)futuresModelArray;

+ (NSArray<FuturesModel *> *)queryFuturesWithPage:(NSInteger)page size:(NSInteger)size;


@end





