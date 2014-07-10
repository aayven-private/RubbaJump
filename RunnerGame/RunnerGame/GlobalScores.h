//
//  GlobalScores.h
//  RunnerGame
//
//  Created by Ivan Borsa on 10/07/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GlobalScores : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSDate * scoreDate;

@end
