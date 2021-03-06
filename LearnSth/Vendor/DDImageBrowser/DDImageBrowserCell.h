//
//  DDImageBrowserCell.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/13.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDImageBrowserCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) void (^SingleTapBlock)(void);
@property (nonatomic, copy) void (^LongPressBlock)(void);

@end
