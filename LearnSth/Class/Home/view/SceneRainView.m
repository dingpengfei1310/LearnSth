//
//  SceneRainView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/29.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "SceneRainView.h"
#import <SceneKit/SceneKit.h>

@interface SceneRainView () {
    CGFloat viewW;
    CGFloat viewH;
}

@property (nonatomic, strong) SCNView *sceneView;
@property (nonatomic, strong) SCNScene *scene;

@property (nonatomic, assign) CGFloat scale;

@end

@implementation SceneRainView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        viewW = CGRectGetWidth(frame);
        viewH = CGRectGetHeight(frame);
        _scale = 1.0;
        
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.sceneView = [[SCNView alloc] initWithFrame:self.bounds];
    self.sceneView.backgroundColor = [UIColor clearColor];
    self.sceneView.autoenablesDefaultLighting = YES;
//    self.sceneView.allowsCameraControl = YES;//方便调试
    [self addSubview:self.sceneView];
    
    self.scene = [SCNScene scene];
    self.sceneView.scene = self.scene;
    
    for (int x = 0; x < 100; x += 10) {
        for (int z = 0; z < 100; z += 10) {
            SCNNode *tree = [self tree];
            tree.position = SCNVector3Make(x, 0, z);
            tree.rotation = SCNVector4Make(0, 1, 0, M_PI * (arc4random() % 180 / 180.0));
            [self.scene.rootNode addChildNode:tree];
        }
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognizer:)];
    [self addGestureRecognizer:pinchGesture];
}

- (SCNNode *)tree {
    SCNCylinder *cylinder = [SCNCylinder cylinderWithRadius:1 height:3];
    cylinder.firstMaterial.diffuse.contents = [UIColor brownColor];
    SCNNode *tree = [SCNNode nodeWithGeometry:cylinder];
    
    for (int i = 1; i < 4; i++) {
        SCNNode *cone = [SCNNode nodeWithGeometry:[SCNCone coneWithTopRadius:0 bottomRadius:3 height:3]];
        cone.position = SCNVector3Make(0, i * 2 + 1, 0);
        cone.geometry.firstMaterial.diffuse.contents = [UIColor greenColor];
        [tree addChildNode:cone];
        
        SCNNode *present = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0]];
        present.geometry.firstMaterial.diffuse.contents = [UIColor blueColor];
        present.position = SCNVector3Make((i % 2) * 2, -1, (i / 2) * 2);
        [tree addChildNode:present];
    }
    
    SCNNode *node = [SCNNode node];
    [node addChildNode:tree];
    
    return node;
}

#pragma mark
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan {
    UIGestureRecognizerState state = pan.state;
    
    if (state == UIGestureRecognizerStateChanged) {
        CGPoint point = [pan locationInView:self];
        
        SCNMatrix4 scale = SCNMatrix4MakeScale(1, 1, _scale);
        SCNMatrix4 rotation = SCNMatrix4Rotate(scale, M_PI_4 * (point.y  - viewH * 0.5) / viewH, 1, 0, 0);
        self.scene.rootNode.transform = SCNMatrix4Rotate(rotation, M_PI_4 * (point.x  - viewW * 0.5) / viewW, 0, 1, 0);
    }
}

- (void)pinchGestureRecognizer:(UIPinchGestureRecognizer *)pinch {
    if (pinch.state == UIGestureRecognizerStateChanged) {
        self.scene.rootNode.transform = SCNMatrix4MakeScale(1, 1, pinch.scale);
        _scale = pinch.scale;
    }
}

@end
