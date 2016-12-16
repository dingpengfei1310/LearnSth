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
//@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;

+ (instancetype)userManager;

- (NSDictionary *)dictionary;


@end
