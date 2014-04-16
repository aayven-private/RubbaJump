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
#import "StatisticsHelper.h"
#import "HighScoreIndicator.h"

@interface GameScene()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) ContactManager *contactManager;

@property (nonatomic) Runner *runner;
@property (nonatomic) Ground *ground;

@property (nonatomic) int jumpCount;

@property (nonatomic) SKEmitterNode *emitter;

//@property (nonatomic) SKEmitterNode *rainEmitter;
//@property (nonatomic) SKEmitterNode *rainDropEmitter;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval randomSpawnInterval;

@property (nonatomic) CGVector selectiveGravity;

@property (nonatomic) NSTimeInterval expectedLandingTime;
@property (nonatomic) double rotationUnitPerSecond;

@property (nonatomic) float secondJumpHeight;

@property (nonatomic) int difficulty;
@property (nonatomic) int score;
@property (nonatomic) float distance;

@property (nonatomic) SKLabelNode *scoreLabel;

@property (nonatomic) BOOL isDead;

@property (nonatomic) float screenDiff;
@property (nonatomic) int doubleJumpCount;
@property (nonatomic) int madJumpCount;
@property (nonatomic) int veryMadJumpCount;

@property (nonatomic) int topCount;
@property (nonatomic) int bottomCount;
@property (nonatomic) int movingCount;

@property (nonatomic) BOOL isRunning;

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@property (nonatomic) float particleBirthRate;

@property (nonatomic) NSString *runnerMood;
@property (nonatomic) BOOL needABreak;

@property (nonatomic) SKTexture *barrierTexture;
@property (nonatomic) SKTexture *starTexture;

@property (nonatomic) int globalJumpCount;
@property (nonatomic) int globalDoubleJumpCount;
@property (nonatomic) int globalBarriersAvoided;

@property (nonatomic) NSMutableArray *highScores;

@property (nonatomic) int lastHighScoreIndicator;

@property (nonatomic) BOOL needsBarrier;

@property (nonatomic) int barrierCount;

@end

@implementation GameScene

static SKAction *sharedDeathSoundAction = nil;
static SKAction *sharedJumpSoundAction = nil;
static SKAction *sharedDoubleJumpSoundAction = nil;

- (SKAction *)deathSoundAction
{
    return sharedDeathSoundAction;
}

-(SKAction *)jumpSoundAction
{
    return sharedJumpSoundAction;
}

-(SKAction *)doubleJumpSoundAction
{
    return sharedDoubleJumpSoundAction;
}

