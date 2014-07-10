//
//  HighScoreManager.h
//  BeeGame
//
//  Created by Ivan Borsa on 24/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBAccessLayer.h"
#import "HighScoreHelper.h"
#import "GlobalScoreHelper.h"

@interface HighScoreManager : NSObject

+(id)sharedManager;

-(NSArray *)getHighScores;
-(void)addHighScore:(HighScoreHelper *)scoreHelper;
-(int)getMinimumHighScore;
-(int)getMaximumHighScore;
-(BOOL)uploadHighscore:(int)score;
-(NSDictionary *)getGlobalScores;
-(void)getGlobalPositionFromServerWithCompletion:(void(^)(int result))completion andFail:(void(^)(void))fail;
-(void)downloadSurroundingsWithCompletion:(void(^)(NSDictionary *scores))completion andFail:(void(^)(void))fail;

@end
