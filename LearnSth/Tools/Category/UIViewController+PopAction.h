//
//  UIViewController+PopAction.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/4/3.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PopActionProtocol <NSObject>

@optional
- (BOOL)navigationShouldPopItem;

@end

///拦截Navigation自带的返回事件
@interface UIViewController (PopAction)<PopActionProtocol>

@end
