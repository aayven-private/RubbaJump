//
//  GlobalScoreHelper.h
//  RunnerGame
//
//  Created by Ivan Borsa on 10/07/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalScoreHelper : NSObject

@property (nonatomic) NSString * userName;
@property (nonatomic) NSNumber * score;
@property (nonatomic) NSNumber * distance;
@property (nonatomic) NSNumber * position;
@property (nonatomic) NSDate * scoreDate;


@end
