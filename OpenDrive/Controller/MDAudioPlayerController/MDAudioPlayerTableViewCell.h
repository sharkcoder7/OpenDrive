//
//  MDAudioPlayerTableViewCell.h
//  OpenDrive
//
//  Created by Bin Jin on 2/22/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MDAudioPlayerTableViewCell : UITableViewCell
{
	UIView				*contentView;
	
	NSString			*title;
	NSString			*number;
	NSString			*duration;
	
	BOOL				isEven;
	BOOL				isSelectedIndex;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *duration;

@property (nonatomic, assign) BOOL isEven;
@property (nonatomic, assign) BOOL isSelectedIndex;

- (void)drawContentView:(CGRect)r;

@end
