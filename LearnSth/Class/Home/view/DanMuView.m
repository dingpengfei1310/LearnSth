//
//  DanMuView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/19.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "DanMuView.h"
#import "DanMuModel.h"

@interface DanMuView ()

@end

const CGFloat labelH = 30;

@implementation DanMuView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, Screen_W, 300);
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize { 
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}

- (void)addDanmu:(DanMuModel *)model {
    _danmuCount++;
    
    int viewHeight = self.frame.size.height - 30;
    CGFloat viewY = 0;
    
    switch (model.position) {
        case DanMuPositionTop: {
            viewHeight = viewHeight * 0.33 - 30;
            break;
        }
            
        case DanMuPositionMiddle: {
            viewHeight = viewHeight * 0.66 - 30;
            viewY = viewHeight * 0.33;
            break;
        }
            
        case DanMuPositionBottom: {
            viewHeight = viewHeight - 30;
            viewY = viewHeight * 0.66;
            break;
        }
            
        default:
            break;
    }
    
    UIFont *font = [UIFont systemFontOfSize:16];
    NSDictionary *att = @{NSFontAttributeName:font};
    CGSize size = [model.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:att context:nil].size;
    
    int originY = MAX(viewY, arc4random() % viewHeight);
    UILabel *danMuLabel = [[UILabel alloc] initWithFrame:CGRectMake(Screen_W, originY, size.width, size.height)];
    danMuLabel.backgroundColor = KBackgroundColor;
    danMuLabel.font = font;
    danMuLabel.text = model.text;
    danMuLabel.textColor = model.textColor;
    [self addSubview:danMuLabel];
    
//    (3 + size.width / 200) * size.width / (size.width + 2 * Screen_W) + 0.1;
    [UIView animateWithDuration:(3 + size.width / 200)
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         danMuLabel.frame = CGRectMake(-size.width, originY, size.width, size.height);
                     } completion:^(BOOL finished) {
                         [danMuLabel removeFromSuperview];
                         _danmuCount--;
                     }];
}

@end
