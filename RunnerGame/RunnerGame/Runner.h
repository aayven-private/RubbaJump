//
//  Runner.h
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameObject.h"

@interface Runner : GameObject

@property (nonatomic) BOOL isJumping;
@property (nonatomic) BOOL isHitable;
@property (nonatomic) NSString *mood;

@end
