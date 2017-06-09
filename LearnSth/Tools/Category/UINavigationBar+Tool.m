//
//  UINavigationBar+Tool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/24.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UINavigationBar+Tool.h"

@implementation UINavigationBar (Tool)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (point.y < 0 || point.y > 44) {
        return nil;
        
    } else if (point.x > self.frame.size.width * 0.5) {
        self.userInteractionEnabled = YES;
        
    } else if (self.backItem) {
        NSString *title = @"返回";
        
        if (self.backItem.backBarButtonItem.title) {
            title = self.backItem.backBarButtonItem.title;
        } else {
            title = self.backItem.title;
        }
        
        NSDictionary *attributes = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
        CGSize size = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributes
                                          context:nil].size;
        
        self.userInteractionEnabled = size.width + 30 > point.x;
//        self.backItem.leftBarButtonItem.enabled = size.width + 30 > point.x;
//        self.backItem.backBarButtonItem.enabled = size.width + 30 > point.x;
    }
    
    return [super hitTest:point withEvent:event];
}

@end
