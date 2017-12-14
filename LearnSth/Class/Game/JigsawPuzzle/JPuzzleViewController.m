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
#import "JPuzzleViewCell.h"
#import "UIImage+Tool.h"

@interface JPuzzleViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) UIEdgeInsets sectionInsets;

@property (nonatomic, assign) NSInteger column;

@property (nonatomic, strong) UIImage *gameImage;
@property (nonatomic, strong) UIImage *numImage;//数字图片

@property (nonatomic, strong) JPuzzleStatus *currentStatus;
@property (nonatomic, strong) JPuzzleStatus *completedStatus;

@end

const CGFloat Margin = 8.0;
const CGFloat LineSpace = 3.0;

@implementation JPuzzleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Game";
    self.automaticallyAdjustsScrollViewInsets = NO;
    _column = 3;
    
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
    [self.view addSubview:self.collectionView];
    
    UIView *buttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, Margin + 64 + Screen_W, Screen_W, 30)];
    [self.view addSubview:buttonView];
    
    CGFloat buttonW = 80;
    NSArray *titles = @[@"难度:低",@"重置",@"打乱",@"自动"];
    for (int i = 0; i < 3; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(i * (Margin + buttonW) + Margin, 0, buttonW, 40)];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:KBaseAppColor forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:KBackgroundColor]
                          forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:button];
    }
}

- (void)resetGame {
    if (_gameImage) {
        _currentStatus = [JPuzzleStatus statusWithRow:_column image:_gameImage];
    } else {
        _currentStatus = [JPuzzleStatus statusWithRow:_column image:_numImage];
    }
    [self.collectionView reloadData];
}

- (void)resetImage {
    CGRect rect = CGRectMake(0, 0, _itemWidth * _column, _itemWidth * _column);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    [[UIColor whiteColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    for (int i = 0; i < _column * _column; i++) {
        NSString *num = [NSString stringWithFormat:@"%d",i + 1];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *att = @{NSFontAttributeName:[UIFont systemFontOfSize:_itemWidth * 0.5],
                              NSForegroundColorAttributeName:KBaseAppColor,
                              NSParagraphStyleAttributeName:style};
        
        CGRect numRect = CGRectMake(i % _column * _itemWidth, i / _column * _itemWidth + _itemWidth * 0.2, _itemWidth, _itemWidth - _itemWidth * 0.2);
        [num drawInRect:numRect withAttributes:att];
    }
    
    _numImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)setColumn:(NSInteger)column {
    if (_column != column) {
        _column = column;
        
        CGFloat viewW = Screen_W - Margin * 2 -  (_column - 1) * LineSpace;
        //计算能否除尽
        CGFloat offsetW = (NSInteger)viewW % _column;
        CGFloat pointX = (offsetW == 0) ? 0 : (_column - offsetW) / 2;
        CGFloat space = (offsetW == 0) ? 0 : 1;
        
        _itemWidth = (viewW - offsetW) / _column + space;
        _sectionInsets = UIEdgeInsetsMake(Margin - pointX, Margin - pointX, Margin - pointX, Margin - pointX);
        
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
        
        NSArray *titleArray = @[@"高",@"中",@"低"];
        NSArray *numArray = @[@"5",@"4",@"3"];
        for (int i = 0; i < titleArray.count; i++) {
            NSString *title = titleArray[i];
            [alert addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                self.column = [numArray[i] integerValue];
                [button setTitle:[NSString stringWithFormat:@"难度:%@",title] forState:UIControlStateNormal];
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if (button.tag == 1) {
        [self resetGame];
        
    } else if (button.tag == 2) {
        if (self.currentStatus.emptyIndex >= 0) {
            [self.currentStatus shuffleWithStep:_column * _column * 10];
//            [self.collectionView reloadData];
            [UIView animateWithDuration:0.3 animations:^{
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                } completion:nil];
            }];
            
        } else {
            [self showError:@"请先挖去一块"];
        }
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
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _column * _column;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JPuzzleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    JPuzzlePiece *piece = _currentStatus.pieceArray[indexPath.item];
    cell.image = piece.image;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_itemWidth, _itemWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return _sectionInsets;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger pieceIndex = indexPath.item;
    JPuzzlePiece *selectPiece = self.currentStatus.pieceArray[pieceIndex];
    
    if (_currentStatus.emptyIndex < 0) {
        //挖空一格,所选方块成为空格
        selectPiece.image = nil;
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        _currentStatus.emptyIndex = pieceIndex;
        self.completedStatus = [self.currentStatus copyStatus];// 设置目标状态
        
        return;
    }
    
    if (![_currentStatus canMoveToIndex:pieceIndex]) {
        return;
    }
    
//    [_currentStatus moveToIndex:pieceIndex];
//    [self.collectionView reloadData];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.collectionView performBatchUpdates:^{
            NSIndexPath *emptyIndex = [NSIndexPath indexPathForItem:_currentStatus.emptyIndex inSection:0];
            
            [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:emptyIndex];
            [self.collectionView moveItemAtIndexPath:emptyIndex toIndexPath:indexPath];
        } completion:nil];
    }];
    [_currentStatus moveToIndex:pieceIndex];
    
    if ([_currentStatus equalWithStatus:self.completedStatus]) {
        [self showAlertWithTitle:@"恭喜你" message:@"拼图完成啦！" operationTitle:@"确定" operation:^{
            [self resetGame];
        }];
    }
}

#pragma mark
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat viewW = Screen_W - Margin * 2 -  (_column - 1) * LineSpace;
        //计算能否除尽
        CGFloat offsetW = (NSInteger)viewW % _column;
        CGFloat pointX = (offsetW == 0) ? 0 : (_column - offsetW) / 2;
        CGFloat space = (offsetW == 0) ? 0 : 1;
        
        _itemWidth = (viewW - offsetW) / _column + space;
        _sectionInsets = UIEdgeInsetsMake(Margin - pointX, Margin - pointX, Margin - pointX, Margin - pointX);
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = LineSpace;
        flowLayout.minimumLineSpacing = LineSpace;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, Screen_W, Screen_W)
                                             collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = KBackgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        [_collectionView registerClass:[JPuzzleViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    
    return _collectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
