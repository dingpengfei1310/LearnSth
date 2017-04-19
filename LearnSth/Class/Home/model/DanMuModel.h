//
//  DanMuModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/19.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,DanMuPosition) {
    DanMuPositionDefault,
    DanMuPositionTop,
    DanMuPositionMiddle,
    DanMuPositionBottom
};

@interface DanMuModel : NSObject

@property (nonatomic, assign) DanMuPosition position;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIColor *textColor;

@end
