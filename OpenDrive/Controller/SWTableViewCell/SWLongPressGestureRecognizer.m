//
//  SWLongPressGestureRecognizer.m
//  OpenDrive
//
//  Created by ioshero on 1/12/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import "SWLongPressGestureRecognizer.h"

@implementation SWLongPressGestureRecognizer

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateFailed;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateFailed;
}

@end

