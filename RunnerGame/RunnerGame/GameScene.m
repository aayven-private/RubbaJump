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

static int kMaxJumpCount = 1;

@interface GameScene()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) ContactManager *contactManager;

@property (nonatomic) Runner *runner;
@property (nonatomic) Ground *ground;

@property (nonatomic) int jumpCount;

@property (nonatomic) SKEmitterNode *emitter;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = kObjectCategoryFrame;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.friction = 0.0f;
        self.physicsBody.restitution = 0.0f;
        self.scaleMode = SKSceneScaleModeAspectFit;
        //self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        self.contactManager = [[ContactManager alloc] initWithDelegate:self];
        self.physicsWorld.contactDelegate = self.contactManager;
        
        self.jumpCount = 0;
    }
    return self;
}

-(void)initEnvironment
{
    NSLog(@"SF: %f", self.view.contentScaleFactor);
    SKShapeNode *groundLine = [SKShapeNode node];
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, 0.0, 100.0);
    CGPathAddLineToPoint(pathToDraw, NULL, self.size.width, 100.0);
    groundLine.path = pathToDraw;
    [groundLine setStrokeColor:[UIColor blackColor]];
    [self addChild:groundLine];
    CGPathRelease(pathToDraw);
    
    self.runner = [[Runner alloc] initWithTexture:[SKTexture textureWithImageNamed:@"square"]];
    self.ground = [[Ground alloc] initWithSize:CGSizeMake(self.size.width * self.view.contentScaleFactor, 100.0 * self.view.contentScaleFactor)];
    
    self.runner.position = CGPointMake(80 + self.runner.size.width / 2.0, 100 + self.runner.size.height / 2.0);
    self.ground.position = CGPointMake(0, 100.0);
    
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"SliderEffect" ofType:@"sks"];
    self.emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.emitter.particleBirthRate = 40;
    self.emitter.position = CGPointMake(83, 104);
    
    [self addChild:self.ground];
    [self addChild:self.runner];
    [self addChild:self.emitter];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_jumpCount < kMaxJumpCount) {
        [self.runner.physicsBody applyImpulse:CGVectorMake(0, 5000.0)];
        [self.runner.physicsBody applyAngularImpulse:-0.66];
        _jumpCount++;
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    [self runAction:[SKAction runBlock:^{
        //self.runner.zRotation = 0;
        self.runner.physicsBody.velocity = CGVectorMake(0, self.runner.physicsBody.velocity.dy);
    }]];
    
}

-(void)runnerJumped
{
    _emitter.particleBirthRate = 0;
}

-(void)runnerLanded
{
    NSLog(@"Pos: %@", NSStringFromCGPoint(self.runner.position));
    _jumpCount = 0;
    _emitter.particleBirthRate = 150;
    [self runAction:[SKAction runBlock:^{
        self.runner.zRotation = 0;
        self.runner.position = CGPointMake(80 + self.runner.size.width / 2.0, 100 + self.runner.size.height / 2.0);
    }]];
}

@end
