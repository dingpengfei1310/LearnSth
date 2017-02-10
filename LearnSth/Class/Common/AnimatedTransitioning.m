//
//  AnimatedTransitioning.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "AnimatedTransitioning.h"

@implementation AnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.operation == UINavigationControllerOperationPush) {
        
        if (self.transitioningType == AnimatedTransitioningTypeNone) {
            [self transitioningWithTypeNone:transitionContext];
        } else if (self.transitioningType == AnimatedTransitioningTypeScale) {
            [self transitioningWithTypeScale:transitionContext];
        }
        
    }
//    else if (self.operation == UINavigationControllerOperationPop) {
//        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//        
//        UIView *mainInSnap = [fromVC.view snapshotViewAfterScreenUpdates:NO];
//        [containerView addSubview:mainInSnap];
//        
//        //        toView.hidden = YES;
//        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//            
//            mainInSnap.transform = CGAffineTransformMakeScale(0.1, 0.1);
//            
//        } completion:^(BOOL finished) {
//            [mainInSnap removeFromSuperview];
//            
//            //            toView.hidden = NO;
//            [transitionContext completeTransition:YES];
//        }];
//        
//        //        [UIView animateWithDuration:0.01 animations:^{} completion:^(BOOL finished) {
//        //
//        //        }];
//    }
}

- (void)transitioningWithTypeNone:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    CGFloat viewWidth = CGRectGetWidth(containerView.frame);
    
    UIView *fromViewSnapshot = [fromVC.navigationController.view snapshotViewAfterScreenUpdates:NO];
    [containerView addSubview:fromViewSnapshot];
    
    UIView *toViewSnapshot = [toView snapshotViewAfterScreenUpdates:YES];
    [containerView addSubview:toViewSnapshot];
    toViewSnapshot.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        fromViewSnapshot.transform = CGAffineTransformMakeTranslation(-100, 0);
        toViewSnapshot.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [toViewSnapshot removeFromSuperview];
        [fromViewSnapshot removeFromSuperview];
        
        [containerView addSubview:toView];
        [transitionContext completeTransition:YES];
    }];
}

- (void)transitioningWithTypeScale:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    UIView *fromViewSnapshot = [fromVC.navigationController.view snapshotViewAfterScreenUpdates:NO];
    [containerView addSubview:fromViewSnapshot];
    
    UIView *toViewSnapshot = [toView snapshotViewAfterScreenUpdates:YES];
    [containerView addSubview:toViewSnapshot];
    toViewSnapshot.frame = self.originalFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        toViewSnapshot.frame = containerView.bounds;
        
    } completion:^(BOOL finished) {
        [toViewSnapshot removeFromSuperview];
        [fromViewSnapshot removeFromSuperview];
        
        [containerView addSubview:toView];
        [transitionContext completeTransition:YES];
    }];
}

@end
