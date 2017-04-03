//
//  UIViewController+PopAction.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/4/3.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UIViewController+PopAction.h"

@implementation UIViewController (PopAction)

@end

@implementation UINavigationController (ShouldPopItem)

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    // 代理返回
    UIViewController* viewController = [self topViewController];
    if([viewController respondsToSelector:@selector(navigationShouldPopItem)]) {
        shouldPop = [viewController navigationShouldPopItem];
    }
    /**
     *  此处为什么要写这个呢，因为当你
     1、A --> B --> C ;
     2、C --> A 之后 你再进入 B 之后，B不能返回 A的情况
     */
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    } else {
        for(UIView *subview in [navigationBar subviews]) {
            if(0. < subview.alpha && subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }
    
    return NO;
}

@end
