//
//  GameOverScene.m
//  RunnerGame
//
//  Created by Ivan Borsa on 15/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "GameOverScene.h"

@interface GameOverScene()

@property (nonatomic) SKSpriteNode *exitButton;
@property (nonatomic) SKSpriteNode *retryButton;

@end

@implementation GameOverScene

-(id)initWithSize:(CGSize)size andStatistics:(StatisticsHelper *)stat
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor whiteColor];
        
        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        gameOverLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 110.0);
        gameOverLabel.fontSize = 30.0;
        gameOverLabel.fontColor = [UIColor blackColor];
        gameOverLabel.text = @"Game Over";
        [self addChild:gameOverLabel];
        
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        scoreLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 80.0);
        scoreLabel.fontSize = 16.0;
        scoreLabel.fontColor = [UIColor blackColor];
        scoreLabel.text = [NSString stringWithFormat:@"Score: %d", stat.barriers];
        [self addChild:scoreLabel];
        
        SKLabelNode *distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        distanceLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 55.0);
        distanceLabel.fontSize = 16.0;
        distanceLabel.fontColor = [UIColor blackColor];
        distanceLabel.text = [NSString stringWithFormat:@"Distance: %d m", stat.distance];
        [self addChild:distanceLabel];
        
        self.exitButton = [[SKSpriteNode alloc] initWithImageNamed:@"button.png"];
        //self.exitButton.centerRect = CGRectMake(70.0 / 160.0, 32.0, 20.0, 10.0);
        self.exitButton.size = CGSizeMake(160, 80);
        self.exitButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.exitButton.name = @"exit";
        [self addChild:self.exitButton];
        
        SKLabelNode *exitLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        exitLabel.text = @"Menu";
        exitLabel.fontColor = [UIColor whiteColor];
        exitLabel.fontSize = 20.0;
        exitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        exitLabel.position = self.exitButton.position;
        exitLabel.name = @"exit";
        [self addChild:exitLabel];
        
        self.retryButton = [[SKSpriteNode alloc] initWithImageNamed:@"button.png"];
        //self.retryButton.centerRect = CGRectMake(70.0 / 160.0, 32.0, 20.0, 10.0);
        self.retryButton.size = CGSizeMake(160, 80);
        self.retryButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 - 90.0);
        self.retryButton.name = @"retry";
        [self addChild:self.retryButton];
        
        SKLabelNode *retryLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        retryLabel.text = @"Retry";
        retryLabel.fontColor = [UIColor whiteColor];
        retryLabel.fontSize = 20.0;
        retryLabel.position = self.retryButton.position;
        retryLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        retryLabel.name = @"retry";
        [self addChild:retryLabel];
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"exit"]) {
        [_delegate quit];
    } else if ([node.name isEqualToString:@"retry"]) {
        [_delegate retry];
    }
}

@end
