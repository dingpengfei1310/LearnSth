//
//  GameViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/22.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@property (nonatomic, strong) UIView *gameView;
@property (nonatomic, strong) UIView *pointView;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) CGFloat pointRadiu;
@property (nonatomic, assign) CFTimeInterval pointAppearTime;

@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, assign) NSInteger score;

@property (nonatomic, assign) NSInteger totalCount;
@property (nonatomic, assign) NSInteger pointCount;
@property (nonatomic, assign) BOOL isGaming;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Game";
    
    _pointRadiu = 20;
    _pointAppearTime = 1.0;
    _totalCount = 15;
    
    [self initSubView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(beginGame)];
}

- (void)initSubView {
    CGFloat viewW = self.view.frame.size.width;
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 64, viewW * 0.5 - 10, 30)];
    _scoreLabel.text = [NSString stringWithFormat:@"分数:0"];
    [self.view addSubview:_scoreLabel];
    
    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewW * 0.5, 64, viewW * 0.5 - 10, 30)];
    _stateLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_stateLabel];
    
    _gameView = [[UIView alloc] initWithFrame:CGRectMake(0, 94, viewW, viewW)];
    _gameView.backgroundColor = KBackgroundColor;
    [self.view addSubview:_gameView];
    
    _pointView = [[UIView alloc] init];
    _pointView.backgroundColor = KBaseBlueColor;
    _pointView.layer.cornerRadius = 10;
    _pointView.hidden = YES;
    [_gameView addSubview:_pointView];
}

#pragma mark
- (void)beginGame {
    if (!_isGaming) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(frameChange)];
        _displayLink.frameInterval = _pointAppearTime * 60;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        _pointView.hidden = NO;
        _isGaming = YES;
        _stateLabel.text = @"游戏中";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(beginGame)];
    } else {
        [self stopGame];
    }
}

- (void)frameChange {
    if (_pointCount >= _totalCount) {
        [self stopGame];
        _stateLabel.text = nil;
        
        NSString *message = [NSString stringWithFormat:@"您的得分为:%ld",_score];
        [self showAlertWithTitle:@"游戏结束" message:message operationTitle:@"确定" operation:^{
            _pointCount = 0;
            _score = 0;
            _scoreLabel.text = [NSString stringWithFormat:@"分数:0"];
        }];
    } else {
        _pointView.hidden = NO;
        int centerX = _gameView.frame.size.width - _pointRadiu;
        NSInteger pointX = arc4random() % centerX;
        NSInteger pointY = arc4random() % centerX;
        
        _pointView.frame = CGRectMake(pointX, pointY, _pointRadiu, _pointRadiu);
        _pointCount++;
    }
}

- (void)stopGame {
    [_displayLink invalidate];
    _displayLink = nil;
    
    _pointView.hidden = YES;
    _isGaming = NO;
    _stateLabel.text = @"暂停中";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(beginGame)];
}

#pragma mark
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.tapCount > 1) {
        return;
    }
    CGPoint point = [touch locationInView:_gameView];
    if (point.x >=0 && point.y >= 0) {
        if (CGRectContainsPoint(_pointView.frame, point)) {
            _score++;
            _scoreLabel.text = [NSString stringWithFormat:@"分数:%ld",_score];
            _pointView.hidden = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
