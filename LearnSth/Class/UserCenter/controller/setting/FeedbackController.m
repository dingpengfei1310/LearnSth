//
//  FeedbackController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/8/1.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "FeedbackController.h"

#import <YYText/YYText.h>
#import <YYImage/YYImage.h>

const NSInteger emoteColumn = 7;//7列
const CGFloat emoteWidth = 28.0;//item宽高为28

@interface FeedbackController ()<YYTextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate> {
    CGFloat viewW;
    CGFloat viewH;
}

@property (nonatomic,strong) YYTextView *textView;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *editButton;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) CGFloat spaceW;

@property (nonatomic, strong) UIFont *emoteFont;

@end

@implementation FeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"意见反馈";
    self.view.backgroundColor = KBackgroundColor;
    viewW = self.view.frame.size.width;
    viewH = self.view.frame.size.height;
    _emoteFont = [UIFont systemFontOfSize:16];
    
    _textView = [[YYTextView alloc] initWithFrame:CGRectMake(0, 64, viewW, 200)];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.font = _emoteFont;
    _textView.delegate = self;
    [self.view addSubview:_textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, viewH - 44, viewW, 44)];
    _bottomView.backgroundColor = KBackgroundColor;
    [self.view addSubview:_bottomView];
    
    UIButton *edit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [edit setTitle:@"edit" forState:UIControlStateNormal];
    [edit setTitleColor:KBaseAppColor forState:UIControlStateSelected];
    [edit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [edit addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:edit];
    _editButton = edit;
    
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    CGRect keyBoardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    self.view.frame = CGRectMake(0, 0, viewW, viewH - keyBoardBounds.size.height);
    _bottomView.frame = CGRectMake(0, viewH - keyBoardBounds.size.height - 44, viewW, 44);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self endEdit];
}

- (void)endEdit {
    _editButton.selected = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, 0, viewW, viewH);
        self.collectionView.frame = CGRectMake(0, viewH, viewW, 216);
        self.bottomView.frame = CGRectMake(0, viewH - 44, viewW, 44);
        
    }];
}

- (void)edit:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self.view endEditing:NO];
        
        if (!self.collectionView) {
            //宽度固定,计算空隙的总宽
            CGFloat viewWidth = Screen_W - emoteColumn * emoteWidth;
            //计算能否除尽
            CGFloat offsetW = (NSInteger)viewWidth % (emoteColumn + 1);
            CGFloat pointX = (offsetW == 0) ? 0 : (emoteColumn - offsetW) / 2;
            CGFloat space = (offsetW == 0) ? 0 : 1;
            CGFloat spaceW = (viewWidth - offsetW) / (emoteColumn + 1) + space;
            _spaceW = spaceW;
            
            UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//            flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            flowLayout.itemSize = CGSizeMake(emoteWidth, emoteWidth);
            flowLayout.sectionInset = UIEdgeInsetsMake(spaceW, spaceW - pointX, spaceW, spaceW - pointX);
            flowLayout.minimumInteritemSpacing = spaceW;
            flowLayout.minimumLineSpacing = spaceW;
            
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                 collectionViewLayout:flowLayout];
            _collectionView.backgroundColor = [UIColor whiteColor];
//            _collectionView.pagingEnabled = YES;
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
            
            [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
            [self.view addSubview:self.collectionView];
        }
        
        CGFloat emoteH = (_spaceW + emoteWidth) * 4 + emoteWidth;
        self.bottomView.frame = CGRectMake(0, viewH - 44 - emoteH, viewW, 44);
        self.collectionView.frame = CGRectMake(0, viewH - emoteH, viewW, emoteH);
        
    } else {
        [self endEdit];
    }
}

#pragma mark
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = [cell viewWithTag:111];
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.tag = 111;
        [cell.contentView addSubview:imageView];
    }
    
    NSString *name = [NSString stringWithFormat:@"%03ld@2x",indexPath.item + 1];
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png" inDirectory:@"EmoticonQQ.bundle"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:data];
    
    imageView.image = image;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableAttributedString *attM = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    
    NSString *name = [NSString stringWithFormat:@"%03ld@2x",indexPath.item + 1];
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif" inDirectory:@"EmoticonQQ.bundle"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    YYImage *image = [YYImage imageWithData:data scale:2];
    image.preloadAllAnimatedImageFrames = YES;
    
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    imageView.bounds = CGRectMake(0, 0, 20, 20);
//    imageView.autoPlayAnimatedImage = NO;
    
    NSMutableAttributedString *attactmentString = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:_emoteFont alignment:YYTextVerticalAlignmentCenter];
    [attM appendAttributedString:attactmentString];
    
    [attM setYy_font:_emoteFont];
    _textView.attributedText = attM;
}

#pragma mark
- (void)textViewDidBeginEditing:(YYTextView *)textView {
    _editButton.selected = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
