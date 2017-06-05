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

@end

@implementation SceneRainView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        viewW = CGRectGetWidth(frame);
        viewH = CGRectGetHeight(frame);
        
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.sceneView = [[SCNView alloc] initWithFrame:self.bounds];
    self.sceneView.backgroundColor = [UIColor clearColor];
    self.sceneView.autoenablesDefaultLighting = YES;
//    self.sceneView.showsStatistics = YES;
    self.sceneView.allowsCameraControl = YES;//方便调试
    [self addSubview:self.sceneView];
    
    self.scene = [SCNScene scene];
    SCNNode *cameraNode = [SCNNode node];
    SCNCamera *camera = [SCNCamera camera];
    camera.yFov = 90;//
    cameraNode.camera = camera;
    cameraNode.position = SCNVector3Make(0, 0, 5);
    [self.scene.rootNode addChildNode:cameraNode];
    
    self.sceneView.scene = self.scene;
    
    SCNGeometry *sphere = [SCNSphere sphereWithRadius:1.0];
    sphere.firstMaterial.diffuse.contents = [UIImage imageNamed:@"earthSurface.jpg"];
    SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
    [self.scene.rootNode addChildNode:sphereNode];
    
    SCNAction *action = [SCNAction repeatActionForever:[SCNAction rotateByX:0 y:M_PI_2 z:0 duration:0.5]];
    [sphereNode runAction:action];
}

@end
