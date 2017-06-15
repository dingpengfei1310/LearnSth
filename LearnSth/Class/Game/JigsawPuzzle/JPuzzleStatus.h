//
//  JPuzzleStatus.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/5.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JPuzzlePiece;
@interface JPuzzleStatus : NSObject

@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, strong) NSMutableArray<JPuzzlePiece*> *pieceArray;

/// 空格位置，无空格时为-1
@property (nonatomic, assign) NSInteger emptyIndex;

+ (instancetype)statusWithRow:(NSInteger)row image:(UIImage *)image;
- (instancetype)copyStatus;
- (BOOL)equalWithStatus:(JPuzzleStatus *)status;

#pragma mark
- (BOOL)canMoveToIndex:(NSInteger)index;
- (void)moveToIndex:(NSInteger)index;

- (void)shuffleWithStep:(NSInteger)count;

@end