+ (void)loadSharedAssets
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedDeathSoundAction = [SKAction playSoundFileNamed:@"DeathB1_05.mp3" waitForCompletion:NO];
                      sharedJumpSoundAction = [SKAction playSoundFileNamed:@"Blop_A_01.wav" waitForCompletion:NO];
                      sharedDoubleJumpSoundAction = [SKAction playSoundFileNamed:@"Blop_D_01.wav" waitForCompletion:NO];
                  });
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        //self.randomSpawnInterval = [CommonTools getRandomFloatFromFloat:1.8 toFloat:2.0];
        
        self.selectiveGravity = CGVectorMake(0, -9.8 * kPpm);
        self.barrierTexture = [SKTexture textureWithImageNamed:@"square"];
        self.starTexture = [SKTexture textureWithImageNamed:@"star"];
        self.highScores = [NSMutableArray array];
        self.needsBarrier = NO;
        
        NSArray *scores = [[HighScoreManager sharedManager] getHighScores];
        /*for (HighScoreHelper *score in scores) {
            [self.highScores addObject:score.score];
        }*/
        
        if (scores.count > 0) {
            HighScoreHelper *hs = [scores objectAtIndex:0];
            [self.highScores addObject:hs.score];
        }
        
        /*for (int i=10; i<500; i+=10) {
            [self.highScores addObject:[NSNumber numberWithInt:i]];
        }*/
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
    
    self.globalJumpCount = 0;
    self.globalDoubleJumpCount = 0;
    self.globalBarriersAvoided = 0;
    self.lastHighScoreIndicator = 0;
    self.barrierCount = 0;
    
    self.isRunning = NO;
    self.needABreak = NO;
    
    self.jumpCount = 0;
    self.doubleJumpCount = 0;
    self.madJumpCount = 0;
    self.veryMadJumpCount = 0;
    
    self.screenDiff = 960.0 / (self.size.width * self.view.contentScaleFactor);
    //NSLog(@"W: %f", self.size.width * self.view.contentScaleFactor);
    
    self.score = 0;
    self.difficulty = 1;
    self.distance = 0;
    
    self.rotationUnitPerSecond = 0.0;
    self.secondJumpHeight = 0.0;
    
    self.topCount = 0;
    self.bottomCount = 0;
    self.movingCount = 0;
    
    self.particleBirthRate = 150;
    
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
    self.emitter.particleBirthRate = self.particleBirthRate;
    self.emitter.position = CGPointMake(81, kGroundHeight + 2.0);
    
    [self addChild:self.runner];
    [self addChild:self.emitter];
    
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.scoreLabel.position = CGPointMake(self.size.width - 30.0, self.size.height - 30.0);
    self.scoreLabel.fontSize = 18.0;
    self.scoreLabel.fontColor = [UIColor blackColor];
    self.scoreLabel.text = @"0";
    [self addChild:self.scoreLabel];
    
    __weak GameScene *weakSelf = self;
    
    [self addTextArray:@[@"3", @"2", @"1", @"GO!"] completion:^{
        weakSelf.isRunning = YES;
        weakSelf.randomSpawnInterval = 0.2;
    } andInterval:.3];
    
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"RJ_MusicLoop_A_v02-85195" withExtension:@"mp3"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
    
    /*NSString *rainPath = [[NSBundle mainBundle] pathForResource:@"RainEffect" ofType:@"sks"];
    self.rainEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:rainPath];
    self.rainEmitter.particlePositionRange = CGVectorMake(self.size.width, 5);
    self.rainEmitter.position = CGPointMake(self.size.width / 2.0, self.size.height - 60.0);
    
    NSString *rainDropPath = [[NSBundle mainBundle] pathForResource:@"RainDropEffect" ofType:@"sks"];
    self.rainDropEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:rainDropPath];
    self.rainDropEmitter.particlePositionRange = CGVectorMake(self.size.width, 5);
    self.rainDropEmitter.position = CGPointMake(self.size.width / 2.0, kGroundHeight - 3);
    
    [self addChild:self.rainEmitter];
    [self addChild:self.rainDropEmitter];*/
    
    [self addChild:self.ground];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _runner.isJumping = YES;
    _runner.physicsBody.contactTestBitMask = kObjectCategoryBarrier | kObjectCategoryGround;
    if (_jumpCount < kMaxJumpCount && !_isDead) {
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
            [self runAction:[self jumpSoundAction]];
            _rotationUnitPerSecond = 0.0;
            _globalJumpCount++;
        } else {
            [self runAction:[self doubleJumpSoundAction]];
            _globalDoubleJumpCount++;
            _secondJumpHeight = self.runner.position.y - 5.0;
            
            _expectedLandingTime = 2.0 * (self.runner.physicsBody.velocity.dy / fabs(self.runner.suggestedGravity.dy));
            if (_veryMadJumpCount == 8) {
                [_runner removeAllActions];
                [self addTextArray:@[@"INSANE!!!"] completion:nil andInterval:.4];
                _runner.mood = kRunnerMoodVeryMad;
                _particleBirthRate = 1000;
                _rotationUnitPerSecond =  -M_PI / (_expectedLandingTime * 2.0);
                SKAction *makeMad = [SKAction group:@[[SKAction scaleTo:2.0 duration:.1], [SKAction runBlock:^{
                    _runner.texture = [SKTexture textureWithImageNamed:@"runner_verymad"];
                    _runner.isHitable = NO;
                }]]];
                SKAction *setMood = [SKAction runBlock:^{
                    _runner.mood = kRunnerMoodNormal;
                }];
                SKAction *madAction = [SKAction sequence:@[makeMad, [SKAction scaleTo:1.0 duration:3.5], setMood, [SKAction waitForDuration:.7], [SKAction runBlock:^{
                    _runner.texture = [SKTexture textureWithImageNamed:@"runner"];
                    _runner.isHitable = YES;
                    _particleBirthRate = 150;
                    if (_emitter.particleBirthRate != 0.0) {
                        _emitter.particleBirthRate = _particleBirthRate;
                    }
                }]]];
                
                [_runner runAction:madAction];
                _madJumpCount = -1;
                _doubleJumpCount = -1;
                _veryMadJumpCount = -1;
            } else if (_madJumpCount == 5) {
                [self addTextArray:@[@"MADMAN!"] completion:nil andInterval:.4];
                _runner.mood = kRunnerMoodMad;
                _rotationUnitPerSecond =  -M_PI / (_expectedLandingTime * 4.0);
                SKAction *makeMad = [SKAction group:@[[SKAction scaleTo:1.5 duration:.1], [SKAction runBlock:^{
                    _runner.texture = [SKTexture textureWithImageNamed:@"runner_mad"];
                    _runner.isHitable = NO;
                }]]];
                SKAction *setMood = [SKAction runBlock:^{
                    _runner.mood = kRunnerMoodNormal;
                }];
                SKAction *madAction = [SKAction sequence:@[makeMad, [SKAction scaleTo:1.0 duration:2.5], setMood, [SKAction waitForDuration:.7], [SKAction runBlock:^{
                    _runner.texture = [SKTexture textureWithImageNamed:@"runner"];
                    _runner.isHitable = YES;
                }]]];
                
                [_runner runAction:madAction];
                _doubleJumpCount = -1;
                _madJumpCount = -1;
            } else {
                if (_doubleJumpCount == 2) {
                    _doubleJumpCount = -1;
                    _rotationUnitPerSecond =  -M_PI / (_expectedLandingTime * 4.0);
                    SKAction *scaleAction = [SKAction sequence:@[[SKAction scaleTo:.6 duration:.1], [SKAction scaleTo:1.0 duration:.1]]];
                    [self.runner runAction:scaleAction];
                } else {
                    _rotationUnitPerSecond =  M_PI / (_expectedLandingTime * 4.0);
                }
            }
        }
    }
    _emitter.particleBirthRate = 0;
}

