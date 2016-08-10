//
//  RenameVC.m
//  OpenDrive
//
//  Created by ioshero on 2/22/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import "RenameVC.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "DataKeeper.h"
#import "HttpClient.h"
#import "IQKeyboardManager.h"
#import "config.h"

@interface RenameVC ()

@property (strong, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (strong, nonatomic) IBOutlet UITextField *textFieldFileName;
@property (assign, nonatomic) BOOL shouldMoveCursor;

@end

@implementation RenameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.shouldMoveCursor = YES;
    
    [self initNavigationBar];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBar
{
    self.view.backgroundColor = OpenDrive_TightGrayColor;
    
    self.navigationItem.title = @"Rename";
    [self.navigationController.navigationBar setBarTintColor:OpenDrive_TightGrayColor];
    [self.navigationController.navigationBar setTintColor:nil];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)initUI
{
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.fileDataModel.thumbLink]];
    
    __unsafe_unretained RenameVC *weakSelf = self;
    
    [_thumbImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        CGSize size = CGSizeMake(32, 32);
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [weakSelf.thumbImageView setImage:thumbnail];
        [weakSelf.thumbImageView layoutIfNeeded];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
    {
    }];

    [_textFieldFileName setText:self.fileDataModel.fileName];
    [_textFieldFileName setTextColor:Folder_Text_Color];
    [_textFieldFileName becomeFirstResponder];
}

- (void)moveCoursorOfTextField
{
    NSString *fileName = _textFieldFileName.text;
    NSArray *strings = [fileName componentsSeparatedByString:@"."];
    NSInteger offset = 0;
    if (strings.count <= 1)
        offset = 0;
    else
    {
        NSString *string = [strings objectAtIndex:strings.count - 1];
        offset = string.length + 1;
    }
    
    UITextRange *selectedRange = [_textFieldFileName selectedTextRange];
    UITextPosition *newPosition = [_textFieldFileName positionFromPosition:selectedRange.start offset:-offset];
    UITextRange *newRange = [_textFieldFileName textRangeFromPosition:newPosition toPosition:newPosition];
    [_textFieldFileName setSelectedTextRange:newRange];
}

- (void)save
{
    NSString *fileName = _textFieldFileName.text;
    if (fileName == nil || [fileName isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"Invalid File Name"];
        return;
    }
    
    [_textFieldFileName resignFirstResponder];
    
    [SVProgressHUD showWithStatus:@"Renaming"];
    
    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    };
    void (^successBlock)(NSDictionary *responseDic) = ^(NSDictionary *responseDic)
    {
        [SVProgressHUD showSuccessWithStatus:@"Renamed"];
        
        [self enableSaveItem];
        [self.navigationController popViewControllerAnimated:YES];
    };

    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    NSDictionary *param = [[HttpClient sharedClient] getFileRenameParams:dataKeeper.userDataModel.sessionID NewFileName:_textFieldFileName.text FileId:self.fileDataModel.fileID];
    
    [[HttpClient sharedClient] post:Post_FileRenameURL
                          withParam:param
                   withSuccessBlock:successBlock
                   withFailureBlock:failureBlock];
}

- (void)enableSaveItem
{
    NSString *fileName = _textFieldFileName.text;
    
    if (fileName == nil || [fileName isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"Invalid File Name"];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else if ([fileName isEqualToString:self.fileDataModel.fileName])
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (IBAction)textFieldDidChange:(id)sender
{
    [self enableSaveItem];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textFieldFileName resignFirstResponder];
    
    [self enableSaveItem];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_shouldMoveCursor)
    {
        _shouldMoveCursor = NO;
        
        [self moveCoursorOfTextField];
    }
}

@end
