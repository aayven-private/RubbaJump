//
//  MyScene.h
//  RunnerGame
//

//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ContactManager.h"
#import "ContactManagerDelegate.h"
#import "GameSceneHandlerDelegate.h"

@interface GameScene : SKScene <ContactManagerDelegate>

-(void)initEnvironment;

@property (nonatomic, weak) id<GameSceneHandlerDelegate> delegate;

@end
