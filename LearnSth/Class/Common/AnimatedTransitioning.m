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
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    UIView *toView = [toVC view];
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView addSubview:toView];
    
//    if (self.navigationOperation == UINavigationControllerOperationPush) {
    
        [UIView animateWithDuration:0.01 animations:^{} completion:^(BOOL finished) {
            UIView *mainInSnap = [toVC.view snapshotViewAfterScreenUpdates:YES];
            [containerView addSubview:mainInSnap];
            
            mainInSnap.transform = CGAffineTransformMakeScale(0.1, 0.1);
            
            toView.hidden = YES;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                
                mainInSnap.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                [mainInSnap removeFromSuperview];
                
                toView.hidden = NO;
                [transitionContext completeTransition:YES];
            }];
        }];
        
//    } else if (self.navigationOperation == UINavigationControllerOperationPop) {
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

@end
