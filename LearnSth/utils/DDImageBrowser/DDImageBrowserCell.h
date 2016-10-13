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

- (void)setImageWithUrl:(NSURL *)url placeholderIamge:(UIImage *)placeholder;

- (void)doubleTapToZommWithScale:(CGFloat)scale;

@end
