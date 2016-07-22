//
//  PreviewImageVC.m
//  OpenDrive
//
//  Created by Bin Jin on 2/23/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "PreviewVC.h"
#import "DataKeeper.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "ODProgressView.h"
#import "config.h"
#import "StyledPageControl.h"
#import "MDAudioFile.h"
#import "MDAudioPlayerController.h"
#import "Global.h"
#import "UIKit+AFNetworking.h"
#import "AudioStreamingPlayerVC.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <QuickLook/QuickLook.h>

@interface PreviewVC () <UIDocumentInteractionControllerDelegate, AVAudioPlayerDelegate, MDAudioPlayerControllerDelegate, AudioStreamingPlayerDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource, UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonItemPrev;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonItemNext;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonPrevTip;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonNextTip;
@property (strong, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageProgressView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBarAction;

@property (strong, nonatomic) IBOutlet UIView *viewImage;
@property (strong, nonatomic) IBOutlet UIView *viewMovie;
@property (strong, nonatomic) IBOutlet UIView *viewAudio;
@property (strong, nonatomic) IBOutlet UIView *viewDoc;
@property (strong, nonatomic) IBOutlet UIView *viewNone;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet ODProgressView *progressWebView;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) IBOutlet UIButton *buttonPlay;
@property (strong, nonatomic) IBOutlet UISlider *audioSlider;

@property (strong, nonatomic) NSMutableArray *arrayImages;
@property (assign, nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) UIDocumentInteractionController *documentViewController;
@property (strong, nonatomic) NSString *currentFilePath;

@end

@implementation PreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    self.currentIndex = [dataKeeper.currentFolderDataModel.arrayFiles indexOfObject:dataKeeper.currentFileDataModel];
    
    [self initNavigationBar];
    [self initToolBarItem];
    [self initUI];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavigationBar
{
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
  
    [self.progressWebView setShowsText:YES];
    [self.progressWebView setRadius:self.view.frame.size.width / 10];
    [self.progressWebView setUsesVibrancyEffect:NO];
    [self.progressWebView setIndeterminate:YES];
    self.progressWebView.textSize = 30;
    
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    [self filePreview:dataKeeper.currentFileDataModel];
    
    UIPinchGestureRecognizer *pinchTap = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.previewImageView addGestureRecognizer:pinchTap];
    
    UIPanGestureRecognizer *panTap = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.previewImageView addGestureRecognizer:panTap];
}

- (void)filePreview:(FileDataModel*)model
{
    [self enableBarItems];
    
    [self.audioPlayer stop];
    
    self.navigationItem.title = model.fileName;
    
    NSString *extension = [model.extension lowercaseString];
    FileType fileType = [Global getFileType:extension];
    if (fileType >= JPEG && fileType <= TIFF)
    {
        [self previewImage:model];
    }
    else if (fileType >= MOV && fileType <= AVI)
    {
        [self previewMovieTypeFile:model];
    }
    else if (fileType >= MP3 && fileType <= M4A)
    {
        [self previewAudioTypeFile:model];
    }
    else if (fileType >= DOC && fileType <= RTF)
    {
        [self previewDocTypeFile:model];
    }
    else if (fileType >= HTM && fileType <= HTML)
    {
        [self previewDocTypeFile:model];
    }
    else
    {
        if ([self enableNextOption])
        {
            [self next];
        }
        else
        {
            [self.viewImage setHidden:YES];
            [self.viewMovie setHidden:YES];
            [self.viewAudio setHidden:YES];
            [self.viewDoc setHidden:YES];
            [self.viewNone setHidden:NO];
        }
    }
}

- (void)previewImage:(FileDataModel*)model
{
    [self.viewImage setHidden:NO];
    [self.viewMovie setHidden:YES];
    [self.viewAudio setHidden:YES];
    [self.viewDoc setHidden:YES];
    [self.viewNone setHidden:YES];
       
    [self.previewImageView setImage:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.streamingLink]];
    [self.imageProgressView startAnimating];
    
    __weak PreviewVC *weakSelf = self;
    [self.previewImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [weakSelf.imageProgressView stopAnimating];
        [weakSelf.previewImageView setImage:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

    }];
}

- (void)previewMovieTypeFile:(FileDataModel*)model
{
    [self.viewImage setHidden:YES];
    [self.viewMovie setHidden:NO];
    [self.viewAudio setHidden:YES];
    [self.viewDoc setHidden:YES];
    [self.viewNone setHidden:YES];
    
    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:model.streamingLink]];
    movieController.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    [movieController.moviePlayer prepareToPlay];
    [movieController.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    movieController.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    
    [self presentViewController:movieController animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:movieController.moviePlayer];
}

