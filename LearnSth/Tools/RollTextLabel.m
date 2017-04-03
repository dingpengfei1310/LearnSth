//
//  RollTextLabel.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/4/3.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "RollTextLabel.h"

@interface RollTextLabel ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation RollTextLabel

- (instancetype)init {
    if (self = [super init]) {
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
//    self.scrollEnabled = NO;
    [self addSubview:self.label];
}

- (void)setText:(NSString *)text {
    if (text.length > 0 && ![_text isEqualToString:text]) {
        _text = text;
        self.label.text = text;
        [self calculateFrame:text];
    }
}

- (void)calculateFrame:(NSString *)text {
    CGSize size = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 21)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                     context:nil].size;
    self.label.frame = CGRectMake(0, 0, size.width, 21);
    self.contentSize = CGSizeMake(size.width, 0);
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 21)];
        _label.font = [UIFont systemFontOfSize:12];
        _label.textColor = [UIColor whiteColor];
    }
    return _label;
}

@end
