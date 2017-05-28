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
//@property (nonatomic, strong) SCNNode *eyeNode;

@property (nonatomic, strong) SCNNode *bossNode;

@property (nonatomic, assign) CGPoint lastPanPoint;

@end

@implementation SceneGameView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        viewW = CGRectGetWidth(frame);
        viewH = CGRectGetHeight(frame);
        
        [self initialize];
        
        [self addSomeGestures];
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
    
//    _eyeNode = [SCNNode node];
//    _eyeNode.camera = [SCNCamera camera];
//    _eyeNode.camera.automaticallyAdjustsZRange = YES;
//    
//    [self.scene.rootNode addChildNode:_eyeNode];//将创建的原子节点添加到根节点
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

- (void)addSomeGestures {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    [self addGestureRecognizer:singleTapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureRecognizer:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizer:)];
    [self addGestureRecognizer:pinchGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
//    U *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
//    tapGesture.numberOfTapsRequired = 2;
//    [self addGestureRecognizer:tapGesture];
}

- (void)addModelFile {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"boss_attack" withExtension:@"dae"];
    
    SCNScene *scene = [SCNScene sceneWithURL:url options:nil error:nil];
    SCNNode *node = scene.rootNode;
    _bossNode = node;
    node.name = @"boss";
    node.position = SCNVector3Make(0, 0, -8000);
    [self.sceneView.scene.rootNode addChildNode:node];
}

#pragma mark
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan {
    UIGestureRecognizerState state = pan.state;
    CGPoint point = [pan locationInView:self];
    
    if (state == UIGestureRecognizerStateBegan) {
        self.lastPanPoint = point;
    } else if (state == UIGestureRecognizerStateChanged) {
        SCNVector3 vector = self.bossNode.eulerAngles;
        
        vector.z = atan((point.x - viewW * 0.5) / (point.y - viewH * 0.5));
        if (point.y - viewH * 0.5 < 0) {
            vector.z += M_PI;
        }
        
        self.bossNode.eulerAngles = vector;
        self.lastPanPoint = point;
    }
}

- (void)pinchGestureRecognizer:(UIPinchGestureRecognizer *)pinch {
    if (pinch.state == UIGestureRecognizerStateChanged) {
        SCNVector3 vector = self.bossNode.position;
        
        if (pinch.scale >= 1.0) {
            vector.z = vector.z + 200 * pinch.scale;
        } else {
            vector.z = vector.z - 200 * pinch.scale;
        }
        
        vector.z = MIN(-5000, MAX(-10000, vector.z));
        self.bossNode.position = vector;
    }
}

- (void)doubleTapGestureRecognizer:(UITapGestureRecognizer *)tap {
    self.bossNode.eulerAngles = SCNVector3Make(0, 0, 0);
}

- (void)singleTapGestureRecognizer:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    //
    SCNVector3 vector = self.bossNode.eulerAngles;
    vector.x = point.x;
    vector.y = point.y / viewH;
    self.bossNode.eulerAngles = vector;
    
    //
//    CGFloat rotationX = (point.y - viewH * 0.5) / viewH * 0.5;
//    CGFloat rotationY = (point.x - viewW * 0.5) / viewW * 0.5;
//    self.bossNode.rotation = SCNVector4Make(rotationX, rotationY, 0, 2);
}

@end
