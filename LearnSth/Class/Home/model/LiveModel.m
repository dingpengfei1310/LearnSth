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
    
//    [tempArray sortUsingComparator:^NSComparisonResult(LiveModel *obj1, LiveModel *obj2) {
//        NSInteger num1 = obj1.allnum.integerValue;
//        NSInteger num2 = obj2.allnum.integerValue;
//        
//        return num1 < num2;
//    }];
    
    return [NSArray arrayWithArray:tempArray];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"city"]) {
        self.gps = value;
        
    } else if ([key isEqualToString:@"name"]) {
        self.familyName = value;
        
    } else if ([key isEqualToString:@"stream_addr"]) {
        self.flv = value;
        
    } else if ([key isEqualToString:@"creator"]) {
        self.myname = [value objectForKey:@"nick"];
        self.bigpic = [value objectForKey:@"portrait"];
        self.signatures = [value objectForKey:@"description"];
        
    } else if ([key isEqualToString:@"online_users"]) {
        self.allnum = value;
    }
}

@end
