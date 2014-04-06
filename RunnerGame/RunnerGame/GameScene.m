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

@property (nonatomic) NSTimeInterval expectedLandingTime;
@property (nonatomic) double rotationUnitPerSecond;

@property (nonatomic) float secondJumpHeight;

@property (nonatomic) int difficulty;
@property (nonatomic) int score;

@property (nonatomic) SKLabelNode *scoreLabel;

@property (nonatomic) BOOL isDead;

@property (nonatomic) float screenDiff;
@property (nonatomic) int doubleJumpCount;

@property (nonatomic) int topCount;
@property (nonatomic) int bottomCount;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        self.jumpCount = 0;
        self.doubleJumpCount = 0;
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
    self.isDead = NO;
    
    self.screenDiff = 960.0 / (self.size.width * self.view.contentScaleFactor);
    //NSLog(@"W: %f", self.size.width * self.view.contentScaleFactor);
    
    self.score = 0;
    self.difficulty = 1;
    
    self.rotationUnitPerSecond = 0.0;
    self.secondJumpHeight = 0.0;
    
    self.topCount = 0;
    self.bottomCount = 0;
    
    //NSLog(@"Frame: %@", NSStringFromCGRect(self.frame));
    
    SKShapeNode *groundLine = [SKShapeNode node];
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, 0.0, kGroundHeight);
    CGPathAddLineToPoint(pathToDraw, NULL, self.size.width, kGroundHeight);
    groundLine.path = pathToDraw;
    [groundLine setStrokeColor:[UIColor blackColor]];
    [self addChild:groundLine];
    CGPathRelease(pathToDraw);
    
    SKShapeNode *topLine = [SKShapeNode node];
    CGMutablePathRef pathToDraw_top = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw_top, NULL, 0.0, self.size.height - 60.0);
    CGPathAddLineToPoint(pathToDraw_top, NULL, self.size.width, self.size.height - 60.0);
    topLine.path = pathToDraw_top;
    [topLine setStrokeColor:[UIColor blackColor]];
    [self addChild:topLine];
    CGPathRelease(pathToDraw_top);
    
    self.runner = [[Runner alloc] initWithTexture:[SKTexture textureWithImageNamed:@"runner"]];
    self.ground = [[Ground alloc] initWithSize:CGSizeMake(self.size.width * self.view.contentScaleFactor + 50.0, kGroundHeight * self.view.contentScaleFactor)];
    
    self.runner.position = CGPointMake(80 + self.runner.size.width / 2.0, kGroundHeight + self.runner.size.height / 2.0);
    self.ground.position = CGPointMake(0, 0);
    
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"SliderEffect" ofType:@"sks"];
    self.emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    self.emitter.particleBirthRate = 40;
    self.emitter.position = CGPointMake(81, kGroundHeight + 2.0);
    
    [self addChild:self.ground];
    [self addChild:self.runner];
    [self addChild:self.emitter];
    
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.scoreLabel.position = CGPointMake(self.size.width - 30.0, self.size.height - 30.0);
    self.scoreLabel.fontSize = 18.0;
    self.scoreLabel.fontColor = [UIColor blackColor];
    self.scoreLabel.text = @"0";
    [self addChild:self.scoreLabel];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _runner.isJumping = YES;
    _runner.physicsBody.contactTestBitMask = kObjectCategoryBarrier | kObjectCategoryGround;
    if (_jumpCount < kMaxJumpCount) {
        _jumpCount++;
        
        self.runner.physicsBody.velocity = CGVectorMake(0, 0);
        [self.runner.physicsBody applyImpulse:CGVectorMake(0, 8000)];
        
        if (self.runner.position.y < kGroundHeight + self.runner.size.height / 2.0 + 10.0) {
            _jumpCount = 1;
        }
        if (self.runner.physicsBody.velocity.dy == 0.0) {
            _jumpCount = 1;
        }
        
        if (_jumpCount == 1) {
            _rotationUnitPerSecond = 0.0;
        } else {
            _secondJumpHeight = self.runner.position.y - 5.0;
            
            _expectedLandingTime = 2.0 * (self.runner.physicsBody.velocity.dy / fabs(self.runner.suggestedGravity.dy));
            
            if (_doubleJumpCount == 2) {
                _doubleJumpCount = -1;
                _rotationUnitPerSecond =  -M_PI / (_expectedLandingTime * 4.0);
            } else {
                _rotationUnitPerSecond =  M_PI / (_expectedLandingTime * 4.0);
            }
        }
    }
}

- (void)update:(NSTimeInterval)currentTime
{
    for (SKSpriteNode *node in self.children) {
        if (node.position.x < 0) {
            [node removeFromParent];
            if (!_isDead) {
                self.score++;
                self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
                if (_score % 10 == 0) {
                    _difficulty++;
                }
            }
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
    if (_secondJumpHeight != 0.0 && _secondJumpHeight - 20.0 < _runner.position.y && _runner.position.y < _secondJumpHeight) {
        _runner.zRotation = 0.0;
        _rotationUnitPerSecond = 0.0;
    }
    
    if (_rotationUnitPerSecond != 0.0) {
        self.runner.zRotation -= timeSinceLast * _rotationUnitPerSecond;
    }
    
    if (_lastSpawnTimeInterval > _randomSpawnInterval) {
        _lastSpawnTimeInterval = 0;
        _randomSpawnInterval = [CommonTools getRandomFloatFromFloat:0.5 * _screenDiff toFloat:0.7 * _screenDiff];
        [self addBarrier];
    }
    
}

-(void)addBarrier
{
    
    Barrier *barrier = [[Barrier alloc] initWithTexture:[SKTexture textureWithImageNamed:@"square"]];
    
    int boolInt = [CommonTools getRandomNumberFromInt:0 toInt:1];
    
    NSLog(@"Bottom in a row: %d", _bottomCount);
    
    if (_bottomCount == kBottomLimit) {
        _bottomCount = 0;
        boolInt = 0;
    }
    if (_topCount == kTopLimit) {
        _topCount = 0;
        boolInt = 1;
    }
    
    if ((BOOL)boolInt) {
        _bottomCount++;
        _topCount = 0;
        barrier.position = CGPointMake(self.size.width, kGroundHeight + barrier.size.height / 2.0);
    } else {
        _topCount++;
        _bottomCount = 0;
        barrier.position = CGPointMake(self.size.width, kGroundHeight + _runner.size.height + barrier.size.height / 2.0 + 2.0);
    }
    
    //barrier.speed = barrier.speed
    
    barrier.physicsBody.velocity = CGVectorMake(barrier.speed, 0);
    [self addChild:barrier];
    
    
}

-(void)runnerJumped
{
    _emitter.particleBirthRate = 0;
}

-(void)runnerLanded
{
    if (_jumpCount == kMaxJumpCount) {
        _doubleJumpCount++;
    } else {
        _doubleJumpCount = 0;
    }
    
    _jumpCount = 0;
    _runner.isJumping = NO;
    _runner.physicsBody.contactTestBitMask = kObjectCategoryBarrier;
    _emitter.particleBirthRate = 150;
    _rotationUnitPerSecond = 0.0;
    _secondJumpHeight = 0.0;
    self.runner.zRotation = 0;
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
    _isDead = YES;
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
