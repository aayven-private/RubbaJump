//
//  GameOverSceneDelegate.h
//  RunnerGame
//
//  Created by Ivan Borsa on 15/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameOverSceneDelegate <NSObject>

-(void)retry;
-(void)quit;

@end
