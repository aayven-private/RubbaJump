//
//  HighScoreManager.m
//  BeeGame
//
//  Created by Ivan Borsa on 24/03/14.
//  Copyright (c) 2014 aayven. All rights reserved.
//

#import "HighScoreManager.h"
#import "HighScores.h"
#import "NetworkManager.h"
#import "CommonTools.h"
#import "Constants.h"
#import "GlobalScores.h"

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
                for (NSUInteger i=scores.count - 1; i<scores.count; i++) {
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

-(NSDictionary *)getGlobalScores
{
    __block NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    [context performBlockAndWait:^{
        NSNumber *lastScore = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUploadedScoreKey];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"GlobalScores"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"score > %@", lastScore];
        [request setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        request.sortDescriptors = @[sortDescriptor];
        
        NSMutableArray *more = [NSMutableArray array];
        NSMutableArray *less = [NSMutableArray array];
        
        NSError *error = nil;
        NSArray *scores = [context executeFetchRequest:request error:&error];
        
        for (GlobalScores *score in scores) {
            GlobalScoreHelper *scoreHelper = [self globalScoreEntityToHelper:score];
            [more addObject:scoreHelper];
        }
        
        request = [[NSFetchRequest alloc] initWithEntityName:@"GlobalScores"];
        predicate = [NSPredicate predicateWithFormat: @"score < %@", lastScore];
        [request setPredicate:predicate];
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
        request.sortDescriptors = @[sortDescriptor];
        
        scores = [context executeFetchRequest:request error:&error];
        
        for (GlobalScores *score in scores) {
            GlobalScoreHelper *scoreHelper = [self globalScoreEntityToHelper:score];
            [less addObject:scoreHelper];
        }
        
        [result setObject:more forKey:@"more"];
        [result setObject:less forKey:@"less"];
    }];
    
    return result;
}

-(void)saveGlobalScores:(NSArray *)globalScores
{
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"GlobalScores"];
    [context performBlockAndWait:^{
        NSError *error = nil;
        NSArray *scores = [context executeFetchRequest:request error:&error];
        
        for (HighScores *score in scores) {
            [context deleteObject:score];
        }
        
        for (GlobalScoreHelper *scoreHelper in globalScores) {
            GlobalScores *globalScore = [NSEntityDescription insertNewObjectForEntityForName:@"GlobalScores" inManagedObjectContext:context];
            globalScore.score = scoreHelper.score;
            //globalScore.scoreDate = scoreHelper.scoreDate;
            globalScore.userName = scoreHelper.userName;
            globalScore.distance = scoreHelper.distance;
            globalScore.position = scoreHelper.position;
        }
        if ([context hasChanges]) {
            [DBAccessLayer saveContext:context async:NO];
        }
    }];
}

-(void)addHighScore:(HighScoreHelper *)scoreHelper
{
    NSManagedObjectContext *context = [DBAccessLayer createManagedObjectContext];
    
    [context performBlock:^{
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"HighScores"];
        
        NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
        int minHighScore = [self getMinimumHighScore];
        
        if ((count < 10 || scoreHelper.score.intValue > minHighScore) && scoreHelper.score.intValue > 0) {
            HighScores *newScore = [NSEntityDescription insertNewObjectForEntityForName:@"HighScores" inManagedObjectContext:context];
            newScore.score = scoreHelper.score;
            newScore.scoreDate = scoreHelper.scoreDate;
            newScore.name = scoreHelper.name;
            newScore.distance = scoreHelper.distance;
            if ([context hasChanges]) {
                [DBAccessLayer saveContext:context async:NO];
            }
        }
    }];
}

