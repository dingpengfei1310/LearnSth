//
//  SceneGameView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/26.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "SceneGameView.h"
//#import <CoreMotion/CoreMotion.h>

@interface SceneGameView () {
    CGFloat viewW;
    CGFloat viewH;
}

@property (nonatomic, strong) SCNView *sceneView;
@property (nonatomic, strong) SCNScene *scene;
@property (nonatomic, strong) SCNNode *eyeNode;

@property (nonatomic, assign) CGPoint lastPanPoint;

@end

@implementation SceneGameView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        viewW = CGRectGetWidth(frame);
        viewH = CGRectGetHeight(frame);
        
        [self initialize];
        
        [self addGesture];
        [self addModelFile];
    }
    return self;
}

- (void)initialize {
    
    self.sceneView = [[SCNView alloc] initWithFrame:self.bounds];
    self.sceneView.backgroundColor = [UIColor clearColor];
//    self.sceneView.allowsCameraControl = YES;//方便调试
    [self addSubview:self.sceneView];
    
    self.scene = [SCNScene scene];
//    SCNBox *box = [SCNBox boxWithWidth:10 height:100 length:100 chamferRadius:1];
//    SCNNode *node = [SCNNode nodeWithGeometry:box];
    
    _eyeNode = [SCNNode node];
    _eyeNode.camera = [SCNCamera camera];
    _eyeNode.camera.automaticallyAdjustsZRange = YES;
    
    [self.scene.rootNode addChildNode:_eyeNode];//将创建的原子节点添加到根节点
    self.sceneView.scene = self.scene;
    
    //重力感应
//    CMMotionManager *motionManager = [[CMMotionManager alloc] init];
//    motionManager.gyroUpdateInterval = 60;
//    motionManager.deviceMotionUpdateInterval = 1/30.0;
//    motionManager.showsDeviceMovementDisplay = YES;
//    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * motion, NSError * error) {
//        
//        CMAttitude *attitude = motion.attitude;
//        SCNVector3 vector = SCNVector3Zero;
//        
//        if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
//            vector.x = attitude.pitch;
//            vector.y = attitude.roll;
//        } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
//            vector.x = attitude.pitch;
//            vector.y = attitude.roll;
//        } else {
//            vector.x = attitude.pitch;
//            vector.y = attitude.roll;
//        }
//        vector.z = attitude.yaw;
//        self.eyeNode.eulerAngles = vector;
//    }];
}

- (void)addGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)addModelFile {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"boss_attack" withExtension:@"dae"];
    
    SCNScene *scene = [SCNScene sceneWithURL:url options:nil error:nil];
    SCNNode *node = scene.rootNode;
    node.position = SCNVector3Make(0, 0, -5000);
//    node.position = SCNVector3Make(100, -100, -2000);
    [self.sceneView.scene.rootNode addChildNode:node];
}

#pragma mark
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan {
    UIGestureRecognizerState state = pan.state;
    CGPoint point = [pan locationInView:self];
    
    if (state == UIGestureRecognizerStateBegan) {
        self.lastPanPoint = point;
    } else if (state == UIGestureRecognizerStateChanged) {
        SCNVector3 vector = self.eyeNode.eulerAngles;
        
//        vector.y += (point.x - self.lastPanPoint.x) / viewW * M_PI_4;
//        vector.x += (point.y - self.lastPanPoint.y) / (viewH - 64) * M_PI_4;
//        
//        vector.y = MAX(vector.y, -0.23);
//        vector.y = MIN(vector.y, 0.25);
//        
//        vector.x = MAX(vector.x, -0.5);
//        vector.x = MIN(vector.x, 0.46);
        
        vector.z = -atan((point.x - viewW * 0.5) / (point.y - viewH * 0.5));
        if (point.y - viewH * 0.5 < 0) {
            vector.z += M_PI;
        }
        
        self.eyeNode.eulerAngles = vector;
        
        self.lastPanPoint = point;
    }
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tap {
    self.eyeNode.eulerAngles = SCNVector3Make(0, 0, 0);
}

@end
