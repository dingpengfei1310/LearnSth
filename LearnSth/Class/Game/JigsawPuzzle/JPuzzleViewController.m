//
//  JPuzzleViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/6/5.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "JPuzzleViewController.h"

#import "JPuzzlePiece.h"
#import "JPuzzleStatus.h"

@interface JPuzzleViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) UIView *gameView;

@property (nonatomic, strong) UIImage *gameImage;
@property (nonatomic, strong) UIImage *numImage;//数字图片

@property (nonatomic, strong) JPuzzleStatus *currentStatus;
@property (nonatomic, strong) JPuzzleStatus *completedStatus;

@end

const CGFloat Margin = 10;

@implementation JPuzzleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Game";
    _row = 3;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(selectImage)];
    
    [self initilizSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!(_numImage || _gameImage)) {
        [self resetImage];
        [self resetGame];
    }
}

- (void)initilizSubviews {
    CGFloat viewW = self.view.frame.size.width - Margin * 2;
    
    _gameView = [[UIView alloc] initWithFrame:CGRectMake(Margin - 2, 64 + Margin, viewW + 4, viewW + 4)];
    _gameView.backgroundColor = KBackgroundColor;
    [self.view addSubview:_gameView];
    
    UIView *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(Margin, Margin + CGRectGetMaxY(_gameView.frame), viewW, 30)];
    [self.view addSubview:buttonView];
    
    CGFloat buttonW = 60;
    NSArray *titles = @[@"难度:低",@"重置",@"打乱",@"自动"];
    for (int i = 0; i < 3; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * (Margin + buttonW), 0, buttonW, 30)];
        button.backgroundColor = KBaseBlueColor;
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:button];
    }
}

- (void)resetGame {
    if (_gameImage) {
        _currentStatus = [JPuzzleStatus statusWithRow:_row image:_gameImage];
    } else {
        _currentStatus = [JPuzzleStatus statusWithRow:_row image:_numImage];
    }
    
    [_currentStatus.pieceArray enumerateObjectsUsingBlock:^(JPuzzlePiece *obj, NSUInteger idx, BOOL *stop) {
        [obj addTarget:self action:@selector(onPieceTouch:) forControlEvents:UIControlEventTouchUpInside];
    }];
    [self showCurrentStatusOnView:_gameView];
}

- (void)resetImage {
    CGRect rect = CGRectMake(0, 0, Screen_W * _row, Screen_W * _row);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [KBackgroundColor setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    for (int i = 0; i < _row * _row; i++) {
        NSString *num = [NSString stringWithFormat:@"%d",i + 1];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *att = @{NSFontAttributeName:[UIFont systemFontOfSize:200],
                              NSForegroundColorAttributeName:KBaseBlueColor,
                              NSParagraphStyleAttributeName:style};
        
        CGRect numRect = CGRectMake(i % _row * Screen_W, i / _row * Screen_W + 40, Screen_W, Screen_W - 40);
        [num drawInRect:numRect withAttributes:att];
    }
    
    _numImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)showCurrentStatusOnView:(UIView *)view {
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat size = CGRectGetWidth(view.bounds) / _row;
    NSInteger index = 0;
    
    for (NSInteger i = 0; i < _row; i++) {
        for (NSInteger j = 0; j < _row; j++) {
            JPuzzlePiece *piece = _currentStatus.pieceArray[index++];
            piece.frame = CGRectMake(j * size, i * size, size, size);
            [_gameView addSubview:piece];
        }
    }
}

- (void)setRow:(NSInteger)row {
    if (_row != row) {
        _row = row;
        if (!_gameImage) {
            [self resetImage];
        }
        
        [self resetGame];
    }
}

#pragma mark
- (void)selectImage {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)buttonClick:(UIButton *)button {
    
    if (button.tag == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"高" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            self.row = 5;
            [button setTitle:@"难度:高" forState:UIControlStateNormal];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"中" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            self.row = 4;
            [button setTitle:@"难度:中" forState:UIControlStateNormal];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"低" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            self.row = 3;
            [button setTitle:@"难度:低" forState:UIControlStateNormal];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if (button.tag == 1) {
        [self resetGame];
        
    } else if (button.tag == 2) {
        if (self.currentStatus.emptyIndex >= 0) {
            [self.currentStatus shuffleWithStep:_row * _row * 10];
            [self reloadWithStatus:self.currentStatus];
        } else {
            [self showError:@"请先挖去一块"];
        }
        
    } else if (button.tag == 3) {
        
    }
}

#pragma mark
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated {
    viewController.view.backgroundColor = [UIColor blackColor];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    _numImage = nil;
    _gameImage = info[UIImagePickerControllerEditedImage];
    [self resetGame];
}

#pragma mark
- (void)onPieceTouch:(JPuzzlePiece *)piece {
    JPuzzleStatus *status = self.currentStatus;
    NSInteger pieceIndex = [status.pieceArray indexOfObject:piece];
    
    // 挖空一格
    if (status.emptyIndex < 0) {
        // 所选方块成为空格
        [UIView animateWithDuration:0.1 animations:^{
            piece.alpha = 0;
        }];
        
        status.emptyIndex = pieceIndex;
        self.completedStatus = [self.currentStatus  copyStatus];// 设置目标状态
        
        return;
    }
    
    if (![status canMoveToIndex:pieceIndex]) {
        return;
    }
    
    [status moveToIndex:pieceIndex];
    [self reloadWithStatus:self.currentStatus];

    if ([status equalWithStatus:self.completedStatus]) {
        [self showAlertWithTitle:@"恭喜你" message:@"拼图完成啦！" operationTitle:@"确定" operation:^{
            [self resetGame];
        }];
    }
}

- (void)reloadWithStatus:(JPuzzleStatus *)status {
    [UIView animateWithDuration:0.25 animations:^{
        CGSize size = status.pieceArray.firstObject.frame.size;
        NSInteger index = 0;
        
        for (NSInteger i = 0; i < _row; i++) {
            for (NSInteger j = 0; j < _row; j++) {
                JPuzzlePiece *piece = status.pieceArray[index++];
                piece.frame = CGRectMake(j * size.width, i * size.height, size.width, size.height);
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
