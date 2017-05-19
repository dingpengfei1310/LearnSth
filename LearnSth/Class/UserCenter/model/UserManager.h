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

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, strong) NSData *headerImageData;

@property (nonatomic, strong) AddressModel *address;

+ (instancetype)shareManager;
+ (void)deallocManager;

+ (void)updateUser;

@end

