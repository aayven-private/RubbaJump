//
//  GameSceneController.h
//  RunnerGame
//
//  Created by Ivan Borsa on 10/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "GameSceneHandlerDelegate.h"
#import "GameOverSceneDelegate.h"

@interface GameSceneController : UIViewController <GameSceneHandlerDelegate, GameOverSceneDelegate>

@end
