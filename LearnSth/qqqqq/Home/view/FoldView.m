//
//  FoldView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/18.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "FoldView.h"

@implementation FoldView {
    CGFloat width,height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        width = frame.size.width;
        height = frame.size.height;
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [bottomLabel setText:@"A"];
        [bottomLabel setFont:[UIFont boldSystemFontOfSize:50]];
        [bottomLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:bottomLabel];
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1/500.0;
        [self.layer setSublayerTransform:transform];
        
        [self.layer setTransform:CATransform3DMakeRotation((M_PI / 2) - 0.2, 1, 0, 0)];
        
        self.layer.contents = (__bridge id)([UIImage imageNamed:@"lookup"].CGImage);
        
    }
    return self;
}

- (void)fold:(CGFloat)fraction {
    
    
    
    float delta = asinf(fraction);
    
    [self.layer setTransform:CATransform3DMakeRotation((M_PI / 2) - delta, 1, 0, 0)];
    
    // rotate topView on the right edge of the view
    // translate rotated view to the bottom to join to the edge of the bottomView
//    CATransform3D transform1 = CATransform3DMakeTranslation(0, -2*self.bottomView.frame.size.height, 0);
//    CATransform3D transform2 = CATransform3DMakeRotation((M_PI / 2) - delta, -1, 0, 0);
//    CATransform3D transform = CATransform3DConcat(transform2, transform1);
//    [self.topView.layer setTransform:transform];
    
}

@end