- (void)update:(NSTimeInterval)currentTime
{
    if (!_isDead) {
        self.emitter.position = CGPointMake(_runner.position.x - _runner.size.width / 2.0, kGroundHeight + 2.0);
        if (_runner.physicsBody.velocity.dy >= 0.005) {
            _emitter.particleBirthRate = 0;
        }
        if (_runner.position.y < kGroundHeight + self.runner.size.height / 2.0 + 3.0) {
            _emitter.particleBirthRate = _particleBirthRate;
        }
    }
    
    for (SKSpriteNode *node in self.children) {
        if (node.position.x < 0) {
            if (!_isDead && [node isKindOfClass:[Barrier class]]) {
                _globalBarriersAvoided++;
                _score += ((Barrier *)node).score;
                self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
                //self.score++;
                //self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
                /*if ((int)_score % 10 == 0) {
                 _difficulty++;
                 }*/
            }
            [node removeAllActions];
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
            if ([node isKindOfClass:[HighScoreIndicator class]]) {
                if (node.position.x < _runner.position.x + 15.0 && !_isDead) {
                    SKAction *scaleFade = [SKAction group:@[[SKAction scaleTo:2.5 duration:.1], [SKAction fadeOutWithDuration:.1]]];
                    [node runAction:scaleFade];
                    _score = ((HighScoreIndicator *)node).score;
                    self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
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
    if (_isRunning && !_isDead) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            _distance += (timeSinceLast * kRunnerSpeed) / 100.0;
            if ([_runner.mood isEqualToString:kRunnerMoodMad]) {
                _distance += 0.1;
            } else if ([_runner.mood isEqualToString:kRunnerMoodVeryMad]) {
                _distance += 0.2;
            }
            
            if ((int)_score == 200) {
                _score += 1;
                //self.isRunning = NO;
                _needABreak = YES;
                __weak GameScene *weakSelf = self;
                [self addTextArray:@[@"Not", @"bad"] completion:^{
                    weakSelf.needABreak = NO;
                    weakSelf.randomSpawnInterval = 0.2;
                } andInterval:.6];
            }
            if ((int)_score == 500) {
                _score += 1;
                //self.isRunning = NO;
                _needABreak = YES;
                __weak GameScene *weakSelf = self;
                [self addTextArray:@[@"Quite", @"Exquisite!"] completion:^{
                    weakSelf.needABreak = NO;
                    weakSelf.randomSpawnInterval = 0.2;
                } andInterval:.6];
            }
            if ((int)_score == 1000) {
                _score += 1;
                //self.isRunning = NO;
                _needABreak = YES;
                __weak GameScene *weakSelf = self;
                [self addTextArray:@[@"YOU", @"ARE", @"DOING", @"EXCELLENT!", @"KEEP", @"ON", @"GOING!!!"] completion:^{
                    weakSelf.needABreak = NO;
                    weakSelf.randomSpawnInterval = 0.2;
                } andInterval:.6];
            }
            if ((int)_score == 2000) {
                _score += 1;
                //self.isRunning = NO;
                _needABreak = YES;
                __weak GameScene *weakSelf = self;
                [self addTextArray:@[@"GO", @"GET", @"A", @"LIFE!:)", @"YOU", @"NEED", @"A", @"BREAK!"] completion:^{
                    weakSelf.needABreak = NO;
                    weakSelf.randomSpawnInterval = 0.2;
                } andInterval:.5];
            }
            
            //if ((int)_score % 10 == 0) {
            //self.scoreLabel.text = [NSString stringWithFormat:@"%dm", (int)_score];
            //}
            //NSLog(@"Score: %d", (int)_score);
        });
    }
    _lastSpawnTimeInterval += timeSinceLast;
    if (_secondJumpHeight != 0.0 && _secondJumpHeight - 20.0 < _runner.position.y && _runner.position.y < _secondJumpHeight) {
        _runner.zRotation = 0.0;
        _rotationUnitPerSecond = 0.0;
    }
    
    if (_rotationUnitPerSecond != 0.0) {
        self.runner.zRotation -= timeSinceLast * _rotationUnitPerSecond;
    }
    
    if (_lastSpawnTimeInterval > _randomSpawnInterval && _isRunning && !_needABreak) {
        _lastSpawnTimeInterval = 0;
        _randomSpawnInterval = [CommonTools getRandomFloatFromFloat:0.5 * _screenDiff toFloat:0.7 * _screenDiff];
        //[self addBarrier];
        _needsBarrier = YES;
    }
    
}

-(void)addBarrier
{
    Barrier *barrier = [[Barrier alloc] initWithTexture:_barrierTexture];
    barrier.score = 1;
    _barrierCount++;
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
    
    if ([_runner.mood isEqualToString:kRunnerMoodMad]) {
        barrier.barrierSpeed -= 150;
    } else if ([_runner.mood isEqualToString:kRunnerMoodVeryMad]) {
        barrier.barrierSpeed -= 300;
    }
    
    barrier.physicsBody.velocity = CGVectorMake(barrier.barrierSpeed, 0);
    
    NSNumber *barrierScore = [NSNumber numberWithInt:_barrierCount];
    if ([_highScores containsObject:barrierScore] && !_isDead) {
        barrier.score = 0;
        int barrierIndex = [_highScores indexOfObject:barrierScore];
        HighScoreIndicator *indicator = [self getHighScoreStarForPosition:barrierIndex + 1 withScore:barrierScore.intValue];
        indicator.position = CGPointMake(barrier.position.x, kGroundHeight - indicator.size.height / 2.0 - 5.0);
        indicator.physicsBody.velocity = CGVectorMake(barrier.barrierSpeed, 0);
        [self addChild:indicator];
        
        /*indicator.attachedLabel.physicsBody.velocity = indicator.physicsBody.velocity;
        
        [indicator addChild:indicator.attachedLabel];
        
        SKPhysicsJointFixed *labelJoint = [SKPhysicsJointFixed jointWithBodyA:indicator.physicsBody bodyB:indicator.attachedLabel.physicsBody anchor:indicator.position];
        [self.physicsWorld addJoint:labelJoint];*/
    }
    
    [self addChild:barrier];
}

-(void)runnerJumped
{
    _emitter.particleBirthRate = 0;
}

-(void)runnerLanded
{
    //NSLog(@"Before: JC: %d, DJC: %d, MJC: %d, VMJP: %d", _jumpCount, _doubleJumpCount, _madJumpCount, _veryMadJumpCount);
    
    if (_jumpCount == kMaxJumpCount) {
        _doubleJumpCount++;
        if ([_runner.mood isEqualToString:kRunnerMoodNormal]) {
            _madJumpCount++;
            _veryMadJumpCount++;
        } else if ([_runner.mood isEqualToString:kRunnerMoodMad]) {
            _veryMadJumpCount++;
        }
    } else {
        _doubleJumpCount = 0;
        _madJumpCount = 0;
        _veryMadJumpCount = 0;
    }
    _runner.physicsBody.contactTestBitMask = kObjectCategoryBarrier;
    //_runner.isHitable = YES;
    _jumpCount = 0;
    _runner.isJumping = NO;
    _emitter.particleBirthRate = _particleBirthRate;
    _rotationUnitPerSecond = 0.0;
    _secondJumpHeight = 0.0;
    self.runner.zRotation = 0;
    //NSLog(@"After: JC: %d, DJC: %d, MJC: %d, VMJP: %d", _jumpCount, _doubleJumpCount, _madJumpCount, _veryMadJumpCount);
}

-(void)barrierLanded:(Barrier *)barrier
{
    if (barrier.isJumper) {
        [barrier.physicsBody applyImpulse:CGVectorMake(0, barrier.impulse)];
    }
}

-(void)runnerCollidedWithBarrier:(Barrier *)barrier
{
    NSString *boomPath = [[NSBundle mainBundle] pathForResource:@"BoomEffect" ofType:@"sks"];
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:boomPath];
    emitter.position = _runner.position;
    
    if (self.runner.isHitable) {
        _isDead = YES;
        [self runAction:[self deathSoundAction]];
        _rotationUnitPerSecond = 0.0;
        _emitter.particleBirthRate = 0;
        SKAction *boom = [SKAction runBlock:^{
            [_runner removeFromParent];
            [self addChild:emitter];
        }];
        
        [self runAction:[SKAction sequence:@[boom, [SKAction waitForDuration:2.0], [SKAction runBlock:^{
            StatisticsHelper *stat = [[StatisticsHelper alloc] init];
            stat.jumps = _globalJumpCount;
            stat.doubleJumps = _globalDoubleJumpCount;
            stat.distance = (int)_distance;
            stat.barriers = _globalBarriersAvoided;
            [_delegate gameOverWithStatistics:stat];
        }]]]];
    } else {
        _score++;
        self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
        [self addChild:emitter];
        [barrier removeFromParent];
    }
}

