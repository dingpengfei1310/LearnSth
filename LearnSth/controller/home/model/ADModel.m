//
//  ADModel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/11.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ADModel.h"

@implementation ADModel

+ (NSArray<ADModel *> *)adWithArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        ADModel *adModel = [[ADModel alloc] init];
        [adModel setValuesForKeysWithDictionary:dict];
        [tempArray addObject:adModel];
    }
    
    return [NSArray arrayWithArray:tempArray];
}

@end
