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
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitioningType == AnimatedTransitioningTypeMove) {
        [self transitioningTypeMoveWithOperation:self.operation context:transitionContext];
        
    } else if (self.transitioningType == AnimatedTransitioningTypeScale) {
        [self transitioningTypeScaleWithOperation:self.operation context:transitionContext];
    }
}

- (void)transitioningTypeMoveWithOperation:(AnimatedTransitioningOperation)operation context:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIView *containerView = [transitionContext containerView];
    CGFloat viewWidth = CGRectGetWidth(containerView.frame);
    
    UIView *fromViewSnapshot = [fromView snapshotViewAfterScreenUpdates:YES];
    UIView *toViewSnapshot = [toView snapshotViewAfterScreenUpdates:YES];
    
    if (operation == AnimatedTransitioningOperationPresent) {
        [containerView addSubview:fromViewSnapshot];
        [containerView addSubview:toViewSnapshot];
        toViewSnapshot.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewSnapshot.transform = CGAffineTransformMakeTranslation(-viewWidth * 0.2, 0);
            toViewSnapshot.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            [toViewSnapshot removeFromSuperview];
            [fromViewSnapshot removeFromSuperview];
            
            [containerView addSubview:toView];
            [transitionContext completeTransition:YES];
        }];
        
    } else if (operation == AnimatedTransitioningOperationDismiss) {
        [containerView addSubview:toViewSnapshot];
        [containerView addSubview:fromViewSnapshot];
        toViewSnapshot.transform = CGAffineTransformMakeTranslation(-viewWidth * 0.2, 0);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewSnapshot.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
            toViewSnapshot.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            [toViewSnapshot removeFromSuperview];
            [fromViewSnapshot removeFromSuperview];
            
            [containerView addSubview:toView];
            [transitionContext completeTransition:YES];
        }];
        
    } else if (operation == AnimatedTransitioningOperationPop) {
        [containerView addSubview:toViewSnapshot];
        [containerView addSubview:fromViewSnapshot];
        toViewSnapshot.transform = CGAffineTransformMakeTranslation(-viewWidth * 0.2, 0);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewSnapshot.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
            toViewSnapshot.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            [toViewSnapshot removeFromSuperview];
            [fromViewSnapshot removeFromSuperview];
            
            [containerView addSubview:toView];
            [transitionContext completeTransition:YES];
        }];
    }
    
}

- (void)transitioningTypeScaleWithOperation:(AnimatedTransitioningOperation)operation context:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.operation == AnimatedTransitioningOperationPush) {
        UIView *containerView = [transitionContext containerView];
        
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
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
}

//- (void)transitioningWithTypeNone:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    
//    UIView *containerView = [transitionContext containerView];
//    CGFloat viewWidth = CGRectGetWidth(containerView.frame);
//    
//    UIView *fromViewSnapshot = [fromVC.navigationController.view snapshotViewAfterScreenUpdates:NO];
//    [containerView addSubview:fromViewSnapshot];
//    
//    UIView *toViewSnapshot = [toView snapshotViewAfterScreenUpdates:YES];
//    [containerView addSubview:toViewSnapshot];
//    toViewSnapshot.transform = CGAffineTransformMakeTranslation(viewWidth, 0);
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        
//        fromViewSnapshot.transform = CGAffineTransformMakeTranslation(-100, 0);
//        toViewSnapshot.transform = CGAffineTransformIdentity;
//        
//    } completion:^(BOOL finished) {
//        [toViewSnapshot removeFromSuperview];
//        [fromViewSnapshot removeFromSuperview];
//        
//        [containerView addSubview:toView];
//        [transitionContext completeTransition:YES];
//    }];
//}

//- (void)transitioningWithTypeScale:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    
//    UIView *containerView = [transitionContext containerView];
//    
//    UIView *fromViewSnapshot = [fromVC.navigationController.view snapshotViewAfterScreenUpdates:NO];
//    [containerView addSubview:fromViewSnapshot];
//    
//    UIView *toViewSnapshot = [toView snapshotViewAfterScreenUpdates:YES];
//    [containerView addSubview:toViewSnapshot];
//    toViewSnapshot.frame = self.originalFrame;
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        
//        toViewSnapshot.frame = containerView.bounds;
//        
//    } completion:^(BOOL finished) {
//        [toViewSnapshot removeFromSuperview];
//        [fromViewSnapshot removeFromSuperview];
//        
//        [containerView addSubview:toView];
//        [transitionContext completeTransition:YES];
//    }];
//}

@end
