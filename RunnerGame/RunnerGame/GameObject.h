//
//  GameObject.h
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Constants.h"

@interface GameObject : SKSpriteNode

@property (nonatomic) NSString *type;
@property (nonatomic) BOOL isAffectedBySelectiveGravity;

@property (nonatomic) CGVector suggestedGravity;
@property (nonatomic) BOOL hasOwnGravity;

@end
