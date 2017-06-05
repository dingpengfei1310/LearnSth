//
//  JPuzzleStatus.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/5.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "JPuzzleStatus.h"
#import "JPuzzlePiece.h"

@implementation JPuzzleStatus

+ (instancetype)statusWithRow:(NSInteger)row image:(UIImage *)image {
    if (row < 3 || !image) {
        return nil;
    }
    
    JPuzzleStatus *status = [[JPuzzleStatus alloc] init];
    status.row = row;
    status.pieceArray = [NSMutableArray arrayWithCapacity:row * row];
    status.emptyIndex = -1;
    
    CGFloat pieceWidh = CGImageGetWidth(image.CGImage) / row;
    CGFloat pieceHeight = CGImageGetHeight(image.CGImage) / row;
    
    NSInteger index = 0;
    for (NSInteger i = 0; i < row; i++) {
        for (NSInteger j = 0; j < row; j++) {
            // 切割图片
            CGRect rect = CGRectMake(j * pieceWidh, i * pieceHeight, pieceWidh, pieceHeight);
            CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, rect);
            JPuzzlePiece *piece = [JPuzzlePiece pieceWithIndex:index++ image:[UIImage imageWithCGImage:imgRef]];
            [status.pieceArray addObject:piece];
        }
    }
    
    return status;
}

- (instancetype)copyStatus {
    JPuzzleStatus *status = [[JPuzzleStatus alloc] init];
    status.row = self.row;
    status.pieceArray = [self.pieceArray mutableCopy];
    status.emptyIndex = self.emptyIndex;
    return status;
}

- (BOOL)equalWithStatus:(JPuzzleStatus *)status {
    return [self.pieceArray isEqualToArray:status.pieceArray];
}

#pragma mark
- (BOOL)canMoveToIndex:(NSInteger)index {
    NSInteger diff = labs(index - _emptyIndex);
    return (diff == _row || (diff == 1 && index / _row == _emptyIndex / _row));
}

/// 把空格移动到某个位置
- (void)moveToIndex:(NSInteger)index {
    JPuzzlePiece *temp = self.pieceArray[self.emptyIndex];
    self.pieceArray[self.emptyIndex] = self.pieceArray[index];
    self.pieceArray[index] = temp;
    
    self.emptyIndex = index;
}

@end
