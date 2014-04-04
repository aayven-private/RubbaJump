//
//  Runner.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "Runner.h"

@implementation Runner

-(id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture]) {
        self.type = kObjectTypeRunner;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:texture.size];
        self.physicsBody.categoryBitMask = kObjectCategoryRunner;
        self.physicsBody.collisionBitMask = kObjectCategoryGround;
        self.physicsBody.contactTestBitMask = kObjectCategoryBarrier | kObjectCategoryGround;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.isAffectedBySelectiveGravity = YES;
        self.physicsBody.mass = 8.0;
        self.physicsBody.restitution = 0.0;
        self.physicsBody.friction = 0.0;
        self.isJumping = NO;
        self.hasOwnGravity = YES;
        self.suggestedGravity = CGVectorMake(0, -24 * kPpm * self.physicsBody.mass);
    }
    return self;
}

@end
