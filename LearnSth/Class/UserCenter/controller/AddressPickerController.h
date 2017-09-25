//
//  AddressPickerController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/16.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@interface AddressPickerController : BaseViewController

@property (nonatomic, copy) void (^SelectBlock)(NSDictionary *province,NSDictionary *city);
@property (nonatomic, copy) void (^AddressDismissBlock)(void);

@end
