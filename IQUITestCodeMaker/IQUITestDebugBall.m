//
//  IQUITestDebugBall.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugBall.h"
#import "IQUITestDebugTable.h"

@interface IQUITestDebugBall ()

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) IQUITestDebugTable *debugTable;

@end

@implementation IQUITestDebugBall

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(debugBallTap) forControlEvents:UIControlEventTouchUpInside];
        [self addGestureRecognizer:self.pan];
    }
    return self;
}

- (void)debugBallTap {
    self.hidden = YES;
    __weak typeof(self)weakSelf = self;
    [self.debugTable showDebugView];
    self.debugTable.debugBlock = ^{
        weakSelf.hidden = NO;
    };
}

- (void)dragMove:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:self];
        CGFloat stopX = (self.center.x + translation.x);
        CGFloat stopY = (self.center.y + translation.y);
        if (stopX <= 40 || stopX >= ([[UIScreen mainScreen] bounds].size.width - 40) || stopY <=40 || stopY>= ([[UIScreen mainScreen] bounds].size.height - 40)) {
            return;
        }
        self.center = CGPointMake(stopX, stopY);
        [panGestureRecognizer setTranslation:CGPointZero inView:self];
    }
}

- (void)drawRect:(CGRect)rect {
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    CAShapeLayer *pulseLayer = [CAShapeLayer layer];
    pulseLayer.frame = self.layer.bounds;
    pulseLayer.path = [UIBezierPath bezierPathWithOvalInRect:pulseLayer.bounds].CGPath;
    pulseLayer.fillColor = [UIColor purpleColor].CGColor;
    pulseLayer.opacity = 0.0;
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = self.bounds;
    replicatorLayer.instanceCount = 4;
    replicatorLayer.instanceDelay = 1;
    [replicatorLayer addSublayer:pulseLayer];
    [self.layer addSublayer:replicatorLayer];
    
    CABasicAnimation *opacityAnima = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnima.fromValue = @(0.3);
    opacityAnima.toValue = @(0.0);
    
    CABasicAnimation *scaleAnima = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnima.fromValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 0.0, 0.0, 0.0)];
    scaleAnima.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1.0, 1.0, 0.0)];
    
    CAAnimationGroup *groupAnima = [CAAnimationGroup animation];
    groupAnima.animations = @[opacityAnima, scaleAnima];
    groupAnima.duration = 4.0;
    groupAnima.autoreverses = NO;
    groupAnima.repeatCount = HUGE;
    [pulseLayer addAnimation:groupAnima forKey:@"groupAnimation"];
}

#pragma mark--Getters & Setters--
- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragMove:)];
        
    }
    return _pan;
}

- (IQUITestDebugTable *)debugTable {
    if (!_debugTable) {
        _debugTable = [[IQUITestDebugTable alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        [[UIApplication sharedApplication].keyWindow addSubview:_debugTable];
    }
    return _debugTable;
}
@end
