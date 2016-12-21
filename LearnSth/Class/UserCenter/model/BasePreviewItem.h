//
//  BasePreviewItem.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QLPreviewItem.h>

@interface BasePreviewItem : NSObject<QLPreviewItem>

@property (nonatomic, strong) NSURL *previewItemURL;
@property (nonatomic, strong) NSString *previewItemTitle;

@end
