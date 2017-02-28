//
//  BaseControllerProtocol.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/28.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

//#ifndef BaseControllerProtocol_h
//#define BaseControllerProtocol_h
//
//
//#endif /* BaseControllerProtocol_h */

#import "UIViewController+Tool.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Tool.h"

#import "AppConfiguration.h"

#import "LanguageTool.h"
#import "HttpManager.h"
#import "Utils.h"

@protocol BaseControllerProtocol <NSObject>

@optional
- (void)resetBackItemTitle:(NSString *)title;

@end
