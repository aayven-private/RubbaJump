//
//  GameOverScene.h
//  RunnerGame
//
//  Created by Ivan Borsa on 15/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameOverSceneDelegate.h"
#import "StatisticsHelper.h"

@interface GameOverScene : SKScene

-(id)initWithSize:(CGSize)size andStatistics:(StatisticsHelper *)stat;

@property (nonatomic, weak) id<GameOverSceneDelegate> delegate;

@end
