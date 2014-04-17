//
//  ComboManager.h
//  RunnerGame
//
//  Created by Ivan Borsa on 16/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComboManager : NSObject

+(id)sharedManager;
-(NSSet *)actionTaken:(NSString *)action;

@end
