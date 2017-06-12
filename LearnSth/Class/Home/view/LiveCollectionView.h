//
//  LiveCollectionView.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/12.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveCollectionView : UIView

@property (nonatomic, copy) void (^BannerClickBlock)(NSString *link);
@property (nonatomic, copy) void (^LiveClickBlock)(NSInteger index, NSArray *liveArray);

- (void)viewWillShow:(BOOL)flag;

@end
