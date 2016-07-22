//
//  OVTextField.m
//  OpenDrive
//
//  Created by Admin on 1/4/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "OVTextField.h"
#import "config.h"

@implementation OVTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    CGFloat fontSize = 16.0f;
    if (IS_IPHONE_6)
        fontSize = 14;
    else if(IS_IPHONE_5)
        fontSize = 13;
    
    if ([self.attributedPlaceholder length])
    {
        UIColor *color = [UIColor grayColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[self.attributedPlaceholder string] attributes:@{
                                                     NSForegroundColorAttributeName:color,
                                                     NSFontAttributeName:[UIFont systemFontOfSize:fontSize]
                                                     }];
    }
    
    [self setFont:[UIFont systemFontOfSize:fontSize - 1]];
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 23, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 23, 10);
}

@end
