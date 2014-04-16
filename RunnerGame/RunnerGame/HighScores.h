//
//  HighScores.h
//  BeeGame
//
//  Created by Ivan Borsa on 24/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HighScores : NSManagedObject

@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSDate * scoreDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * distance;

@end
