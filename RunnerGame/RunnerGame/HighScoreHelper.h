//
//  HighScoreHelper.h
//  BeeGame
//
//  Created by Ivan Borsa on 24/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HighScoreHelper : NSObject

@property (nonatomic) NSNumber *score;
@property (nonatomic) NSDate *scoreDate;
@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *distance;

@end