-(int)getMaximumHighScore
{
    __block int result = 0;
    
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
        NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        
        // Create an expression description using the minExpression and returning a date.
        NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
        
        // The name is the key that will be used in the dictionary for the return value.
        [expressionDescription setName:@"score"];
        [expressionDescription setExpression:maxExpression];
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

-(BOOL)uploadHighscore:(int)score
{
    NSString *checkString = [NSString stringWithFormat:@"%@%d", [UIDevice currentDevice].identifierForVendor.UUIDString, score];
    NSString *hmac = [CommonTools hmacForKey:kSecret andData:checkString];
    NetworkManager *manager = [NetworkManager createNetworkManager];
    RequestHelper *request = [[RequestHelper alloc] init];
    NSMutableDictionary *customHeaders = [NSMutableDictionary dictionary];
    [customHeaders setObject:hmac forKey:@"hmac"];
    [customHeaders setObject:checkString forKey:@"checkString"];
    request.customHeaders = customHeaders;
    request.requestUri = [NSString stringWithFormat:@"%@/%@/%@/%d", kServerBaseUrl, kPostScoreUrl, [UIDevice currentDevice].identifierForVendor.UUIDString, score];
    request.requestMethod = kHttpMethodPost;
    [manager performHttpRequest:request succesBlock:^(ResponseHelper *result) {
        NSData *responseData = [result.responseDict objectForKey:@"data"];
        if (responseData) {
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (!error) {
                NSNumber *globalPos = [responseDict objectForKey:@"position"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:score] forKey:kLastUploadedScoreKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (globalPos) {
                    [[NSUserDefaults standardUserDefaults] setObject:globalPos forKey:kGlobalPositionKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDirtyScoreKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } andFailBlock:^(ResponseHelper *result) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:score] forKey:kDirtyScoreKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    return YES;
}

-(void)getGlobalPositionFromServerWithCompletion:(void(^)(int result))completion andFail:(void(^)(void))fail
{
    int highScore = [self getMaximumHighScore];
    NSString *checkString = [NSString stringWithFormat:@"%@%d", [UIDevice currentDevice].identifierForVendor.UUIDString, highScore];
    NSString *hmac = [CommonTools hmacForKey:kSecret andData:checkString];
    NetworkManager *manager = [NetworkManager createNetworkManager];
    RequestHelper *request = [[RequestHelper alloc] init];
    NSMutableDictionary *customHeaders = [NSMutableDictionary dictionary];
    [customHeaders setObject:hmac forKey:@"hmac"];
    [customHeaders setObject:checkString forKey:@"checkString"];
    request.customHeaders = customHeaders;
    request.requestUri = [NSString stringWithFormat:@"%@/%@/%d", kServerBaseUrl, kGetGlobalPositionUrl, highScore];
    request.requestMethod = kHttpMethodGet;
    [manager performHttpRequest:request succesBlock:^(ResponseHelper *result) {
        NSData *responseData = [result.responseDict objectForKey:@"data"];
        //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if (responseData) {
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (!error) {
                NSNumber *globalPos = [responseDict objectForKey:@"position"];
                //NSLog(@"Global position: %@", globalPos);
                if (globalPos) {
                    [[NSUserDefaults standardUserDefaults] setObject:globalPos forKey:kGlobalPositionKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    completion(globalPos.intValue);
                } else {
                    fail();
                }
            } else {
                fail();
            }
        } else {
            fail();
        }
    } andFailBlock:^(ResponseHelper *result) {
        fail();
    }];
}

-(void)downloadSurroundingsWithCompletion:(void(^)(NSDictionary *scores))completion andFail:(void(^)(void))fail
{
    int highScore = [self getMaximumHighScore];
    NSNumber *lastHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:kLastUploadedScoreKey];
    if (lastHighScore) {
        if (highScore != lastHighScore.intValue) {
            [self uploadHighscore:highScore];
        }
        highScore = lastHighScore.intValue;
    }
    NSString *checkString = [NSString stringWithFormat:@"%@%d", [UIDevice currentDevice].identifierForVendor.UUIDString, highScore];
    NSString *hmac = [CommonTools hmacForKey:kSecret andData:checkString];
    NetworkManager *manager = [NetworkManager createNetworkManager];
    RequestHelper *request = [[RequestHelper alloc] init];
    NSMutableDictionary *customHeaders = [NSMutableDictionary dictionary];
    [customHeaders setObject:hmac forKey:@"hmac"];
    [customHeaders setObject:checkString forKey:@"checkString"];
    request.customHeaders = customHeaders;
    request.requestUri = [NSString stringWithFormat:@"%@/%@/%d", kServerBaseUrl, @"getSurroundingsForScore", highScore];
    request.requestMethod = kHttpMethodGet;
    [manager performHttpRequest:request succesBlock:^(ResponseHelper *result) {
        NSData *responseData = [result.responseDict objectForKey:@"data"];
        //NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if (responseData) {
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (!error) {
                NSArray *more = [responseDict objectForKey:@"more"];
                NSArray *less = [responseDict objectForKey:@"less"];
                NSMutableArray *resultArray = [NSMutableArray array];
                NSMutableArray *moreArray = [NSMutableArray array];
                NSMutableArray *lessArray = [NSMutableArray array];
                
                if (more) {
                    for (NSDictionary *scoreDict in more) {
                        GlobalScoreHelper *scoreHelper = [[GlobalScoreHelper alloc] init];
                        scoreHelper.score = NULL_TO_NIL([scoreDict objectForKey:@"score"]);
                        scoreHelper.scoreDate = NULL_TO_NIL([scoreDict objectForKey:@"timeStamp"]);
                        scoreHelper.userName = NULL_TO_NIL([scoreDict objectForKey:@"userName"]);
                        [resultArray addObject:scoreHelper];
                        [moreArray addObject:scoreHelper];
                    }
                }
                if (less) {
                    for (NSDictionary *scoreDict in less) {
                        GlobalScoreHelper *scoreHelper = [[GlobalScoreHelper alloc] init];
                        scoreHelper.score = NULL_TO_NIL([scoreDict objectForKey:@"score"]);
                        scoreHelper.scoreDate = NULL_TO_NIL([scoreDict objectForKey:@"timeStamp"]);
                        scoreHelper.userName = NULL_TO_NIL([scoreDict objectForKey:@"userName"]);
                        [resultArray addObject:scoreHelper];
                        [lessArray addObject:scoreHelper];
                    }
                }
                [self saveGlobalScores:resultArray];
                
                completion([NSDictionary dictionaryWithObjects:@[moreArray, lessArray] forKeys:@[@"more", @"less"]]);
            } else {
                fail();
            }
        } else {
            fail();
        }
    } andFailBlock:^(ResponseHelper *result) {
        fail();
    }];
}

-(HighScoreHelper *)scoreEntityToHelper:(HighScores *)score
{
    HighScoreHelper *scoreHelper = [[HighScoreHelper alloc] init];
    scoreHelper.score = score.score;
    scoreHelper.scoreDate = score.scoreDate;
    scoreHelper.name = score.name;
    scoreHelper.distance = score.distance;
    return scoreHelper;
}

-(GlobalScoreHelper *)globalScoreEntityToHelper:(GlobalScores *)score
{
    GlobalScoreHelper *scoreHelper = [[GlobalScoreHelper alloc] init];
    scoreHelper.score = score.score;
    //scoreHelper.scoreDate = score.scoreDate;
    scoreHelper.userName = score.userName;
    scoreHelper.distance = score.distance;
    scoreHelper.position = score.position;
    return scoreHelper;
}

@end
