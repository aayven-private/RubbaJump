//
//  HighScoreIndicator.m
//  RunnerGame
//
//  Created by Ivan Borsa on 16/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "HighScoreIndicator.h"

@implementation HighScoreIndicator

-(id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture]) {
        self.type = kObjectTypeBarrier;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1.0, 1.0)];
        self.physicsBody.categoryBitMask = kObjectCategoryStar;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.isAffectedBySelectiveGravity = NO;
        self.physicsBody.usesPreciseCollisionDetection = NO;
        self.physicsBody.mass = 0.0;
        self.physicsBody.restitution = 0.0;
        self.physicsBody.friction = 0.0;
        self.physicsBody.contactTestBitMask = 0;
        self.hasOwnGravity = NO;
        
    }
    return self;
}

@end
