//
//  DanMuView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/4/19.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DanMuModel;

@interface DanMuView : UIView

@property (nonatomic, copy) NSString *addString;
@property (nonatomic, strong) DanMuModel *model;

@end
