//
//  HighScoreCell.h
//  RunnerGame
//
//  Created by Ivan Borsa on 10/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoreCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *indexLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;

@end