- (void)previewAudioTypeFile:(FileDataModel*)model
{
    [self.viewImage setHidden:YES];
    [self.viewMovie setHidden:YES];
    [self.viewAudio setHidden:NO];
    [self.viewDoc setHidden:YES];
    [self.viewNone setHidden:YES];
    
    AudioStreamingPlayerVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioStreamingPlayerVC"];
    vc.audioURL = [NSURL URLWithString:model.streamingLink];
    vc.titleFileName = model.fileName;
    vc.delegate = self;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)previewDocTypeFile:(FileDataModel*)model;
{
    [self.viewImage setHidden:YES];
    [self.viewMovie setHidden:YES];
    [self.viewAudio setHidden:YES];
    [self.viewDoc setHidden:NO];
    [self.viewNone setHidden:YES];
    
    self.progressWebView.progress = 0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.currentFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:model.fileName];
    NSLog(@"Download - %@", self.currentFilePath);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentFilePath])
    {
        [self.progressWebView setHidden:YES];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.currentFilePath]];
        [self.webView loadRequest:request];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:model.downloadLink];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:self.currentFilePath append:NO];
        
        __weak AFHTTPRequestOperation *weakOperation = operation;
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse*)weakOperation.response;
            NSString *contentLength = [[response allHeaderFields] objectForKey:@"Content-Length"];
            if (contentLength != nil)
                totalBytesExpectedToRead = [contentLength doubleValue];
            
            CGFloat downloadProgress = (float) totalBytesRead/totalBytesExpectedToRead;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressWebView setProgress:downloadProgress animated:YES];
            });
        }];
        
        [operation start];
    }
}

- (BOOL)enablePreviewOption
{
    if (self.currentIndex <= 0)
        return NO;
    
    return YES;
}

- (BOOL)enableNextOption
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    if (self.currentIndex >= (dataKeeper.currentFolderDataModel.arrayFiles.count - 1))
        return NO;
    
    return YES;
}

- (void)previous
{
    self.currentIndex = self.currentIndex - 1;
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:self.currentIndex];
    [self filePreview:fileDataModel];
}

- (void)next
{
    self.currentIndex = self.currentIndex + 1;
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:self.currentIndex];
    [self filePreview:fileDataModel];
}

- (void)handlePinch:(UIPinchGestureRecognizer*)pinch
{
    self.previewImageView.transform = CGAffineTransformScale(self.previewImageView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
}

- (void)handlePan:(UIPanGestureRecognizer*)pan
{
    CGPoint translation = [pan translationInView:self.previewImageView];
    self.previewImageView.center = CGPointMake(self.previewImageView.center.x + translation.x, self.previewImageView.center.y + translation.y);
    [pan setTranslation:CGPointMake(0, 0) inView:self.previewImageView];
}

- (IBAction)previousAction:(id)sender
{
    [self previous];
}

- (IBAction)nextAction:(id)sender
{
    [self next];
}

- (IBAction)playAction:(id)sender
{
    if ([self.audioPlayer isPlaying]) {
        [self.buttonPlay setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
        [self.audioPlayer play];
    }
    else {
        [self.buttonPlay setImage:[UIImage imageNamed:@"AudioPlayerPlay.png"] forState:UIControlStateNormal];
        [self.audioPlayer pause];
    }
}

#pragma mark - Notification

- (void)moviePlayerDidFinish:(NSNotification *)note
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];

/*
    [self dismissMoviePlayerViewControllerAnimated];
    
    if ([self enableNextOption])
    {
        self.currentIndex = self.currentIndex + 1;
        DataKeeper *dataKeeper = [DataKeeper sharedInstance];
        FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:self.currentIndex];
        [self filePreview:fileDataModel];
    }
    else
    {
        self.currentIndex = self.currentIndex - 1;
        DataKeeper *dataKeeper = [DataKeeper sharedInstance];
        FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:self.currentIndex];
        [self filePreview:fileDataModel];
    }
*/
}

#pragma mark - MDAudioPlayerController Delegate

- (void)audioPlayerDidClose:(MDAudioPlayerController *)player
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
/*
    if ([self enableNextOption])
    {
        self.currentIndex = self.currentIndex + 1;
        DataKeeper *dataKeeper = [DataKeeper sharedInstance];
        FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:self.currentIndex];
        [self filePreview:fileDataModel];
    }
    else
    {
        self.currentIndex = self.currentIndex - 1;
        DataKeeper *dataKeeper = [DataKeeper sharedInstance];
        FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:self.currentIndex];
        [self filePreview:fileDataModel];
    }
*/
}

#pragma mark - AudioStreamingPlayer Delegate

- (void)audioStreamingPlayerDidClose
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
/*
    if ([self enableNextOption])
    {
        self.currentIndex = self.currentIndex + 1;
        DataKeeper *dataKeeper = [DataKeeper sharedInstance];
        FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:self.currentIndex];
        [self filePreview:fileDataModel];
    }
    else
    {
        self.currentIndex = self.currentIndex - 1;
        DataKeeper *dataKeeper = [DataKeeper sharedInstance];
        FileDataModel *fileDataModel = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:self.currentIndex];
        [self filePreview:fileDataModel];
    }
*/
}

#pragma mark - QLPreviewController DataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.currentFilePath];
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
