//
//  MyScene.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

@import AVFoundation;
#import "GameScene.h"
#import "Runner.h"
#import "Barrier.h"
#import "Ground.h"
#import "CommonTools.h"
#import "HighScoreHelper.h"
#import "HighScoreManager.h"

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
@property (nonatomic) int movingCount;

@property (nonatomic) BOOL isRunning;

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@end

@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        //self.randomSpawnInterval = [CommonTools getRandomFloatFromFloat:1.8 toFloat:2.0];
        
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
    
    self.isRunning = NO;
    
    self.jumpCount = 0;
    self.doubleJumpCount = 0;
    
    self.screenDiff = 960.0 / (self.size.width * self.view.contentScaleFactor);
    //NSLog(@"W: %f", self.size.width * self.view.contentScaleFactor);
    
    self.score = 0;
    self.difficulty = 1;
    
    self.rotationUnitPerSecond = 0.0;
    self.secondJumpHeight = 0.0;
    
    self.topCount = 0;
    self.bottomCount = 0;
    self.movingCount = 0;
    
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
    
    SKLabelNode *countDownLabel = [SKLabelNode labelNodeWithFontNamed:@"Verdana-Bold"];
    countDownLabel.fontColor = [UIColor blackColor];
    countDownLabel.fontSize = 25;
    countDownLabel.text = @"3";
    
    SKAction *ct1 = [SKAction group:@[[SKAction fadeInWithDuration:0.0], [SKAction scaleTo:1.0 duration:0.0], [SKAction runBlock:^{
        countDownLabel.text = @"2";
    }]]];
    
    SKAction *ct2 = [SKAction group:@[[SKAction fadeInWithDuration:0.0], [SKAction scaleTo:1.0 duration:0.0], [SKAction runBlock:^{
        countDownLabel.text = @"1";
    }]]];
    
    SKAction *ctGo = [SKAction group:@[[SKAction fadeInWithDuration:0.0], [SKAction scaleTo:1.0 duration:0.0], [SKAction runBlock:^{
        countDownLabel.text = @"GO!";
    }]]];
    
    SKAction *growAndFade = [SKAction group:@[[SKAction fadeOutWithDuration:1.0], [SKAction scaleTo:6.0 duration:1.0]]];
    
    /*SKAction *g1 = [SKAction group:@[changeText2, growAndFade]];
    SKAction *g2 = [SKAction group:@[changeText1, growAndFade]];
    SKAction *ggo = [SKAction group:@[changeTextStart, growAndFade]];*/
    
    SKAction *countDown = [SKAction sequence:@[growAndFade, ct1, growAndFade, ct2, growAndFade, ctGo, growAndFade]];
    
    countDownLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    countDownLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    countDownLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [countDownLabel runAction:countDown completion:^{
        self.isRunning = YES;
        self.randomSpawnInterval = 0.2;
    }];
    
    [self addChild:countDownLabel];
    
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"RJ_MusicLoop_A_v02-85195" withExtension:@"mp3"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
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
            [self runAction:[SKAction playSoundFileNamed:@"Blop_A_01.wav" waitForCompletion:NO]];
            _rotationUnitPerSecond = 0.0;
        } else {
            [self runAction:[SKAction playSoundFileNamed:@"Blop_D_01.wav" waitForCompletion:NO]];
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
    
    if (_lastSpawnTimeInterval > _randomSpawnInterval && _isRunning) {
        _lastSpawnTimeInterval = 0;
        _randomSpawnInterval = [CommonTools getRandomFloatFromFloat:0.5 * _screenDiff toFloat:0.7 * _screenDiff];
        [self addBarrier];
    }
    
}

-(void)addBarrier
{
    
    Barrier *barrier = [[Barrier alloc] initWithTexture:[SKTexture textureWithImageNamed:@"square"]];
    
    BOOL isBottom = (BOOL)[CommonTools getRandomNumberFromInt:0 toInt:1];
    
    if (_bottomCount == kBottomLimit) {
        _bottomCount = 0;
        isBottom = NO;
    }
    if (_topCount == kTopLimit) {
        _topCount = 0;
        isBottom = YES;
    }
    
    if (isBottom) {
        _bottomCount++;
        _topCount = 0;
        barrier.position = CGPointMake(self.size.width, kGroundHeight + barrier.size.height / 2.0);
    } else {
        _topCount++;
        _bottomCount = 0;
        
        if (barrier.isJumper && _movingCount <= kMovingLimit) {
            _movingCount++;
            
            float randomHeight = [CommonTools getRandomFloatFromFloat:30.0 toFloat:65.0];
            BOOL isStartingTop = (BOOL)[CommonTools getRandomNumberFromInt:0 toInt:1];
            
            barrier.position = CGPointMake(self.size.width, isStartingTop ? kGroundHeight + _runner.size.height + barrier.size.height / 2.0 + 2.0 + randomHeight : kGroundHeight - barrier.size.height / 2.0 - randomHeight);
            
            SKAction *stomp = [SKAction sequence:@[[SKAction moveToY:isStartingTop ? kGroundHeight - barrier.size.height / 2.0 - randomHeight : kGroundHeight + _runner.size.height + barrier.size.height / 2.0 + 2.0 + randomHeight duration:.6], [SKAction waitForDuration:0.15], [SKAction moveToY:isStartingTop ? kGroundHeight + _runner.size.height + barrier.size.height / 2.0 + 2.0 + randomHeight : kGroundHeight - barrier.size.height / 2.0 - randomHeight duration:.6], [SKAction waitForDuration:0.15]]];
            SKAction *moveAction = [SKAction repeatActionForever:stomp];
            //barrier.barrierSpeed += 150;
            [barrier runAction:moveAction];
        } else {
            _movingCount = 0;
            barrier.position = CGPointMake(self.size.width, kGroundHeight + _runner.size.height + barrier.size.height / 2.0 + 2.0);
        }
        //barrier.position = CGPointMake(self.size.width, self.size.height - 60.0 - barrier.size.height / 2.0);
    }
    
    barrier.physicsBody.velocity = CGVectorMake(barrier.barrierSpeed, 0);
    
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
    _emitter.particleBirthRate = 150;
    _rotationUnitPerSecond = 0.0;
    _secondJumpHeight = 0.0;
    self.runner.zRotation = 0;

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
        [_delegate gameOverWithScore:_score];
    }]]]];
}

@end