-(void)addTextArray:(NSArray *)textArray completion:(void(^)())completion andInterval:(float)interval
{
    SKLabelNode *textLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
    textLabel.fontColor = [UIColor blackColor];
    textLabel.fontSize = 25;
    
    NSMutableArray *textActions = [NSMutableArray array];
    
    SKAction *growAndFade = [SKAction group:@[[SKAction fadeOutWithDuration:interval], [SKAction scaleTo:6.0 duration:interval]]];
    
    for (NSString *text in textArray) {
        SKAction *ta = [SKAction group:@[[SKAction fadeInWithDuration:0.0], [SKAction scaleTo:1.0 duration:0.0], [SKAction runBlock:^{
            textLabel.text = text;
        }]]];
        
        SKAction *tas = [SKAction sequence:@[growAndFade, ta]];
        
        [textActions addObject:tas];
    }
    
    [textActions addObject:growAndFade];
    [textActions addObject:[SKAction removeFromParent]];
    
    SKAction *countDown = [SKAction sequence:textActions];
    
    textLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    textLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    textLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [textLabel runAction:countDown completion:completion];
    
    [self addChild:textLabel];
}

-(HighScoreIndicator *)getHighScoreStarForPosition:(int)position withScore:(int)score
{
    HighScoreIndicator *indicator = [[HighScoreIndicator alloc] initWithTexture:_starTexture];
    indicator.score = score;
    /*float starSpeed = -1 * kRunnerSpeed;
    
    if ([_runner.mood isEqualToString:kRunnerMoodMad]) {
        starSpeed -= 150;
        //indicator.score += 2;
    } else if ([_runner.mood isEqualToString:kRunnerMoodVeryMad]) {
        starSpeed -= 300;
        //indicator.score += 4;
    }*/
    
    /*SKLabelNode *indexLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
    indexLabel.fontColor = [UIColor blackColor];
    indexLabel.fontSize = 16;
    indexLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    indexLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    //indexLabel.position = indicator.position;
    indexLabel.text = [NSString stringWithFormat:@"%d", position];
    
    indexLabel.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:1.0];
    indexLabel.physicsBody.mass = 0;
    indexLabel.physicsBody.friction = 0;
    indexLabel.physicsBody.contactTestBitMask = 0;
    indexLabel.physicsBody.collisionBitMask = 0;
    indexLabel.physicsBody.dynamic = YES;
    
    indicator.attachedLabel = indexLabel;*/
    
    /*if (position == 1) {
        _needABreak = YES;
        __weak GameScene *weakSelf = self;
        [self addTextArray:@[@"New", @"High", @"Score!"] completion:^{
            weakSelf.needABreak = NO;
            weakSelf.randomSpawnInterval = 0.2;
        } andInterval:.6];
    }*/
    
    return indicator;
}

-(void)didSimulatePhysics
{
    /*if (_isRunning) {
        NSNumber *newScore = [NSNumber numberWithInt:(int)_score + 5];
        if ([_highScores containsObject:newScore] && newScore.intValue != _lastHighScoreIndicator) {
            _lastHighScoreIndicator = newScore.intValue;
            int index = [_highScores indexOfObject:newScore] + 1;
            [self addHighScoreStarForPosition:index withScore:newScore.intValue];
        }
    }*/
    if (_needsBarrier) {
        _needsBarrier = NO;
        [self addBarrier];
    }
}

@end
