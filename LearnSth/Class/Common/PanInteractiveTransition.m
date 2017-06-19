//
//  PanInteractiveTransition.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "PanInteractiveTransition.h"

@interface PanInteractiveTransition ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL shouldComplete;
@property (nonatomic, strong) UIViewController *presentingVC;

@end

@implementation PanInteractiveTransition

- (void)setPresentingController:(UIViewController *)controler {
    _presentingVC = controler;
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    gesture.delegate = self;
    [_presentingVC.view addGestureRecognizer:gesture];
}

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.interacting = YES;
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat fraction = translation.x / CGRectGetWidth(gestureRecognizer.view.superview.frame);
            fraction = fminf(fmaxf(fraction, 0.0), 1.0);
            self.shouldComplete = (fraction > 0.5);
            
            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.interacting = NO;
            if (!self.shouldComplete || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            } else {
                [self finishInteractiveTransition];
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
        if (translation.x > 30) {
            return NO;
        }
    }
    return YES;
}

@end
