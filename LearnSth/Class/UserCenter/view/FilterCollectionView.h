//
//  FilterCollectionView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/24.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCollectionView : UIView

@property (nonatomic, strong) NSArray *filters;

@property (nonatomic, copy) void (^FilterSelect)(NSInteger index);

@end
