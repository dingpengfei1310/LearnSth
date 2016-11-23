//
//  DDImageBrowserCell.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/13.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDImageBrowserConfig.h"

@interface DDImageBrowserCell : UITableViewCell

///可以显示网络图片和本地图片（包括占位图和高清图）
- (void)setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder;

@end
