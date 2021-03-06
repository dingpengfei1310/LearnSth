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
    if(self.viewControllers.count < navigationBar.items.count) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    // 代理返回
    UIViewController* viewController = [self topViewController];
    if([viewController respondsToSelector:@selector(navigationShouldPopItem)]) {
        shouldPop = [viewController navigationShouldPopItem];
    }
    
    if(shouldPop) {
        [self popViewControllerAnimated:YES];
        
    } else {
        for(UIView *subview in navigationBar.subviews) {
            if(0.0 < subview.alpha && subview.alpha < 1.0) {
                subview.alpha = 1.;
            }
        }
    }
    
    return NO;
}

@end
