//
//  SideBar.m
//  OpenDrive
//
//  Created by Bin Jin on 1/14/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "SideBar.h"
#import "config.h"

@interface SideBar ()

@property (strong, nonatomic) IBOutlet UIButton         *buttonExplorer;
@property (strong, nonatomic) IBOutlet UIButton         *buttonSetting;
@property (strong, nonatomic) IBOutlet UIButton         *buttonLogout;
@property (strong, nonatomic) UISwipeGestureRecognizer  *leftSwipe;
@property (strong, nonatomic) UISwipeGestureRecognizer  *rightSwipe;
@property (strong, nonatomic) UITapGestureRecognizer    *tap;
@property (strong, nonatomic) UIViewController          *viewController;

@property (assign, nonatomic) BOOL isOpen;

- (IBAction)menuAction:(id)sender;
- (UIImage *)imageWithColor:(UIColor*)color;

@end

@implementation SideBar

- (void)awakeFromNib
{
    _isOpen = NO;
    
    [_buttonExplorer setBackgroundImage:[self imageWithColor:OpenDrive_Color] forState:UIControlStateSelected];
    [_buttonExplorer setSelected:YES];

    [_buttonSetting setSelected:NO];
    [_buttonSetting setBackgroundImage:[self imageWithColor:OpenDrive_Color] forState:UIControlStateSelected];
}

- (BOOL)isOpenSideBar
{
    return _isOpen;
}

- (void)setBarStatus:(BOOL)bOpen
{
    _isOpen  = bOpen;
    if (_isOpen)
        [_viewController.view addGestureRecognizer:_tap];
    else
        [_viewController.view removeGestureRecognizer:_tap];
}

- (IBAction)menuAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapMenuItem:)])
        [self.delegate tapMenuItem:(SideBarItem)tag];
}

- (UIImage *)imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)selectedMenuItem:(SideBarItem)selectedItem
{
    switch (selectedItem) {
        case SELECTED_EXPLORER:
        {
            [_buttonExplorer setSelected:YES];
            [_buttonSetting setSelected:NO];
            [_buttonLogout setSelected:NO];
        }
            break;
        case SELECTED_SETTING:
        {
            [_buttonExplorer setSelected:NO];
            [_buttonSetting setSelected:YES];
            [_buttonLogout setSelected:NO];
        }
            break;
        default:
            break;
    }
}

- (void)hide
{
    if (!_isOpen)
        return;
    
    self.leftLayoutConstraint.constant = -46;
    
    [UIView animateWithDuration:0.5f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self setBarStatus:NO];
    }];
}

- (void)show
{
    if (_isOpen)
        return;
    
    self.leftLayoutConstraint.constant = 0;
    
    [UIView animateWithDuration:0.5f animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self setBarStatus:YES];
    }];
}

- (void)initSwipeGesture:(UIViewController *)viewController
{
    _rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(show)];
    _rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [viewController.view addGestureRecognizer:_rightSwipe];
    
    _leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    _leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [viewController.view addGestureRecognizer:_leftSwipe];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    
    _viewController = viewController;
}

@end
