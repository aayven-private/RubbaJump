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
        //self.backgroundColor = [UIColor whiteColor];
        //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gameover_bg.png"]];
        
        SKSpriteNode *bgNode = [[SKSpriteNode alloc] initWithImageNamed:@"gameover_bg"];
        bgNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
        [self addChild:bgNode];
        
        SKSpriteNode *boxNode = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.8] size:CGSizeMake(180, 95)];
        boxNode.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 95);
        [self addChild:boxNode];
        
        SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        gameOverLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 110.0);
        gameOverLabel.fontSize = 30.0;
        gameOverLabel.fontColor = [UIColor whiteColor];
        gameOverLabel.text = @"Game Over";
        [self addChild:gameOverLabel];
        
        
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        scoreLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 80.0);
        scoreLabel.fontSize = 16.0;
        scoreLabel.fontColor = [UIColor whiteColor];
        scoreLabel.text = [NSString stringWithFormat:@"Score: %d", stat.barriers];
        [self addChild:scoreLabel];
        
        SKLabelNode *distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"ExpletusSans-Bold"];
        distanceLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 55.0);
        distanceLabel.fontSize = 16.0;
        distanceLabel.fontColor = [UIColor whiteColor];
        distanceLabel.text = [NSString stringWithFormat:@"Distance: %d m", stat.distance];
        [self addChild:distanceLabel];
        
        self.exitButton = [[SKSpriteNode alloc] initWithImageNamed:@"menu_a3.png"];
        //self.exitButton.centerRect = CGRectMake(70.0 / 160.0, 32.0, 20.0, 10.0);
        self.exitButton.size = CGSizeMake(205, 90);
        self.exitButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 - 10);
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
        
        self.retryButton = [[SKSpriteNode alloc] initWithImageNamed:@"retry_a3.png"];
        //self.retryButton.centerRect = CGRectMake(70.0 / 160.0, 32.0, 20.0, 10.0);
        self.retryButton.size = CGSizeMake(205, 90);
        self.retryButton.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0 - 80.0);
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
        _exitButton.texture = [SKTexture textureWithImageNamed:@"menu_on_a3"];
    } else if ([node.name isEqualToString:@"retry"]) {
        _retryButton.texture = [SKTexture textureWithImageNamed:@"retry_on_a3"];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _exitButton.texture = [SKTexture textureWithImageNamed:@"menu_a3"];
    _retryButton.texture = [SKTexture textureWithImageNamed:@"retry_a3"];
    
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
