//
//  JPuzzlePiece.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/5.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPuzzlePiece : UIButton

@property (nonatomic, assign) NSInteger index;

+ (instancetype)pieceWithIndex:(NSInteger)index image:(UIImage *)image;

@end
