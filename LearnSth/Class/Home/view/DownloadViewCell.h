//
//  DownloadViewCell.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadModel.h"

@protocol DownloadCellDelegate <NSObject>
@required
- (void)downloadButtonClickIndex:(NSInteger)index state:(DownloadState)state;
@end

@interface DownloadViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) DownloadModel *fileModel;

@property (nonatomic, weak) id<DownloadCellDelegate> delegate;

@end
