//
//  LightSpotView.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/11/7.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "LightSpotView.h"

@interface LightSpotView () {
    CGFloat width;
    CGFloat height;
}

@property (nonatomic, strong) NSArray *positionArray;

@end

CGFloat const BACKGROUND_ALPHA = 0.7;

@implementation LightSpotView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        CGPoint point =  CGPointMake(100, 100);
        _positionArray = @[[NSValue valueWithCGPoint: point]];
        
        width = CGRectGetWidth(frame);
        height = CGRectGetHeight(frame);
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self lightSpotWithRect:rect];
}

- (void)lightSpotWithRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGPoint center = CGPointMake(width * 0.5, height * 0.5);
    
    CGFloat compoents[12] = {
        248.0/255.0,86.0/255.0,86.0/255.0,1,
        249.0/255.0,127.0/255.0,127.0/255.0,1.0,
        1.0,1.0,1.0,1.0
    };
    CGFloat locatiobs[3] = {0.0,0.5,1.0};
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpace, compoents, locatiobs, 3);
    
//    CGContextDrawLinearGradient(context, gradientRef, CGPointMake(0, 0), CGPointMake(20, 20), kCGGradientDrawsBeforeStartLocation);
    
    CGContextDrawRadialGradient(context, gradientRef, center, 0, center, width * 0.4,kCGGradientDrawsBeforeStartLocation);
    
    CGColorSpaceRelease(colorSpace);
}

-(void)_background:(CGRect)rect
{
    // context for drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGImageRef backgroundimage = CGBitmapContextCreateImage(context);
    CGContextClearRect(context, rect);
    //CGContextDrawImage(context, rect, backgroundimage);
    
    // save state
    CGContextSaveGState(context);
    
    // flip the context (right-sideup)
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //colors/components/locations
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat black[4] = {0.0,0.0,0.0,BACKGROUND_ALPHA};
    CGFloat white[4] = {1.0,1.0,1.0,1.0};//clear
    
    CGFloat components[8] = {
        
        white[0],white[1],white[2],white[3],
        black[0],black[1],black[2],black[3],
    };
    
    CGFloat colorLocations[2] = {0.25,0.5};
    
    // draw spotlights
    NSInteger spotlightCount = _positionArray.count;
    for (int i=0; i<spotlightCount; ++i)
    {
        // center and radius of spotlight
        CGPoint c = [[_positionArray objectAtIndex:i] CGPointValue];
//        CGFloat radius = [[_radiusArray objectAtIndex:i] floatValue];
        CGFloat radius = 10;
        
        //draw the shape
        CGMutablePathRef path = CGPathCreateMutable();
        //
        //draw a rect around view
        
        CGPathAddRect(path, NULL, CGRectMake(c.x - radius, c.y -radius,100,100));
        CGPathAddLineToPoint(path, NULL, c.x + radius, c.y - radius*2);
        CGPathAddLineToPoint(path, NULL, c.x + radius, c.y + radius*2);
        CGPathAddLineToPoint(path, NULL, c.x - radius, c.y + radius*2);
        CGPathAddLineToPoint(path, NULL, c.x - radius, c.y);
        CGPathAddLineToPoint(path, NULL, c.x, c.y);
        /*
         
         //draw a rectangle like spotlight --- i'll get to this later
         CGPathMoveToPoint(path, NULL, c.x-radius, c.y-radius);
         CGPathAddLineToPoint(path, NULL, c.x, c.y-radius);
         CGPathAddArcToPoint(path, NULL, c.x+radius, c.y-radius, c.x+radius, c.y, radius);
         CGPathAddArcToPoint(path, NULL, c.x+radius, c.y +radius, c.x , c.y+radius, radius);
         CGPathAddArcToPoint(path, NULL, c.x -radius, c.y + radius, c.x-radius, c.y, radius);
         CGPathAddArcToPoint(path, NULL, c.x-radius, c.y - radius, c.x, c.y-radius, radius);
         CGContextAddPath(context, path);
         CGContextClip(context);
         
         //fill with gradient
         CGContextDrawRadialGradient(context, gradientRef, c, 0.0f, c, _radius*2, 0);
         
         
         */
        CGContextSaveGState(context);
        
        CGContextAddPath(context, path);
        CGPathRelease(path);
        CGContextClip(context);
        
        //add gradient
        //create the gradient Ref
        CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorspace, components, colorLocations, 2);
        CGContextDrawRadialGradient(context, gradientRef, c, 0.0f, c, radius*2, 0);
        CGGradientRelease(gradientRef);
        
        CGContextRestoreGState(context);
    }
    
    CGColorSpaceRelease(colorspace);
    CGContextRestoreGState(context);
    
    //convert drawing to image for masking
    CGImageRef maskImage = CGBitmapContextCreateImage(context);
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskImage),
                                        CGImageGetHeight(maskImage),
                                        CGImageGetBitsPerComponent(maskImage),
                                        CGImageGetBitsPerPixel(maskImage),
                                        CGImageGetBytesPerRow(maskImage),
                                        CGImageGetDataProvider(maskImage), NULL, FALSE);
    
    
    //mask the background image
    CGImageRef masked = CGImageCreateWithMask(backgroundimage, mask);
    CGImageRelease(backgroundimage);
    //remove the spotlight gradient now that we have it as image
    CGContextClearRect(context, rect);
    
    //draw the transparent background with the mask
    CGContextDrawImage(context, rect, masked);
    
    CGImageRelease(maskImage);
    CGImageRelease(mask);
    CGImageRelease(masked);
}

@end
