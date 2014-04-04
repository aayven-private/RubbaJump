//
//  MyScene.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "GameScene.h"
#import "Runner.h"
#import "Barrier.h"
#import "Ground.h"
#import "CommonTools.h"

@interface GameScene()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) ContactManager *contactManager;

@property (nonatomic) Runner *runner;
@property (nonatomic) Ground *ground;

@property (nonatomic) int jumpCount;

@property (nonatomic) SKEmitterNode *emitter;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval randomSpawnInterval;

@property (nonatomic) CGVector selectiveGravity;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        self.jumpCount = 0;
        self.randomSpawnInterval = [CommonTools getRandomFloatFromFloat:1.8 toFloat:2.0];
        
        self.selectiveGravity = CGVectorMake(0, -9.8 * kPpm);
    }
    return self;
}

-(void)initEnvironment
{
    [self removeAllChildren];
    self.contactManager = [[ContactManager alloc] initWithDelegate:self];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self.contactManager;
    self.physicsBody.categoryBitMask = kObjectCategoryFrame;
    self.physicsBody.contactTestBitMask = 0;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.friction = 0.0f;
    self.physicsBody.restitution = 0.0f;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.scaleMode = SKSceneScaleModeAspectFill;
    
    //NSLog(@"Frame: %@", NSStringFromCGRect(self.frame));
    
    SKShapeNode *groundLine = [SKShapeNode node];
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, 0.0, 100.0);
    CGPathAddLineToPoint(pathToDraw, NULL, self.size.width, 100.0);
    groundLine.path = pathToDraw;
    [groundLine setStrokeColor:[UIColor blackColor]];
    [self addChild:groundLine];
    CGPathRelease(pathToDraw);
    
    self.runner = [[Runner alloc] initWithTexture:[SKTexture textureWithImageNamed:@"runner"]];
    self.ground = [[Ground alloc] initWithSize:CGSizeMake(self.size.width * self.view.contentScaleFactor + 50.0, 100.0 * self.view.contentScaleFactor)];
    
    self.runner.position = CGPointMake(80 + self.runner.size.width / 2.0, 100 + self.runner.size.height / 2.0 + 3);
    self.ground.position = CGPointMake(0, 0);
    
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"SliderEffect" ofType:@"sks"];
    self.emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.emitter.particleBirthRate = 40;
    self.emitter.position = CGPointMake(81, 102);
    
    [self addChild:self.ground];
    [self addChild:self.runner];
    [self addChild:self.emitter];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _runner.isJumping = YES;
    _runner.physicsBody.contactTestBitMask = kObjectCategoryBarrier | kObjectCategoryGround;
    if (_jumpCount < kMaxJumpCount) {
        [self.runner.physicsBody applyImpulse:CGVectorMake(0, 8000)];
        [self.runner.physicsBody applyAngularImpulse:-0.95];
        
        _jumpCount++;
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    for (SKSpriteNode *node in self.children) {
        if (node.position.x < 0) {
            [node removeFromParent];
        } else {
            if ([node isKindOfClass:[GameObject class]]) {
                if (((GameObject *)node).hasOwnGravity) {
                    CGVector ownGravity = ((GameObject *)node).suggestedGravity;
                    [node.physicsBody applyForce:ownGravity];
                } else if (((GameObject *)node).isAffectedBySelectiveGravity) {
                    [node.physicsBody applyForce:CGVectorMake(node.physicsBody.mass * _selectiveGravity.dx, node.physicsBody.mass * _selectiveGravity.dy)];
                }
            }
        }
    }
    CFTimeInterval timeSinceLast = currentTime - _lastUpdateTimeInterval;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
    }
    _lastUpdateTimeInterval = currentTime;
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    _lastSpawnTimeInterval += timeSinceLast;
    
    if (_lastSpawnTimeInterval > _randomSpawnInterval) {
        _lastSpawnTimeInterval = 0;
        _randomSpawnInterval = [CommonTools getRandomFloatFromFloat:0.5 toFloat:0.7];
        //[self addBarrier];
    }
    
}

-(void)addBarrier
{
    Barrier *barrier = [[Barrier alloc] initWithTexture:[SKTexture textureWithImageNamed:@"square"]];
    
    int boolInt = [CommonTools getRandomNumberFromInt:0 toInt:1];
    if ((BOOL)boolInt) {
        barrier.position = CGPointMake(self.size.width, 100.0 + barrier.size.height / 2.0);
    } else {
        barrier.position = CGPointMake(self.size.width, 100.0 + _runner.size.height + barrier.size.height / 2.0 + 2);
    }
    
    barrier.physicsBody.velocity = CGVectorMake(barrier.speed, 0);
    [self addChild:barrier];
    
    
}

-(void)runnerJumped
{
    _emitter.particleBirthRate = 0;
}

-(void)runnerLanded
{
    _jumpCount = 0;
    _runner.isJumping = NO;
    _runner.physicsBody.contactTestBitMask = kObjectCategoryBarrier;
    _emitter.particleBirthRate = 150;
    //self.runner.zRotation = 0;
    //self.runner.position = CGPointMake(80 + self.runner.size.width / 2.0, 100 + self.runner.size.height / 2.0);
    //self.runner.position = CGPointMake(80 + self.runner.size.width / 2.0, 100 + self.runner.size.height / 2.0);

}

-(void)barrierLanded:(Barrier *)barrier
{
    if (barrier.isJumper) {
        [barrier.physicsBody applyImpulse:CGVectorMake(0, barrier.impulse)];
    }
}

-(void)barrierCollidedWithRunner
{
    NSString *boomPath = [[NSBundle mainBundle] pathForResource:@"BoomEffect" ofType:@"sks"];
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:boomPath];
    emitter.position = _runner.position;
    [_runner removeFromParent];
    _emitter.particleBirthRate = 0;
    SKAction *boom = [SKAction runBlock:^{
        [_runner removeFromParent];
        [self addChild:emitter];
    }];
    
    [self runAction:[SKAction sequence:@[boom, [SKAction waitForDuration:2.0], [SKAction runBlock:^{
        [self initEnvironment];
    }]]]];
}

@end
