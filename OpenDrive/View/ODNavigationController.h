//
//  ODNavigationController.h
//  OpenDrive
//
//  Created by ioshero on 1/22/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBar.h"

@interface ODNavigationController : UINavigationController

@property (strong, nonatomic) SideBar *menuSideBar;
@property (strong, nonatomic) UITapGestureRecognizer *tap;

- (void)menuAction:(id)sender;

@end
