//
//  ContactManagerDelegate.h
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Barrier.h"

@protocol ContactManagerDelegate <NSObject>

-(void)runnerJumped;
-(void)runnerLanded;

-(void)barrierCollidedWithRunner;

-(void)barrierLanded:(Barrier *)barrier;

@end
