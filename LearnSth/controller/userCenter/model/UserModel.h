//
//  UserModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *nickname;//昵称
@property (nonatomic, copy) NSString *username;//
@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, copy) NSString *acceptPkTimes;
@property (nonatomic, copy) NSString *buysellRatio;
@property (nonatomic, copy) NSString *createBy;
@property (nonatomic, copy) NSString *createDate;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *groupType;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *isAllowPk;
@property (nonatomic, copy) NSString *pkRowWin;
@property (nonatomic, copy) NSString *pkTotal;
@property (nonatomic, copy) NSString *pkWin;
@property (nonatomic, copy) NSString *updateBy;
@property (nonatomic, copy) NSString *updateDate;

@property (nonatomic, copy) NSString *winRate;

+ (instancetype)user;

+ (NSArray<UserModel *> *)userWithArray:(NSArray *)array;

@end
