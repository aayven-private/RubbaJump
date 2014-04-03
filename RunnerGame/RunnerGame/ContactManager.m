//
//  ContactManager.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "ContactManager.h"

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
    [_delegate runnerLanded];
}

-(void)didEndContact:(SKPhysicsContact *)contact
{
    [_delegate runnerJumped];
}

@end
