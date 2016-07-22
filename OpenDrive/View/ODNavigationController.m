//
//  ODNavigationController.m
//  OpenDrive
//
//  Created by Bin Jin on 1/22/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "ODNavigationController.h"
#import "DataKeeper.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "FolderDataModel.h"

@interface ODNavigationController () <SideBarDelegate>

@property (strong, nonatomic) NSLayoutConstraint *topLC;
@property (strong, nonatomic) NSLayoutConstraint *heightLC;

- (void)initSideBar;

@end

@implementation ODNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSideBar];
}

- (void)viewWillLayoutSubviews
{
    if (self.menuSideBar)
    {
        CGFloat offset = (self.view.bounds.size.height > self.view.bounds.size.width)? (self.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height) : self.navigationBar.frame.size.height;
        self.topLC.constant = offset;
        self.heightLC.constant = -offset;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initSideBar
{
    self.menuSideBar = [[[NSBundle mainBundle] loadNibNamed:@"SideBar" owner:self options:nil] objectAtIndex:0];
    self.menuSideBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.menuSideBar.delegate = self;
    [self.menuSideBar initSwipeGesture:self];
    [self.view addSubview:self.menuSideBar];
    
    self.menuSideBar.leftLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.menuSideBar
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:-46];
    
    [self.view addConstraint:self.menuSideBar.leftLayoutConstraint];
    
    CGFloat offset = (self.view.bounds.size.height > self.view.bounds.size.width)? (self.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height) : self.navigationBar.frame.size.height;
    
    self.topLC = [NSLayoutConstraint constraintWithItem:self.menuSideBar
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0
                                               constant:offset];
    [self.view addConstraint:self.topLC];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuSideBar
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:46.0]];
    
    self.heightLC = [NSLayoutConstraint constraintWithItem:self.menuSideBar
                                                 attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:self.view
                                                 attribute:NSLayoutAttributeHeight
                                                multiplier:1.0
                                                  constant:-offset];
    [self.view addConstraint:self.heightLC];
    
    [self.view updateConstraints];
}

- (void)closeSession
{
    __weak ODNavigationController *weakSelf = self;
    
    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    };
    void (^successBlock)(NSDictionary *responseDic) = ^(NSDictionary *responseDic)
    {
        [SVProgressHUD dismiss];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [prefs dictionaryRepresentation];
        for (id key in dic) {
            [prefs removeObjectForKey:key];
        }
        [prefs synchronize];
        
        DataKeeper *dataKeeper = [DataKeeper sharedInstance];
        [dataKeeper.currentFolderDataModel.arrayFiles removeAllObjects];
        [dataKeeper.currentFolderDataModel.subFolders removeAllObjects];
        [dataKeeper.currentFolderDataModel reset];
        
        [weakSelf popToRootViewControllerAnimated:YES];
    };
    
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:dataKeeper.userDataModel.sessionID, @"session_id", nil];
    
    [[HttpClient sharedClient] post:Post_SessionLogOutURL
                          withParam:param
                   withSuccessBlock:successBlock
                   withFailureBlock:failureBlock];
}

- (void)menuAction:(id)sender
{
    [self.view layoutIfNeeded];
    
    if (self.menuSideBar.isOpenSideBar)
        [self.menuSideBar hide];
    else
        [self.menuSideBar show];
}

#pragma mark - SideBar Delegate

- (void)tapMenuItem:(SideBarItem)selectedItem
{
    [self.menuSideBar selectedMenuItem:selectedItem];
    switch (selectedItem) {
        case SELECTED_EXPLORER:
            break;
        case SELECTED_SETTING:
            break;
        case SELECTED_LOGOUT:
        {
            [self.menuSideBar hide];
            [self closeSession];
        }
            break;
        default:
            break;
    }
}


@end
