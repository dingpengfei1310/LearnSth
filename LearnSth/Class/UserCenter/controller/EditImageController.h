//
//  EditImageController.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/15.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "BaseViewController.h"

@interface EditImageController : BaseViewController

@property (nonatomic, copy) void (^FinishImageBlock)(UIImage *editImage);
@property (nonatomic, strong) UIImage *originalImage;

@end
