//
//  IDCardInfo.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/7.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "IDCardInfo.h"

@implementation IDCardInfo

-(NSString *)description {
    return [NSString stringWithFormat:@"<%@>",@{@"姓名：":_name,@"性别：":_gender,@"民族：":_nation,@"住址：":_address,@"公民身份证：":_num}];
}

@end
