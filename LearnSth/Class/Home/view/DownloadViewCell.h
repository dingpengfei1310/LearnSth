//
//  DownloadViewCell.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadModel;
@interface DownloadViewCell : UITableViewCell

- (IBAction)buttonClick:(UIButton *)sender;

@property (nonatomic, copy) void (^CellButtonClick)(BOOL running);

@property (nonatomic, strong) DownloadModel *fileModel;

@end
