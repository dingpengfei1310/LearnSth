//
//  JPuzzlePiece.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/5.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "JPuzzlePiece.h"

@implementation JPuzzlePiece

+ (instancetype)pieceWithIndex:(NSInteger)index image:(UIImage *)image {
    JPuzzlePiece *piece = [[JPuzzlePiece alloc] init];
    piece.index = index;
    piece.layer.borderWidth = 2.0;
    piece.layer.borderColor = [UIColor whiteColor].CGColor;
    [piece setBackgroundImage:image forState:UIControlStateNormal];
    
    return piece;
}

@end
