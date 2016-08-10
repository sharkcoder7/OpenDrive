//
//  LaunchScreenVC.m
//  OpenDrive
//
//  Created by ioshero on 3/31/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import "LaunchScreenVC.h"
#import "config.h"
#import "FilesScreenVC.h"
#import "WelcomeVC.h"
#import "DataKeeper.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "UserDataModel.h"

@interface LaunchScreenVC ()

@end

@implementation LaunchScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:UserDefault_SessionID_Key] && [userDefaults objectForKey:UserDefault_UserID_Key])
    {
        NSString *sessionID = [userDefaults objectForKey:UserDefault_SessionID_Key];
        NSString *userID = [userDefaults objectForKey:UserDefault_UserID_Key];
        if (sessionID && userID)
        {
            [self existSession:^(BOOL isExist) {
                if (isExist) {
                    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
                    dataKeeper.userDataModel.userID = userID;
                    dataKeeper.userDataModel.sessionID = sessionID;
                    
                    [self getBrandingInfo:userID Session:sessionID];
                }
                else
                {
                    WelcomeVC *welcomeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomScreen"];
                    [self.navigationController pushViewController:welcomeVC animated:NO];
                }
            }];
        }
    }
}

- (void)existSession:(void(^)(BOOL isExist))callback
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:UserDefault_SessionID_Key])
    {
        NSString *sessionID = [userDefaults objectForKey:UserDefault_SessionID_Key];
        if (sessionID)
        {
            NSDictionary *param = [[HttpClient sharedClient] getExistSessionParams:sessionID];
            [[HttpClient sharedClient] post:Post_SessionExistURL withParam:param withSuccessBlock:^(NSDictionary *responseDic) {
                BOOL isExist = [[responseDic objectForKey:@"result"] boolValue];
                
                if (callback)
                    callback(isExist);
            } withFailureBlock:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        }
    }
}

- (void)getBrandingInfo:(NSString*)userId Session:(NSString*)sessionId
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    };
    void (^successBlock)(NSDictionary *responseDic) = ^(NSDictionary *responseDic)
    {
        [dataKeeper.currentBrandDataModel initBrandInfo:responseDic];
        
        FilesScreenVC *filesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesScreen"];
        [self.navigationController pushViewController:filesVC animated:NO];
    };
    
    NSDictionary *param = [[HttpClient sharedClient] getUserBrandingInfo:userId Session:sessionId];
    [[HttpClient sharedClient] get:Get_UserBrandingInfoURL
                         withParam:param
                  withSuccessBlock:successBlock
                  withFailureBlock:failureBlock];
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

@end
