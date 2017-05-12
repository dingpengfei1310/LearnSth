//
//  UserInfoViewController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/1.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoViewController : UIViewController

@property (nonatomic, copy) void (^ChangeHeaderImageBlock)();
@property (nonatomic, copy) void (^ChangeUsernameBlock)();

@end
