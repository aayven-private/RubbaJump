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
        self.physicsBody.contactTestBitMask = kObjectCategoryBarrier;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = YES;
        self.physicsBody.mass = 8.0;
        self.physicsBody.restitution = 0.0;
    }
    return self;
}

@end
