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
    if (self = [super init]) {
        self.type = kObjectTypeGround;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 0) toPoint:CGPointMake(size.width, 0)];
        self.physicsBody.categoryBitMask = kObjectCategoryGround;
        self.physicsBody.contactTestBitMask = kObjectCategoryBarrier | kObjectCategoryRunner;
        self.physicsBody.collisionBitMask = kObjectCategoryBarrier | kObjectCategoryRunner;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.dynamic = NO;
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.restitution = 0.0;
    }
    return self;
}

@end
