//
//  HighScoreManager.m
//  BeeGame
//
//  Created by Ivan Borsa on 24/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import "HighScoreManager.h"
#import "HighScores.h"

@implementation HighScoreManager

+ (id)sharedManager {
    static HighScoreManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(NSArray *)getHighScores
{
    __block NSMutableArray *result = [NSMutableArray array];
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"HighScores"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *scores = [context executeFetchRequest:request error:&error];
        
        if (!error) {
            if (scores.count > 10) {
                for (int i=scores.count - 1; i<scores.count; i++) {
                    HighScores *scoreToDelete = [scores objectAtIndex:i];
                    [context deleteObject:scoreToDelete];
                }
                for (int i=0; i<10; i++) {
                    HighScores *score = [scores objectAtIndex:i];
                    HighScoreHelper *scoreHelper = [self scoreEntityToHelper:score];
                    [result addObject:scoreHelper];
                }
            } else {
                for (HighScores *score in scores) {
                    HighScoreHelper *scoreHelper = [self scoreEntityToHelper:score];
                    [result addObject:scoreHelper];
                }
            }
            if ([context hasChanges]) {
                [DBAccessLayer saveContext:context async:NO];
            }
        }
    }];
    
    return result;
}

-(void)addHighScore:(HighScoreHelper *)scoreHelper
{
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"HighScores"];
        
        NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
        int minHighScore = [self getMinimumHighScore];
        
        if ((count < 10 || scoreHelper.score.intValue > minHighScore) && scoreHelper.score.intValue > 0) {
            HighScores *newScore = [NSEntityDescription insertNewObjectForEntityForName:@"HighScores" inManagedObjectContext:context];
            newScore.score = scoreHelper.score;
            newScore.scoreDate = scoreHelper.scoreDate;
            newScore.name = scoreHelper.name;
            if ([context hasChanges]) {
                [DBAccessLayer saveContext:context async:NO];
            }
        }
    }];
}

-(int)getMinimumHighScore
{
    __block int result = -1;
    
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    [context performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"HighScores" inManagedObjectContext:context];
        [request setEntity:entity];
        
        // Specify that the request should return dictionaries.
        [request setResultType:NSDictionaryResultType];
        
        // Create an expression for the key path.
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"score"];
        
        // Create an expression to represent the minimum value at the key path 'creationDate'
        NSExpression *minExpression = [NSExpression expressionForFunction:@"min:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        
        // Create an expression description using the minExpression and returning a date.
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        
        // The name is the key that will be used in the dictionary for the return value.
        [expressionDescription setName:@"score"];
        [expressionDescription setExpression:minExpression];
        [expressionDescription setExpressionResultType:NSInteger16AttributeType];
        
        // Set the request's properties to fetch just the property represented by the expressions.
        [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
        
        // Execute the fetch.
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if (objects == nil) {
            // Handle the error.
        }
        else {
            if ([objects count] > 0) {
                NSNumber *minScore = [[objects objectAtIndex:0] valueForKey:@"score"];
                result = minScore.intValue;
            }
        }
    }];
    
    return result;
}

-(HighScoreHelper *)scoreEntityToHelper:(HighScores *)score
{
    HighScoreHelper *scoreHelper = [[HighScoreHelper alloc] init];
    scoreHelper.score = score.score;
    scoreHelper.scoreDate = score.scoreDate;
    scoreHelper.name = score.name;
    return scoreHelper;
}

@end
