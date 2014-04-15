//
//  StatisticsManager.m
//  RunnerGame
//
//  Created by Ivan Borsa on 15/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "StatisticsManager.h"
#import "HighScoreManager.h"
#import "Constants.h"

@implementation StatisticsManager

+(id)sharedInstance
{
    static StatisticsManager *myManagerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myManagerInstance = [[self alloc] init];
    });
    return myManagerInstance;
}

-(id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)saveStatistics:(StatisticsHelper *)stat
{
    HighScoreHelper *scoreHelper = [[HighScoreHelper alloc] init];
    scoreHelper.score = [NSNumber numberWithInt:stat.distance];
    scoreHelper.scoreDate = [NSDate date];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[HighScoreManager sharedManager] addHighScore:scoreHelper];
    });
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *barrierCount = [defaults objectForKey:kStatBarrierKey];
    if (!barrierCount) {
        barrierCount = [NSNumber numberWithInt:0];
    }
    barrierCount = [NSNumber numberWithInt:barrierCount.intValue + stat.barriers];
    [defaults setObject:barrierCount forKey:kStatBarrierKey];
    
    NSNumber *jumpCount = [defaults objectForKey:kStatJumpKey];
    if (!jumpCount) {
        jumpCount = [NSNumber numberWithInt:0];
    }
    jumpCount = [NSNumber numberWithInt:jumpCount.intValue + stat.jumps];
    [defaults setObject:jumpCount forKey:kStatJumpKey];
    
    NSNumber *doubleJumpCount = [defaults objectForKey:kStatDoubleJumpKey];
    if (!doubleJumpCount) {
        doubleJumpCount = [NSNumber numberWithInt:0];
    }
    doubleJumpCount = [NSNumber numberWithInt:doubleJumpCount.intValue + stat.doubleJumps];
    [defaults setObject:doubleJumpCount forKey:kStatDoubleJumpKey];
    
    NSNumber *distance = [defaults objectForKey:kStatDistanceKey];
    if (!distance) {
        distance = [NSNumber numberWithInt:0];
    }
    distance = [NSNumber numberWithInt:distance.intValue + stat.distance];
    [defaults setObject:distance forKey:kStatDistanceKey];
    
    [defaults synchronize];
}

-(StatisticsHelper *)getStatistics
{
    StatisticsHelper *stat = [[StatisticsHelper alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *barrierCount = [defaults objectForKey:kStatBarrierKey];
    if (!barrierCount) {
        barrierCount = [NSNumber numberWithInt:0];
    }
    
    NSNumber *jumpCount = [defaults objectForKey:kStatJumpKey];
    if (!jumpCount) {
        jumpCount = [NSNumber numberWithInt:0];
    }
    
    NSNumber *doubleJumpCount = [defaults objectForKey:kStatDoubleJumpKey];
    if (!doubleJumpCount) {
        doubleJumpCount = [NSNumber numberWithInt:0];
    }
    
    NSNumber *distance = [defaults objectForKey:kStatDistanceKey];
    if (!distance) {
        distance = [NSNumber numberWithInt:0];
    }
    
    stat.distance = distance.intValue;
    stat.jumps = jumpCount.intValue;
    stat.doubleJumps = doubleJumpCount.intValue;
    stat.barriers = barrierCount.intValue;
    
    return stat;
}

@end
