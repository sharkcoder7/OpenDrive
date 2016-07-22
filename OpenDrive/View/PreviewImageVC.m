//
//  PreviewImageVC.m
//  OpenDrive
//
//  Created by Alexander Chulanov on 2/23/16.
//  Copyright © 2016 Alexander Chulanov. All rights reserved.
//

#import "PreviewImageVC.h"
#import "DataKeeper.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "ODProgressView.h"
#import "config.h"

@interface PreviewImageVC ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonItemPrev;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonItemNext;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonPrevTip;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonNextTip;
@property (strong, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) IBOutlet ODProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBarAction;

@property (strong, nonatomic) NSMutableArray *arrayImages;
@property (assign, nonatomic) NSInteger currentIndex;

@end

@implementation PreviewImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getImageData];
    
    [self initNavigationBar];
    [self initToolBarItem];
    [self initUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    [self loadImage:dataKeeper.currentFileDataModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBar
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    self.navigationItem.title = dataKeeper.currentFileDataModel.fileName;
    [self.navigationController.navigationBar setBarTintColor:OpenDrive_TightGrayColor];
    [self.navigationController.navigationBar setTintColor:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)initToolBarItem
{
    _toolBarAction.backgroundColor = OpenDrive_TightGrayColor;
    [self enableBarItems];
}

- (void)getImageData
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    _currentIndex = [dataKeeper.currentFolderDataModel.arrayFiles indexOfObject:dataKeeper.currentFileDataModel];
    _arrayImages = [NSMutableArray array];
    
    for (NSInteger i = 0 ; i < dataKeeper.currentFolderDataModel.arrayFiles.count ; i ++) {
        FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:i];
        NSString *extension = [fileDataModel.extension lowercaseString];
        if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"png"])
        {
            [_arrayImages addObject:fileDataModel];
        }
    }
}

- (void)enableBarItems
{
    _barButtonItemPrev.enabled = [self enablePreviewOption];
    _barButtonPrevTip.enabled = [self enablePreviewOption];
    _barButtonItemNext.enabled = [self enableNextOption];
    _barButtonNextTip.enabled = [self enableNextOption];
}

- (void)initUI
{
    self.view.backgroundColor = OpenDrive_Preview_BackgroundColor;

    [_progressView setShowsText:YES];
    [_progressView setRadius:self.view.frame.size.width / 8];
    [_progressView setUsesVibrancyEffect:NO];
    [_progressView setIndeterminate:YES];
    _progressView.textSize = 30;

    [_previewImageView setUserInteractionEnabled:YES];

    UIPinchGestureRecognizer *pinchTap = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_previewImageView addGestureRecognizer:pinchTap];
    
    UIPanGestureRecognizer *panTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_previewImageView addGestureRecognizer:panTap];
}

- (void)loadImage:(FileDataModel*)model
{
    self.navigationItem.title = model.fileName;
    
    _barButtonItemPrev.enabled = NO;
    _barButtonPrevTip.enabled = NO;
    _barButtonItemNext.enabled = NO;
    _barButtonNextTip.enabled = NO;
    
    [_previewImageView setImage:nil];
    
    _currentIndex = [_arrayImages indexOfObject:model];
    
    _progressView.progress = 0;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.downloadLink]];
    
    __weak PreviewImageVC *weakSelf = self;
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIImage *image = [UIImage imageWithData:responseObject];
        [weakSelf.previewImageView setImage:image];
        [weakSelf.previewImageView layoutIfNeeded];
        [weakSelf enableBarItems];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
    __weak AFHTTPRequestOperation *weakOperation = operation;
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)weakOperation.response;
        NSString *contentLength = [[response allHeaderFields] objectForKey:@"Content-Length"];
        if (contentLength != nil)
            totalBytesExpectedToRead = [contentLength doubleValue];
        
        CGFloat downloadProgress = (float) totalBytesRead/totalBytesExpectedToRead;
        [weakSelf.progressView setProgress:downloadProgress animated:YES];
    }];
    
    [operation start];
}

- (BOOL)enablePreviewOption
{
    if (_currentIndex <= 0)
        return NO;
    
    return YES;
}

- (BOOL)enableNextOption
{
    if (_currentIndex >= (_arrayImages.count - 1))
        return NO;
    
    return YES;
}

- (void)didTapImage:(UISwipeGestureRecognizer*)tap
{
    if (tap.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        FileDataModel *fileDataModel = [_arrayImages objectAtIndex:_currentIndex - 1];
        [self loadImage:fileDataModel];
    }
    else
    {
        FileDataModel *fileDataModel = [_arrayImages objectAtIndex:_currentIndex + 1];
        [self loadImage:fileDataModel];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer*)pinch
{
    _previewImageView.transform = CGAffineTransformScale(_previewImageView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
}

- (void)handlePan:(UIPanGestureRecognizer*)pan
{
    CGPoint translation = [pan translationInView:_previewImageView];
    _previewImageView.center = CGPointMake(_previewImageView.center.x + translation.x, _previewImageView.center.y + translation.y);
    [pan setTranslation:CGPointMake(0, 0) inView:_previewImageView];
}

- (IBAction)previousAction:(id)sender
{
    FileDataModel *fileDataModel = [_arrayImages objectAtIndex:_currentIndex - 1];
    [self loadImage:fileDataModel];
 }

- (IBAction)nextAction:(id)sender
{
    FileDataModel *fileDataModel = [_arrayImages objectAtIndex:_currentIndex + 1];
    [self loadImage:fileDataModel];
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
