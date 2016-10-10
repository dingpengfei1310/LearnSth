//
//  UserModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (NSArray<UserModel *> *)userWithArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        UserModel *futuresModel = [[UserModel alloc] init];
        [futuresModel setValuesForKeysWithDictionary:dict];
        [tempArray addObject:futuresModel];
    }
    
    return [NSArray arrayWithArray:tempArray];
}

@end
