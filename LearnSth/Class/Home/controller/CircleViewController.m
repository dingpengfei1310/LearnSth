//
//  CircleViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/12/29.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "CircleViewController.h"
#import "CircleLayout.h"

@interface CircleViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation CircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
}

#pragma mark
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = KBaseAppColor;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FFPrint(@"%ld",indexPath.row)
}

#pragma mark
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat viewW = CGRectGetWidth(self.view.frame);
        CircleLayout *layout = [[CircleLayout alloc] init];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, viewW, viewW * 0.6)
                                             collectionViewLayout:layout];
        _collectionView.backgroundColor = KBackgroundColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
    return _collectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
