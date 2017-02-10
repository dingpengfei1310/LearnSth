//
//  AnimatedTransitioning.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger){
    AnimatedTransitioningTypeNone = 0,
    AnimatedTransitioningTypeScale
}AnimatedTransitioningType;

@interface AnimatedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) UINavigationControllerOperation operation;
@property (nonatomic, assign) AnimatedTransitioningType transitioningType;

@property (nonatomic, assign) CGRect originalFrame;

@end
