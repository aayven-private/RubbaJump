//
//  Ground.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "Ground.h"

@implementation Ground

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithColor:[UIColor clearColor] size:size]) {
        self.type = kObjectTypeGround;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.categoryBitMask = kObjectCategoryGround;
        self.physicsBody.contactTestBitMask = kObjectCategoryBarrier;
        self.physicsBody.collisionBitMask = kObjectCategoryBarrier | kObjectCategoryRunner;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.dynamic = NO;
        self.isAffectedBySelectiveGravity = NO;
        self.physicsBody.restitution = 0.0;
        self.physicsBody.friction = 0.0;
        self.hasOwnGravity = NO;
    }
    return self;
}

@end
