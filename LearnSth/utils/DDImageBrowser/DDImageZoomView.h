//
//  DDImageZoomView.h
//  ReadyJob
//
//  Created by 丁鹏飞 on 16/8/4.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDImageBrowserConfig.h"

@interface DDImageZoomView : UIView

- (void)setImageWithUrl:(NSURL *)url placeholderIamge:(UIImage *)placeholder;

- (void)doubleTapToZommWithScale:(CGFloat)scale;

@end
