//
//  StatisticsManager.h
//  RunnerGame
//
//  Created by Ivan Borsa on 15/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatisticsHelper.h"

@interface StatisticsManager : NSObject

+(id)sharedInstance;

-(void)saveStatistics:(StatisticsHelper *)stat;
-(StatisticsHelper *)getStatistics;

@end
