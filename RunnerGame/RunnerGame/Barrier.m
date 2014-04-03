//
//  Barrier.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "Barrier.h"

@implementation Barrier

-(id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture]) {
        self.type = kObjectTypeBarrier;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:texture.size];
        self.physicsBody.categoryBitMask = kObjectCategoryBarrier;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = YES;
        self.physicsBody.mass = 1.0;
    }
    return self;
}

@end
