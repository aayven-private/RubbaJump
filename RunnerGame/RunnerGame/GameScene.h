//
//  MyScene.h
//  RunnerGame
//

//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ContactManager.h"
#import "ContactManagerDelegate.h"

@interface GameScene : SKScene <ContactManagerDelegate>

-(void)initEnvironment;

@end
