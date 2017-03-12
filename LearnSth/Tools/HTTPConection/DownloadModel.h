//
//  DownloadModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/9.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadModel : NSObject

@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *state;

@property (nonatomic, assign) int64_t bytesReceived;
@property (nonatomic, assign) int64_t bytesTotal;

@end
