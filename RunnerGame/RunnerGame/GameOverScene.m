//
//  GameOverScene.m
//  RunnerGame
//
//  Created by Ivan Borsa on 15/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "GameOverScene.h"
#import "Constants.h"
#import "HighScoreManager.h"

@interface GameOverScene()

@property (nonatomic) SKSpriteNode *exitButton;
@property (nonatomic) SKSpriteNode *retryButton;
@property (nonatomic) BOOL isSoundEnabled;

@end

@implementation GameOverScene

-(id)initWithSize:(CGSize)size andStatistics:(StatisticsHelper *)stat
{
    if (self = [super initWithSize:size]) {
        //self.backgroundColor = [UIColor whiteColor];
        //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gameover_bg.png"]];
        
        int maxHighscore = [[HighScoreManager sharedManager] getMaximumHighScore];
        if (maxHighscore < stat.barriers) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[HighScoreManager sharedManager] uploadHighscore:stat.barriers];
            });
        }
        
        NSNumber *soundEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:kSoundEnabledKey];
        if (!soundEnabled) {
            soundEnabled = [NSNumber numberWithBool:YES];
            [[NSUserDefaults standardUserDefaults] setObject:soundEnabled forKey:kSoundEnabledKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        _isSoundEnabled = soundEnabled.boolValue;
        
        NSString *bgFileName;
        if (IS_PHONEPOD5()) {
            bgFileName = @"game_over_bg_a4-568h";
        } else {
            bgFileName = @"game_over_bg_a4";
        }
        
        SKSpriteNode *bgNode = [[SKSpriteNode alloc] initWithImageNamed:bgFileName];
        bgNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        [self addChild:bgNode];
        
        /*SKSpriteNode *boxNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.8] size:CGSizeMake(180, 95)];
        boxNode.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 95);
        [self addChild:boxNode];*/
        
        /*SKShapeNode* tile = [SKShapeNode node];
        [tile setPath:CGPathCreateWithRoundedRect(CGRectMake(size.width / 2.0 - 100, size.height / 2.0 + 45, 200, 95), 4, 4, nil)];
        tile.strokeColor = tile.fillColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.8];
        [self addChild:tile];*/
        
        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"PoetsenOne-Regular"];
        gameOverLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 110.0);
        gameOverLabel.fontSize = 30.0;
        gameOverLabel.fontColor = [UIColor blackColor];
        gameOverLabel.text = @"Game Over";
        [self addChild:gameOverLabel];
        
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"PoetsenOne-Regular"];
        scoreLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 65.0);
        scoreLabel.fontSize = 36.0;
        scoreLabel.fontColor = [UIColor blackColor];
        scoreLabel.text = [NSString stringWithFormat:@"Score: %d", stat.barriers];
        [self addChild:scoreLabel];
        
        /*SKLabelNode *distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"PoetsenOne-Regular"];
        distanceLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 55.0);
        distanceLabel.fontSize = 16.0;
        distanceLabel.fontColor = [UIColor whiteColor];
        distanceLabel.text = [NSString stringWithFormat:@"Distance: %d m", stat.distance];
        [self addChild:distanceLabel];*/
        
        self.exitButton = [[SKSpriteNode alloc] initWithImageNamed:@"menu_a4.png"];
        //self.exitButton.centerRect = CGRectMake(70.0 / 160.0, 32.0, 20.0, 10.0);
        self.exitButton.size = CGSizeMake(160, 55);
        self.exitButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 - 20);
        self.exitButton.name = @"exit";
        [self addChild:self.exitButton];
        
        /*SKLabelNode *exitLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        exitLabel.text = @"Menu";
        exitLabel.fontColor = [UIColor whiteColor];
        exitLabel.fontSize = 20.0;
        exitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        exitLabel.position = self.exitButton.position;
        exitLabel.name = @"exit";
        [self addChild:exitLabel];*/
        
        self.retryButton = [[SKSpriteNode alloc] initWithImageNamed:@"retry_a4.png"];
        //self.retryButton.centerRect = CGRectMake(70.0 / 160.0, 32.0, 20.0, 10.0);
        self.retryButton.size = CGSizeMake(160, 55);
        self.retryButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 - 90.0);
        self.retryButton.name = @"retry";
        [self addChild:self.retryButton];
        
        /*SKLabelNode *retryLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        retryLabel.text = @"Retry";
        retryLabel.fontColor = [UIColor whiteColor];
        retryLabel.fontSize = 20.0;
        retryLabel.position = self.retryButton.position;
        retryLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        retryLabel.name = @"retry";
        [self addChild:retryLabel];*/
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"exit"]) {
        _exitButton.texture = [SKTexture textureWithImageNamed:@"menu_on_a4"];
    } else if ([node.name isEqualToString:@"retry"]) {
        _retryButton.texture = [SKTexture textureWithImageNamed:@"retry_on_a4"];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _exitButton.texture = [SKTexture textureWithImageNamed:@"menu_a4"];
    _retryButton.texture = [SKTexture textureWithImageNamed:@"retry_a4"];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"exit"]) {
        [self playButtonSound];
        [_gameDelegate quit];
    } else if ([node.name isEqualToString:@"retry"]) {
        [self playButtonSound];
        [_gameDelegate retry];
    }
}

-(void)playButtonSound
{
    if (_isSoundEnabled) {
        SystemSoundID soundID;
        
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"buttonClick_B-01" ofType:@"wav"];
        NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
        
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundUrl, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}

@end
