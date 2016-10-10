//
//  TodayModel.h
//  SomeTry
//
//  Created by 丁鹏飞 on 16/9/19.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodayModel : NSObject

@property (nonatomic, copy) NSString *contractName;
@property (nonatomic, copy) NSString *createBy;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, copy) NSString *dspName;
@property (nonatomic, copy) NSString *exchangeNo;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *stockName;
@property (nonatomic, copy) NSString *stockNo;
@property (nonatomic, copy) NSString *updateBy;
@property (nonatomic, copy) NSString *updateDate;
@property (nonatomic, copy) NSString *upperTickCode;

@property (nonatomic, strong) NSNumber *commodityType;
@property (nonatomic, strong) NSNumber *dotNum;
@property (nonatomic, strong) NSNumber *isVip;
@property (nonatomic, strong) NSNumber *lowerTick;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *uad;


+ (NSArray *)objectWithArray:(NSArray *)array;

@end


