//
//  StrokeLabel.m
//  RunnerGame
//
//  Created by Ivan Borsa on 13/06/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "StrokeLabel.h"

@implementation StrokeLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.strokeColor = [UIColor blackColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = _strokeColor;
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
    
}

@end
