//
//  ResponseModel.m
//  SomeTry
//
//  Created by 丁鹏飞 on 16/9/19.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "ResponseModel.h"

#import "TodayModel.h"

@implementation ResponseModel

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"data"]) {
        
        NSArray *array = [NSArray arrayWithArray:value];
        self.data = [TodayModel objectWithArray:array];
        
    }
}

@end
