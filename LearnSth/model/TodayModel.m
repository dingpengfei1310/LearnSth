//
//  TodayModel.m
//  SomeTry
//
//  Created by 丁鹏飞 on 16/9/19.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "TodayModel.h"

@implementation TodayModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

+ (NSArray *)objectWithArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        TodayModel *model = [[TodayModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [tempArray addObject:model];
    }
    
    NSArray *modelArray = [NSArray arrayWithArray:tempArray];
    return modelArray;
}

@end
