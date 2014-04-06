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

@interface HighScoreManager : NSObject

+(id)sharedManager;

-(NSArray *)getHighScores;
-(void)addHighScore:(HighScoreHelper *)scoreHelper;
-(int)getMinimumHighScore;

@end
