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

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor whiteColor];
        
        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"BanglaSangamMN-Bold"];
        gameOverLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 50.0);
        gameOverLabel.fontSize = 30.0;
        gameOverLabel.fontColor = [UIColor blackColor];
        gameOverLabel.text = @"Game Over";
        [self addChild:gameOverLabel];
        
        self.exitButton = [[SKSpriteNode alloc] initWithColor:[UIColor lightGrayColor] size:CGSizeMake(100, 50)];
        self.exitButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        self.exitButton.name = @"exit";
        [self addChild:self.exitButton];
        
        SKLabelNode *exitLabel = [SKLabelNode labelNodeWithFontNamed:@"BanglaSangamMN"];
        exitLabel.text = @"Menu";
        exitLabel.fontColor = [UIColor blackColor];
        exitLabel.fontSize = 20.0;
        exitLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        exitLabel.position = self.exitButton.position;
        exitLabel.name = @"exit";
        [self addChild:exitLabel];
        
        self.retryButton = [[SKSpriteNode alloc] initWithColor:[UIColor lightGrayColor] size:CGSizeMake(100, 50)];
        self.retryButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 - 60.0);
        self.retryButton.name = @"retry";
        [self addChild:self.retryButton];
        
        SKLabelNode *retryLabel = [SKLabelNode labelNodeWithFontNamed:@"BanglaSangamMN"];
        retryLabel.text = @"Retry";
        retryLabel.fontColor = [UIColor blackColor];
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
