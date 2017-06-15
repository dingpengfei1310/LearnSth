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
    status.rowCount = row;
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
    status.rowCount = self.rowCount;
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
    return (diff == _rowCount || (diff == 1 && index / _rowCount == _emptyIndex / _rowCount));
}

/// 把空格移动到某个位置
- (void)moveToIndex:(NSInteger)index {
    JPuzzlePiece *temp = self.pieceArray[self.emptyIndex];
    self.pieceArray[self.emptyIndex] = self.pieceArray[index];
    self.pieceArray[index] = temp;
    
    self.emptyIndex = index;
}

//打乱
- (void)shuffleWithStep:(NSInteger)count {
    // 记录前置状态，避免来回移动
    // 前两个状态的空格位置
    NSInteger ancestorIndex = -1;
    // 前一个状态的空格位置
    NSInteger parentIndex = -1;
    while (count > 0) {
        NSInteger targetIndex = -1;
        switch (arc4random() % 4) {
            case 0:
                targetIndex = [self upIndex];
                break;
            case 1:
                targetIndex = [self downIndex];
                break;
            case 2:
                targetIndex = [self leftIndex];
                break;
            case 3:
                targetIndex = [self rightIndex];
                break;
            default:
                break;
        }
        
        if (targetIndex != -1 && targetIndex != ancestorIndex) {
            [self moveToIndex:targetIndex];
            ancestorIndex = parentIndex;
            parentIndex = targetIndex;
            count --;
        }
    }
}


#pragma mark
//行号
- (NSInteger)rowOfIndex:(NSInteger)index {
    return index / self.rowCount;
}
//列号
- (NSInteger)colOfIndex:(NSInteger)index {
    return index % self.rowCount;
}

- (NSInteger)upIndex {
    if ([self rowOfIndex:self.emptyIndex] == 0) {
        return -1;
    }
    return self.emptyIndex - self.rowCount;
}

- (NSInteger)downIndex {
    if ([self rowOfIndex:self.emptyIndex] == self.rowCount - 1) {
        return -1;
    }
    return self.emptyIndex + self.rowCount;
}

- (NSInteger)leftIndex {
    if ([self colOfIndex:self.emptyIndex] == 0) {
        return -1;
    }
    return self.emptyIndex - 1;
}

- (NSInteger)rightIndex {
    if ([self colOfIndex:self.emptyIndex] == self.rowCount - 1) {
        return -1;
    }
    return self.emptyIndex + 1;
}

@end
