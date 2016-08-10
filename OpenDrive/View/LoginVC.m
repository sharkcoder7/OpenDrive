//
//  LoginVC.m
//  OpenDrive
//
//  Created by ioshero on 12/27/15.
//  Copyright © 2015 ioshero. All rights reserved.
//

#import "LoginVC.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "config.h"
#import "HttpClient.h"
#import "OVTextField.h"
#import "FilesScreenVC.h"
#import "DataKeeper.h"
#import "UserDataModel.h"

@interface LoginVC ()

@property (strong, nonatomic) IBOutlet OVTextField *textfieldEmail;
@property (strong, nonatomic) IBOutlet OVTextField *textfieldPassword;

- (IBAction)loginAction:(id)sender;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.title = @"Log In";
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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

- (IBAction)loginAction:(id)sender
{
    NSString *email = _textfieldEmail.text;
    if (email == nil || [email isEqualToString:@""])
    {
        [SVProgressHUD showInfoWithStatus:@"UserName empty"];
        return;
    }
    
    NSString *password = _textfieldPassword.text;
    if (password == nil || [password isEqualToString:@""])
    {
        [SVProgressHUD showInfoWithStatus:@"Password empty"];
        return;
    }

    [_textfieldEmail resignFirstResponder];
    [_textfieldPassword resignFirstResponder];
    
    [SVProgressHUD show];

    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    };
    void (^successBlock)(NSDictionary *responseDic) = ^(NSDictionary *responseDic)
    {
        [self getResponseData:responseDic];
        [self saveAuthentication];
        
        [self getBrandingInfo];
    };
    
    NSDictionary *param = [[HttpClient sharedClient] getSessionLoginParams:email Password:password];
    
    [[HttpClient sharedClient] post:Post_LoginURL
                                withParam:param
                                withSuccessBlock:successBlock
                                withFailureBlock:failureBlock];
}

- (void)getResponseData:(NSDictionary*)responseDic
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    [dataKeeper.userDataModel initUserDataModel:responseDic];
}

- (void)saveAuthentication
{
    DataKeeper *dateKeeper = [DataKeeper sharedInstance];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setValue:dateKeeper.userDataModel.sessionID forKey:UserDefault_SessionID_Key];
    [prefs setValue:dateKeeper.userDataModel.userID forKey:UserDefault_UserID_Key];
    [prefs synchronize];
}

- (void)getBrandingInfo
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    [SVProgressHUD show];
    
    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    };
    void (^successBlock)(NSDictionary *responseDic) = ^(NSDictionary *responseDic)
    {
        [SVProgressHUD dismiss];
        
        [dataKeeper.currentBrandDataModel initBrandInfo:responseDic];
        
        FilesScreenVC *filesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesScreen"];
        [self.navigationController pushViewController:filesVC animated:YES];
    };
    
    NSDictionary *param = [[HttpClient sharedClient] getUserBrandingInfo:dataKeeper.userDataModel.userID Session:dataKeeper.userDataModel.sessionID];
    [[HttpClient sharedClient] get:Get_UserBrandingInfoURL
                          withParam:param
                   withSuccessBlock:successBlock
                   withFailureBlock:failureBlock];
}

@end

