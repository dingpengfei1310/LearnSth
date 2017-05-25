//
//  PanInteractiveTransition.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PanInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign) BOOL interacting;

- (void)setController:(UIViewController *)controler;

@end
