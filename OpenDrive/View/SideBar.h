//
//  SideBar.h
//  OpenDrive
//
//  Created by Bin Jin on 1/14/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SELECTED_EXPLORER = 0,
    SELECTED_SETTING,
    SELECTED_LOGOUT
} SideBarItem;

@protocol SideBarDelegate <NSObject>

@optional
- (void)tapMenuItem:(SideBarItem)selectedItem;

@end

@interface SideBar : UIView

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftLayoutConstraint;
@property (assign, nonatomic) id <SideBarDelegate> delegate;

- (BOOL)isOpenSideBar;
- (void)setBarStatus:(BOOL)bOpen;
- (void)selectedMenuItem:(SideBarItem)selectedItem;

- (void)hide;
- (void)show;

- (void)initSwipeGesture:(UIViewController *)viewController;

@end
