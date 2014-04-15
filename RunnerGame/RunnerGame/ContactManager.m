//
//  ContactManager.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "ContactManager.h"
#import "Constants.h"

@implementation ContactManager

-(id)initWithDelegate:(id<ContactManagerDelegate>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == kObjectCategoryRunner) {
        if (contact.bodyB.categoryBitMask == kObjectCategoryGround) {
            [_delegate runnerLanded];
        }
        if (contact.bodyB.categoryBitMask == kObjectCategoryBarrier) {
            [_delegate runnerCollidedWithBarrier:(Barrier *)contact.bodyB.node];
        }
    } else if (contact.bodyB.categoryBitMask == kObjectCategoryRunner) {
        if (contact.bodyA.categoryBitMask == kObjectCategoryGround) {
            [_delegate runnerLanded];
        }
        if (contact.bodyA.categoryBitMask == kObjectCategoryBarrier) {
            [_delegate runnerCollidedWithBarrier:(Barrier *)contact.bodyA.node];
        }
    } else if (contact.bodyA.categoryBitMask == kObjectCategoryBarrier) {
        if (contact.bodyB.categoryBitMask == kObjectCategoryGround) {
            [_delegate barrierLanded:(Barrier *)contact.bodyA.node];
        }

    } else if (contact.bodyB.categoryBitMask == kObjectCategoryBarrier) {
        if (contact.bodyA.categoryBitMask == kObjectCategoryGround) {
            [_delegate barrierLanded:(Barrier *)contact.bodyB.node];
        }

    }
}

-(void)didEndContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == kObjectCategoryRunner) {
        if (contact.bodyB.categoryBitMask == kObjectCategoryGround) {
            [_delegate runnerJumped];
        }
    } else if (contact.bodyB.categoryBitMask == kObjectCategoryRunner) {
        if (contact.bodyA.categoryBitMask == kObjectCategoryGround) {
            [_delegate runnerJumped];
        }
    }}

@end
