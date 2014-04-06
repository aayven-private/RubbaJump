//
//  Barrier.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "Barrier.h"
#import "CommonTools.h"

@implementation Barrier

-(id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture]) {
        self.type = kObjectTypeBarrier;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:texture.size];
        self.physicsBody.categoryBitMask = kObjectCategoryBarrier;
        self.physicsBody.collisionBitMask = kObjectCategoryGround;
        self.physicsBody.dynamic = YES;
        self.physicsBody.affectedByGravity = NO;
        self.isAffectedBySelectiveGravity = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.mass = 8.0;
        self.physicsBody.restitution = 0.0;
        self.physicsBody.friction = 0.0;
        int boolInt = [CommonTools getRandomNumberFromInt:0 toInt:1];
        //self.isJumper = (BOOL)boolInt;
        self.isJumper = NO;
        self.physicsBody.contactTestBitMask = self.isJumper ? 0 : 0;
        
        if (self.isJumper) {
            int rnd = [CommonTools getRandomNumberFromInt:1 toInt:2];
            switch (rnd) {
                case 1: {

                }
                    break;
                case 2: {

                }
                    break;
                case 3: {

                }
                    break;
                case 4: {

                }
                    break;
                case 5: {

                }
                    break;
                default:
                    break;
            }
        } else {
            self.speed = [CommonTools getRandomFloatFromFloat:-600 toFloat:-650];
        }
        
        self.hasOwnGravity = self.isJumper;
        self.suggestedGravity = CGVectorMake(0, -15 * kPpm * self.physicsBody.mass);
        
        
    }
    return self;
}

@end
