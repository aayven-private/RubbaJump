//
//  GameSceneHandlerDelegate.h
//  RunnerGame
//
//  Created by Ivan Borsa on 10/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameSceneHandlerDelegate <NSObject>

-(void)gameOverWithScore:(int)score;

@end
