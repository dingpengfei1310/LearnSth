//
//  AddressModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/3.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressModel : NSObject

@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *street;

- (NSDictionary *)dictionary;

@end
