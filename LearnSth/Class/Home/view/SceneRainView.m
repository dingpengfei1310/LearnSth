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
    cameraNode.position = SCNVector3Make(0, 5, 10);
    [self.scene.rootNode addChildNode:cameraNode];
    
    self.sceneView.scene = self.scene;
    
    SCNGeometry *geometry = [SCNSphere sphereWithRadius:0.5];
    geometry.firstMaterial.diffuse.contents = [UIColor greenColor];
    geometry.firstMaterial.normal.contents = [UIImage imageNamed:@"mybricks1_AO"];
    SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
    [self.scene.rootNode addChildNode:geometryNode];
}

- (SCNNode *)geometryNode {
    SCNGeometry *geometry;
    
    NSInteger shapeType = 0;
    shapeType = arc4random() % 8;
    
    switch (shapeType) {
        case 0:
            geometry = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0];
            break;
        case 1:
            geometry = [SCNSphere sphereWithRadius:0.5];
            break;
        case 2:
            geometry = [SCNPyramid pyramidWithWidth:1 height:1 length:1];
            break;
        case 3:
            geometry = [SCNTorus torusWithRingRadius:0.5 pipeRadius:0.25];
            break;
        case 4:
            geometry = [SCNCapsule capsuleWithCapRadius:0.3 height:2.5];
            break;
        case 5:
            geometry = [SCNCylinder cylinderWithRadius:0.3 height:2.5];
            break;
        case 6:
            geometry = [SCNCone coneWithTopRadius:0.25 bottomRadius:0.5 height:1.0];
            break;
        case 7:
            geometry = [SCNTube tubeWithInnerRadius:0.25 outerRadius:0.5 height:1.0];
            break;
        default:
            break;
    }
    UIColor *color = [self randomColor];
    geometry.firstMaterial.diffuse.contents = color;
    
    
    SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
    geometryNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
//    [geometryNode addParticleSystem:[self particleSystemWithColor:color geometry:geometry]];
    
    NSInteger randomI = arc4random();
    float randomX = (randomI % 40 - 20) * 0.1;
    float randomY = (randomI % 80 + 100) * 0.1;
    
    SCNVector3 force = SCNVector3Make(randomX, randomY, 0);
    SCNVector3 position = SCNVector3Make(0.05, 0.05, 0.05);
    [geometryNode.physicsBody applyForce:force atPosition:position impulse:YES];
    
    return geometryNode;
}

- (UIColor *)randomColor {
    UIColor *color;
    
    NSInteger colorNum = 0;
    colorNum = arc4random() % 8;
    
    switch (colorNum) {
        case 0:
            color = [UIColor blueColor];
            break;
        case 1:
            color = [UIColor whiteColor];
            break;
        case 2:
            color = [UIColor redColor];
            break;
        case 3:
            color = [UIColor yellowColor];
            break;
        case 4:
            color = [UIColor greenColor];
            break;
        case 5:
            color = [UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1.0];
            break;
        case 6:
            color = [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:1.0];
            break;
        case 7:
            color = [UIColor colorWithRed:0.5 green:0.5 blue:0 alpha:1.0];
            break;
        default:
            break;
    }
    
    return color;
}

- (SCNParticleSystem *)particleSystemWithColor:(UIColor *)color geometry:(SCNGeometry *)geometry {
    SCNParticleSystem *par = [SCNParticleSystem particleSystemNamed:@"Rain.scnp" inDirectory:nil];
    par.particleColor = color;
    par.emitterShape = geometry;
    return par;
}

#pragma mark
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touche = touches.anyObject;
    CGPoint location = [touche locationInView:self.sceneView];
    
    NSArray *hitResults = [self.sceneView hitTest:location options:nil];
    if (hitResults.count > 0) {
        SCNHitTestResult *result = hitResults.firstObject;
        SCNNode *node = result.node;
        [self createExplosionGeometry:node.geometry
                             position:node.presentationNode.position
                             rotation:node.presentationNode.rotation];
    }
}

- (void)createExplosionGeometry:(SCNGeometry *)geometry position:(SCNVector3)position rotation:(SCNVector4)rotation {
    SCNParticleSystem *explode = [SCNParticleSystem particleSystemNamed:@"Explode.scnp" inDirectory:nil];
    explode.emitterShape = geometry;
    
    explode.particleColor = geometry.firstMaterial.diffuse.contents;
    
    SCNMatrix4 rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z);
    SCNMatrix4 translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z);
    SCNMatrix4 transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix);
    [self.scene addParticleSystem:explode withTransform:transformMatrix];
}

@end
