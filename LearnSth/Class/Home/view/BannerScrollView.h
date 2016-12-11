//
//  BannerScrollView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/5.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ImageClickBlock)(NSInteger index);

@interface BannerScrollView : UIView

@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, copy) ImageClickBlock imageClickBlock;

- (void)setUpTimer;
- (void)invalidateTimer;

@end
