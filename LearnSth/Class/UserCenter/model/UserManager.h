//
//  UserModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressModel.h"

@interface UserManager : NSObject

@property (nonatomic, copy) NSString *objectId;
//@property (nonatomic, copy) NSString *sessionToken;

@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *updatedAt;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *mobilePhoneNumber;
@property (nonatomic, copy) NSString *headerUrl;

@property (nonatomic, strong) AddressModel *address;

+ (instancetype)shareManager;
+ (void)deallocManager;

+ (void)updateUser;

@end

