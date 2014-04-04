//
//  Barrier.h
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameObject.h"

@interface Barrier : GameObject

@property (nonatomic) BOOL isJumper;
@property (nonatomic) float impulse;
@property (nonatomic) float speed;

@end
