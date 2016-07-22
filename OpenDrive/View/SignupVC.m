//
//  SignupVC.m
//  OpenDrive
//
//  Created by Bin Jin on 12/27/15.
//  Copyright © 2015 Bin Jin. All rights reserved.
//

#import "SignupVC.h"
#import "SVProgressHUD.h"
#import "config.h"
#import "HttpClient.h"
#import "FilesScreenVC.h"
#import "DataKeeper.h"

@interface SignupVC ()

@property (strong, nonatomic) IBOutlet UITextField *textfieldFirstName;
@property (strong, nonatomic) IBOutlet UITextField *textfieldLastName;
@property (strong, nonatomic) IBOutlet UITextField *textfieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *textfieldPassword;

- (IBAction)signupAction:(id)sender;

- (BOOL) isValidEmail:(NSString *)checkString;
- (BOOL) isValidInfo;

@end

@implementation SignupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.title = @"Sign Up";
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

- (IBAction)signupAction:(id)sender {
    if ([self isValidInfo] == NO)
        return;
    
    NSString *firstName = _textfieldFirstName.text;
    NSString *lastName = _textfieldLastName.text;
    NSString *email = _textfieldEmail.text;
    NSString *password = _textfieldPassword.text;
    NSString *username = [NSString stringWithFormat:@"%@%@", firstName, lastName];
    
    [_textfieldFirstName resignFirstResponder];
    [_textfieldLastName resignFirstResponder];
    [_textfieldEmail resignFirstResponder];
    [_textfieldPassword resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"Waitng"];
    
    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    };
    void (^successBlock)(NSDictionary *responseDic) = ^(NSDictionary *responseDic)
    {
        [SVProgressHUD dismiss];
        
        [self getResponseData:responseDic];
        
        FilesScreenVC *filesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FilesScreen"];
        [self.navigationController pushViewController:filesVC animated:YES];
    };
		
    NSString *postURL = [NSString stringWithFormat:@"%@%@", ServerURL, Post_SignURL];
    NSDictionary *paramDic = [[HttpClient sharedClient] getCreateUserParams:username Email:email Password:password FirstName:firstName LastName:lastName CreatedById:@"1"];
    
    [[HttpClient sharedClient] post:postURL
                               withParam:paramDic
                        withSuccessBlock:successBlock
                        withFailureBlock:failureBlock];
}

- (BOOL) isValidInfo
{
    NSString *firstName = _textfieldFirstName.text;
    if (firstName == nil || [firstName isEqualToString:@""] || firstName.length < 2 || firstName.length > 50)
    {
        [SVProgressHUD showInfoWithStatus:@"Invalid first name"];
        return NO;
    }
    
    NSString *lastName = _textfieldLastName.text;
    if (lastName == nil || [lastName isEqualToString:@""] || lastName.length < 2 || lastName.length > 50)
    {
        [SVProgressHUD showInfoWithStatus:@"Invalid last name"];
        return NO;
    }
    
    NSString *email = _textfieldEmail.text;
    if (email == nil || [email isEqualToString:@""] || [self isValidEmail:email] == NO)
    {
        [SVProgressHUD showInfoWithStatus:@"Invalid email"];
        return NO;
    }
    
    NSString *password = _textfieldPassword.text;
    if (password == nil || [password isEqualToString:@""] || password.length < 5)
    {
        [SVProgressHUD showInfoWithStatus:@"Invalid password. Minimum 4 characters required"];
        return NO;
    }
    
    return YES;
}

- (BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)getResponseData:(NSDictionary*)responseDic
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    [dataKeeper.userDataModel initUserDataModel:responseDic];
}

@end
