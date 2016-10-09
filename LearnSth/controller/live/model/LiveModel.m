//
//  LiveModel.m
//  ReadyJob
//
//  Created by 丁鹏飞 on 16/8/28.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LiveModel.h"

@implementation LiveModel

+ (NSArray<LiveModel *> *)liveWithArray:(NSArray *)array {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
    
    for (NSDictionary *dict in array) {
        LiveModel *liveModel = [[LiveModel alloc] init];
        [liveModel setValuesForKeysWithDictionary:dict];
        [tempArray addObject:liveModel];
    }
    
    return [NSArray arrayWithArray:tempArray];
}

@end
