//
//  HighScoreCell.h
//  RunnerGame
//
//  Created by Ivan Borsa on 10/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrokeLabel.h"

@interface HighScoreCell : UITableViewCell

@property (nonatomic, weak) IBOutlet StrokeLabel *indexLabel;
@property (nonatomic, weak) IBOutlet StrokeLabel *scoreLabel;
@property (nonatomic, weak) IBOutlet StrokeLabel *distanceLabel;

@end
