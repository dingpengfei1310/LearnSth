//
//  YingKeLiveModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/12/20.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "YingKeLiveModel.h"

@implementation YingKeLiveModel

+ (NSArray<YingKeLiveModel *> *)liveWithArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        YingKeLiveModel *liveModel = [[YingKeLiveModel alloc] init];
        [liveModel setValuesForKeysWithDictionary:dict];
        [tempArray addObject:liveModel];
    }
    
    return [NSArray arrayWithArray:tempArray];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

@end
