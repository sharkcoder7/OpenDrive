//
//  MDAudioPlayerController.m
//  OpenDrive
//
//  Created by ioshero on 2/22/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import "MDAudioPlayerController.h"
#import "MDAudioPlayerTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MDAudioPlayerController ()
{
    CGFloat statusBarOffset;
}

- (UIImage *)reflectedImage:(UIButton *)fromImage withHeight:(NSUInteger)height;
@end

@implementation MDAudioPlayerController

static const CGFloat kDefaultReflectionFraction = 0.65;

@synthesize soundFiles;
@synthesize soundFile;
@synthesize soundFilesPath;

@synthesize player;
@synthesize gradientLayer;

@synthesize playButton;
@synthesize pauseButton;
@synthesize nextButton;
@synthesize previousButton;
@synthesize toggleButton;
@synthesize repeatButton;
@synthesize shuffleButton;

@synthesize currentTime;
@synthesize duration;
@synthesize indexLabel;
@synthesize titleLabel;
@synthesize artistLabel;
@synthesize albumLabel;

@synthesize volumeSlider;
@synthesize progressSlider;

@synthesize songTableView;

@synthesize artworkView;
@synthesize reflectionView;
@synthesize containerView;
@synthesize overlayView;

@synthesize updateTimer;

@synthesize interrupted;
@synthesize repeatAll;
@synthesize repeatOne;
@synthesize shuffle;


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

void interruptionListenerCallback (void *userData, UInt32 interruptionState)
{
	MDAudioPlayerController *vc = (__bridge MDAudioPlayerController *)userData;
	if (interruptionState == kAudioSessionBeginInterruption)
		vc.interrupted = YES;
	else if (interruptionState == kAudioSessionEndInterruption)
		vc.interrupted = NO;
}

-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p
{
	NSString *current = [NSString stringWithFormat:@"%d:%02d", (int)p.currentTime / 60, (int)p.currentTime % 60, nil];
	NSString *dur = [NSString stringWithFormat:@"-%d:%02d", (int)((int)(p.duration - p.currentTime)) / 60, (int)((int)(p.duration - p.currentTime)) % 60, nil];
	duration.text = dur;
	currentTime.text = current;
	progressSlider.value = p.currentTime;
}

- (void)updateCurrentTime
{
	[self updateCurrentTimeForPlayer:self.player];
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
	titleLabel.text = [[self.soundFile title] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	artistLabel.text = [[self.soundFile artist] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	albumLabel.text = [[self.soundFile album] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[self updateCurrentTimeForPlayer:p];
	
	if (updateTimer) 
		[updateTimer invalidate];
	
	if (p.playing)
	{
		[playButton removeFromSuperview];
		[self.view addSubview:pauseButton];
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
	}
	else
	{
		[pauseButton removeFromSuperview];
		[self.view addSubview:playButton];
		updateTimer = nil;
	}
    
    UIImage *artwork = [[soundFiles objectAtIndex:selectedIndex] coverImage];
    if (!artwork) {
        artwork = self.noArtworkImage;
    }
	
	if (![songTableView superview])
	{
		[artworkView setImage:artwork forState:UIControlStateNormal];
		reflectionView.image = [self reflectedImage:artworkView withHeight:artworkView.bounds.size.height * kDefaultReflectionFraction];
	}
	
	if (repeatOne || repeatAll || shuffle)
		nextButton.enabled = YES;
	else	
		nextButton.enabled = [self canGoToNextTrack];
	previousButton.enabled = [self canGoToPreviousTrack];
    
    NSArray *keys = [NSArray arrayWithObjects:
                     MPMediaItemPropertyTitle,
                     MPMediaItemPropertyArtist,
                     MPMediaItemPropertyPlaybackDuration,
                     MPNowPlayingInfoPropertyPlaybackRate,
                     MPMediaItemPropertyArtwork,
                     nil];
    
    NSString *title = @"";
    NSString *artist = @"";
    
    if (self.titleLabel.text) title = self.titleLabel.text;
    if (self.artistLabel.text) artist = self.artistLabel.text;
    
    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:artwork];
    
    NSArray *values = @[title,
                        artist,
                        @(p.duration),
                        @1,
                        albumArt];
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
}

-(void)updateViewForPlayerInfo:(AVAudioPlayer*)p
{
	duration.text = [NSString stringWithFormat:@"%d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
	indexLabel.text = [NSString stringWithFormat:@"%d of %d", (selectedIndex + 1), [soundFiles count]];
	progressSlider.maximumValue = p.duration;
}

- (MDAudioPlayerController *)initWithSoundFiles:(NSMutableArray *)songs atPath:(NSString *)path andSelectedIndex:(int)index customNoArtworkImage:(UIImage *)noArtworkImage
{
    if (self = [super init])
	{
        [[NSNotificationCenter defaultCenter] addObserver:self
               selector:@selector(audioRouteChanged:)
                   name:AVAudioSessionRouteChangeNotification
                 object:nil];
        
        _noArtworkImage = noArtworkImage;
        
        statusBarOffset = 0;
        
		self.soundFiles = songs;
		self.soundFilesPath = path;
		selectedIndex = index;
        
		NSError *error = nil;
        
		self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
		[player setNumberOfLoops:0];
		player.delegate = self;
        
		[self updateViewForPlayerInfo:player];
		[self updateViewForPlayerState:player];
		
		if (error)
			NSLog(@"%@", error);
	}
	
	return self;
}

- (MDAudioPlayerController *)initWithSoundFiles:(MDAudioFile *)audioFile customNoArtworkImage:(UIImage *)noArtworkImage
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(audioRouteChanged:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
        
        _noArtworkImage = noArtworkImage;
        
        statusBarOffset = 0;
        
        self.soundFile = audioFile;
        selectedIndex = 0;
        
        NSError *error = nil;
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[self.soundFile filePath] error:&error];
        [player setNumberOfLoops:0];
        player.delegate = self;
        
        [self updateViewForPlayerInfo:player];
        [self updateViewForPlayerState:player];
        
        if (error)
            NSLog(@"%@", error);
    }
    
    return self;
}

- (MDAudioPlayerController *)initWithSoundFiles:(NSMutableArray *)songs atPath:(NSString *)path andSelectedIndex:(int)index
{
	return [self initWithSoundFiles:songs atPath:path andSelectedIndex:index customNoArtworkImage:nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    if (IS_OS_7_OR_LATER) statusBarOffset = 20;
	
	self.view.backgroundColor = [UIColor blackColor];
	
	if (!IS_OS_7_OR_LATER) [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    
	updateTimer = nil;
    
    UIView *statusBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, statusBarOffset)];
    statusBarBackground.backgroundColor = [UIColor colorWithRed:0.078f green:0.078f blue:0.078f alpha:1.00f];
    [self.view addSubview:statusBarBackground];
	
	UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, statusBarOffset, self.view.frame.size.width, 44)];
	navigationBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	navigationBar.barStyle = UIBarStyleBlackOpaque;
	[self.view addSubview:navigationBar];
	
	UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
	[navigationBar pushNavigationItem:navItem animated:NO];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAudioPlayer)];
	
	navItem.leftBarButtonItem = doneButton;
	
	AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, (__bridge void *)(self));
	AudioSessionSetActive(true);
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);	
	
	MDAudioFile *selectedSong = self.soundFile;
	
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 14 + statusBarOffset, 195, 12)];
    NSString *title = [[selectedSong title] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	titleLabel.text = title;
	titleLabel.font = [UIFont boldSystemFontOfSize:12];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.shadowColor = [UIColor blackColor];
	titleLabel.shadowOffset = CGSizeMake(0, -1);
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	[self.view addSubview:titleLabel];
	
	self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 2 + statusBarOffset, 195, 12)];
	artistLabel.text = [[selectedSong artist] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	artistLabel.font = [UIFont boldSystemFontOfSize:12];
	artistLabel.backgroundColor = [UIColor clearColor];
	artistLabel.textColor = [UIColor lightGrayColor];
	artistLabel.shadowColor = [UIColor blackColor];
	artistLabel.shadowOffset = CGSizeMake(0, -1);
	artistLabel.textAlignment = NSTextAlignmentCenter;
	artistLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	[self.view addSubview:artistLabel];
	
	self.albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 27 + statusBarOffset, 195, 12)];
	albumLabel.text = [[selectedSong album] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	albumLabel.backgroundColor = [UIColor clearColor];
	albumLabel.font = [UIFont boldSystemFontOfSize:12];
	albumLabel.textColor = [UIColor lightGrayColor];
	albumLabel.shadowColor = [UIColor blackColor];
	albumLabel.shadowOffset = CGSizeMake(0, -1);
	albumLabel.textAlignment = NSTextAlignmentCenter;
	albumLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	[self.view addSubview:albumLabel];

	duration.adjustsFontSizeToFitWidth = YES;
	currentTime.adjustsFontSizeToFitWidth = YES;
	progressSlider.minimumValue = 0.0;	
	
	self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44 + statusBarOffset, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
	[self.view addSubview:containerView];
	
	self.artworkView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    
    UIImage *artwork = [selectedSong coverImage];
    if (!artwork) {
        artwork = self.noArtworkImage;
    }
    
	[artworkView setImage:artwork forState:UIControlStateNormal];
    self.artworkView.imageView.contentMode = UIViewContentModeScaleAspectFill;
	[artworkView addTarget:self action:@selector(showOverlayView) forControlEvents:UIControlEventTouchUpInside];
	artworkView.showsTouchWhenHighlighted = NO;
	artworkView.adjustsImageWhenHighlighted = NO;
	artworkView.backgroundColor = [UIColor clearColor];
	[containerView addSubview:artworkView];
	
	self.reflectionView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 320, 320, 96)];
	reflectionView.image = [self reflectedImage:artworkView withHeight:artworkView.bounds.size.height * kDefaultReflectionFraction];
	reflectionView.alpha = kDefaultReflectionFraction;
	[self.containerView addSubview:reflectionView];
	
	self.songTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 368 + (FOUR_INCH_SCREEN?88:0))];
	self.songTableView.delegate = self;
	self.songTableView.dataSource = self;
	self.songTableView.separatorColor = [UIColor colorWithRed:0.986 green:0.933 blue:0.994 alpha:0.10];
	self.songTableView.backgroundColor = [UIColor clearColor];
	self.songTableView.contentInset = UIEdgeInsetsMake(0, 0, 37, 0); 
	self.songTableView.showsVerticalScrollIndicator = NO;
	
	gradientLayer = [[CAGradientLayer alloc] init];
	gradientLayer.frame = CGRectMake(0.0, self.containerView.bounds.size.height - 96, self.containerView.bounds.size.width, 48);
	gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor blackColor].CGColor, (id)[UIColor blackColor].CGColor, nil];
	gradientLayer.zPosition = INT_MAX;
	
	/*! HACKY WAY OF REMOVING EXTRA SEPERATORS */
	
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
	v.backgroundColor = [UIColor clearColor];
	[self.songTableView setTableFooterView:v];

	UIImageView *buttonBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 96, self.view.bounds.size.width, 96)];
	buttonBackground.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerBarBackground" ofType:@"png"]] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
	[self.view addSubview:buttonBackground];
		
	self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(144, self.view.bounds.size.height - 90, 40, 40)];
	[playButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPlay" ofType:@"png"]] forState:UIControlStateNormal];
	[playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
	playButton.showsTouchWhenHighlighted = YES;
	[self.view addSubview:playButton];
							  
	self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(140, self.view.bounds.size.height - 90, 40, 40)];
	[pauseButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPause" ofType:@"png"]] forState:UIControlStateNormal];
	[pauseButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
	pauseButton.showsTouchWhenHighlighted = YES;
	
	self.volumeSlider = [[MPVolumeView alloc] initWithFrame:CGRectMake(25, self.view.bounds.size.height - 40, 270, 40)];
	[self.view addSubview:volumeSlider];
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
        
	[player play];
    
    if([_delegate respondsToSelector:@selector(audioPlayer:didBeginPlaying:)]) {
        MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
        [_delegate audioPlayer:self didBeginPlaying:curr];
    }
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)dismissAudioPlayer
{
    if ([self respondsToSelector:@selector(presentingViewController)]){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    if([_delegate respondsToSelector:@selector(audioPlayerDidClose:)]) {
        [_delegate audioPlayerDidClose:self];
    }
}

- (void)showSongFiles
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
	
	[UIView setAnimationTransition:([self.songTableView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.toggleButton cache:YES];
	if ([songTableView superview])
		[self.toggleButton setImage:[UIImage imageNamed:@"AudioPlayerAlbumInfo.png"] forState:UIControlStateNormal];
	else
		[self.toggleButton setImage:self.artworkView.imageView.image forState:UIControlStateNormal];
	
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.5];
	
	[UIView setAnimationTransition:([self.songTableView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:self.containerView cache:YES];
	if ([songTableView superview])
	{
		[self.songTableView removeFromSuperview];
        
        UIImage *artwork = [[soundFiles objectAtIndex:selectedIndex] coverImage];
        if (!artwork) {
            artwork = self.noArtworkImage;
        }
        
		[self.artworkView setImage:artwork forState:UIControlStateNormal];
		[self.containerView addSubview:reflectionView];
		
		[gradientLayer removeFromSuperlayer];
	}
	else
	{
		[self.artworkView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerTableBackground_" ofType:@"png"]] forState:UIControlStateNormal];
		[self.reflectionView removeFromSuperview];
		[self.overlayView removeFromSuperview];
		[self.containerView addSubview:songTableView];
		
		[[self.containerView layer] insertSublayer:gradientLayer atIndex:0];
	}
	
	[UIView commitAnimations];
}

- (void)showOverlayView
{	
	if (overlayView == nil) 
	{		
		self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 76)];
		overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
		overlayView.opaque = NO;
		
		self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(54, 20, 212, 23)];

        if (!IS_OS_7_OR_LATER) {
            [progressSlider setThumbImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberKnob" ofType:@"png"]]
                                 forState:UIControlStateNormal];
            [progressSlider setMinimumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberLeft" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                                        forState:UIControlStateNormal];
            [progressSlider setMaximumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberRight" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]
                                        forState:UIControlStateNormal];

        }
		
        [progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
		progressSlider.maximumValue = player.duration;
		progressSlider.minimumValue = 0.0;	
		[overlayView addSubview:progressSlider];
		
		self.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 2, 64, 21)];
		indexLabel.font = [UIFont boldSystemFontOfSize:12];
		indexLabel.shadowOffset = CGSizeMake(0, -1);
		indexLabel.shadowColor = [UIColor blackColor];
		indexLabel.backgroundColor = [UIColor clearColor];
		indexLabel.textColor = [UIColor whiteColor];
		indexLabel.textAlignment = NSTextAlignmentCenter;
		[overlayView addSubview:indexLabel];
		
		self.duration = [[UILabel alloc] initWithFrame:CGRectMake(272, 21, 48, 21)];
		duration.font = [UIFont boldSystemFontOfSize:14];
		duration.shadowOffset = CGSizeMake(0, -1);
		duration.shadowColor = [UIColor blackColor];
		duration.backgroundColor = [UIColor clearColor];
		duration.textColor = [UIColor whiteColor];
		[overlayView addSubview:duration];
		
		self.currentTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 48, 21)];
		currentTime.font = [UIFont boldSystemFontOfSize:14];
		currentTime.shadowOffset = CGSizeMake(0, -1);
		currentTime.shadowColor = [UIColor blackColor];
		currentTime.backgroundColor = [UIColor clearColor];
		currentTime.textColor = [UIColor whiteColor];
		currentTime.textAlignment = NSTextAlignmentRight;
		[overlayView addSubview:currentTime];
		
		duration.adjustsFontSizeToFitWidth = YES;
		currentTime.adjustsFontSizeToFitWidth = YES;
	}
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	
	if ([overlayView superview])
		[overlayView removeFromSuperview];
	else
		[containerView addSubview:overlayView];
	
	[UIView commitAnimations];
}

- (void)toggleShuffle
{
	if (shuffle)
	{
		shuffle = NO;
		[shuffleButton setImage:[UIImage imageNamed:@"_AudioPlayerShuffleOff"] forState:UIControlStateNormal];
	}
	else
	{
		shuffle = YES;
		[shuffleButton setImage:[UIImage imageNamed:@"_AudioPlayerShuffleOn"] forState:UIControlStateNormal];
	}
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)toggleRepeat
{
	if (repeatOne)
	{
		[repeatButton setImage:[UIImage imageNamed:@"_AudioPlayerRepeatOff"]
					  forState:UIControlStateNormal];
		repeatOne = NO;
		repeatAll = NO;
	}
	else if (repeatAll)
	{
		[repeatButton setImage:[UIImage imageNamed:@"_AudioPlayerRepeatOneOn"]
					  forState:UIControlStateNormal];
		repeatOne = YES;
		repeatAll = NO;
	}
	else
	{
		[repeatButton setImage:[UIImage imageNamed:@"_AudioPlayerRepeatOn"]
					  forState:UIControlStateNormal];
		repeatOne = NO;
		repeatAll = YES;
	}
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (BOOL)canGoToNextTrack
{
	if (selectedIndex + 1 == [self.soundFiles count]) 
		return NO;
	else
		return YES;
}

- (BOOL)canGoToPreviousTrack
{
	if (selectedIndex == 0)
		return NO;
	else
		return YES;
}

-(void)play
{
	if (self.player.playing == YES) 
	{
		[self.player pause];
	}
	else
	{
		if ([self.player play]) 
		{
			if([_delegate respondsToSelector:@selector(audioPlayer:didBeginPlaying:)]) {
                MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
                [_delegate audioPlayer:self didBeginPlaying:curr];
            }
		}
		else
		{
			NSLog(@"Could not play %@\n", self.player.url);
		}
	}
	
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)previous
{
    
	NSUInteger newIndex = selectedIndex - 1;
	selectedIndex = newIndex;
		
	NSError *error = nil;
	AVAudioPlayer *newAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
	
	if (error)
		NSLog(@"%@", error);
	
	[player stop];
    if([_delegate respondsToSelector:@selector(audioPlayer:didStopPlaying:)]) {
        MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
        [_delegate audioPlayer:self didStopPlaying:curr];
    }
    
	self.player = newAudioPlayer;
	
	player.delegate = self;
	[player prepareToPlay];
	[player setNumberOfLoops:0];
	[player play];
    
    if([_delegate respondsToSelector:@selector(audioPlayer:didBeginPlaying:)]) {
        MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
        [_delegate audioPlayer:self didBeginPlaying:curr];
    }
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
    
    [self.songTableView reloadData];
}

- (void)next
{
	NSUInteger newIndex;
	
	if (shuffle)
	{
		newIndex = rand() % [soundFiles count];
	}
	else if (repeatOne)
	{
		newIndex = selectedIndex;
	}
	else if (repeatAll)
	{
		if (selectedIndex + 1 == [self.soundFiles count])
			newIndex = 0;
		else
			newIndex = selectedIndex + 1;
	}
	else
	{
		newIndex = selectedIndex + 1;
	}
	
	selectedIndex = newIndex;
		
	NSError *error = nil;
    
	AVAudioPlayer *newAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
    
		
	if (error)
		NSLog(@"%@", error);
	
	[player stop];
    if([_delegate respondsToSelector:@selector(audioPlayer:didStopPlaying:)]) {
        MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
        [_delegate audioPlayer:self didStopPlaying:curr];
    }
    
	self.player = newAudioPlayer;
	
	player.delegate = self;
	[player prepareToPlay];
	[player setNumberOfLoops:0];
	[player play];
    if([_delegate respondsToSelector:@selector(audioPlayer:didBeginPlaying:)]) {
        MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
        [_delegate audioPlayer:self didBeginPlaying:curr];
    }
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];

    [self.songTableView reloadData];
}

- (IBAction)progressSliderMoved:(UISlider *)sender
{
	player.currentTime = sender.value;
	[self updateCurrentTimeForPlayer:player];
}


#pragma mark -
#pragma mark AVAudioPlayer delegate


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
	
	if ([self canGoToNextTrack]) {
        [self dismissAudioPlayer];
    } else if (interrupted) {
		[self.player play];
        if([_delegate respondsToSelector:@selector(audioPlayer:didBeginPlaying:)]) {
            MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
            [_delegate audioPlayer:self didBeginPlaying:curr];
        }
    } else {
		[self.player stop];
    }
		 
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error);
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Decode Error" 
														message:[NSString stringWithFormat:@"Unable to decode audio file with error: %@", [error localizedDescription]] 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	// perform any interruption handling here
	printf("(apbi) Interruption Detected\n");
	[[NSUserDefaults standardUserDefaults] setFloat:[self.player currentTime] forKey:@"Interruption"];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	// resume playback at the end of the interruption
	printf("(apei) Interruption ended\n");
	[self.player play];
    
    if([_delegate respondsToSelector:@selector(audioPlayer:didBeginPlaying:)]) {
        MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
        [_delegate audioPlayer:self didBeginPlaying:curr];
    }
	
	// remove the interruption key. it won't be needed
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Interruption"];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{	
    return [soundFiles count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    MDAudioPlayerTableViewCell *cell = (MDAudioPlayerTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[MDAudioPlayerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.title = [[[soundFiles objectAtIndex:indexPath.row] title] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	cell.number = [NSString stringWithFormat:@"%d.", (indexPath.row + 1)];
	cell.duration = [[soundFiles objectAtIndex:indexPath.row] durationInMinutes];

	cell.isEven = indexPath.row % 2;
	
	if (selectedIndex == indexPath.row)
		cell.isSelectedIndex = YES;
	else
		cell.isSelectedIndex = NO;
	
	return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	selectedIndex = indexPath.row;
	
	for (MDAudioPlayerTableViewCell *cell in [aTableView visibleCells])
	{
		cell.isSelectedIndex = NO;
	}
	
	MDAudioPlayerTableViewCell *cell = (MDAudioPlayerTableViewCell *)[aTableView cellForRowAtIndexPath:indexPath];
	cell.isSelectedIndex = YES;
	
	NSError *error = nil;
	AVAudioPlayer *newAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[(MDAudioFile *)[soundFiles objectAtIndex:selectedIndex] filePath] error:&error];
	
	if (error)
		NSLog(@"%@", error);
	
	[player stop];
    if([_delegate respondsToSelector:@selector(audioPlayer:didStopPlaying:)]) {
        MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
        [_delegate audioPlayer:self didStopPlaying:curr];
    }
    
	self.player = newAudioPlayer;
	
	player.delegate = self;
	[player prepareToPlay];
	[player setNumberOfLoops:0];
	[player play];
    if([_delegate respondsToSelector:@selector(audioPlayer:didBeginPlaying:)]) {
        MDAudioFile* curr = (MDAudioFile *)[soundFiles objectAtIndex:selectedIndex];
        [_delegate audioPlayer:self didBeginPlaying:curr];
    }
	
	[self updateViewForPlayerInfo:player];
	[self updateViewForPlayerState:player];
}

- (BOOL)tableView:(UITableView *)table canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return NO;
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}


#pragma mark - Image Reflection

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);

	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
	
    return bitmapContext;
}

- (UIImage *)reflectedImage:(UIButton *)fromImage withHeight:(NSUInteger)height
{
    if (height == 0)
		return nil;
    
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
	
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.bounds.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);

	CGContextTranslateCTM(mainViewContentContext, 0.0, height);
	CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
	
	CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.imageView.image.CGImage);
	
	CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	CGImageRelease(reflectionImage);
	
	return theImage;
}

- (void)viewDidUnload
{
	self.reflectionView = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImage *)noArtworkImage
{
    if (_noArtworkImage) {
        return _noArtworkImage;
    }
    else {
        return self.noArtworkDefaultImage;
    }
}

- (UIImage *)noArtworkDefaultImage
{
    if (_noArtworkDefaultImage) {
        return _noArtworkDefaultImage;
    }
    else {
        _noArtworkDefaultImage = [UIImage imageNamed:@"AudioPlayerNoArtwork"];
        return _noArtworkDefaultImage;
    }
}

- (void)audioRouteChanged:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    AVAudioSessionRouteDescription *previousRoute = [interuptionDict valueForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    if ([[previousRoute.outputs valueForKeyPath:@"portType"] containsObject:AVAudioSessionPortHeadphones] && self.player.isPlaying) {
        [self play];
    }
    
//    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
//    switch (routeChangeReason) {
//        case AVAudioSessionRouteChangeReasonUnknown:
//            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonUnknown");
//            break;
//            
//        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
//            // a headset was added or removed
//            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
//            break;
//            
//        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
//            // a headset was added or removed
//            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
//            break;
//            
//        case AVAudioSessionRouteChangeReasonCategoryChange:
//            // called at start - also when other audio wants to play
//            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");//AVAudioSessionRouteChangeReasonCategoryChange
//            break;
//            
//        case AVAudioSessionRouteChangeReasonOverride:
//            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOverride");
//            break;
//            
//        case AVAudioSessionRouteChangeReasonWakeFromSleep:
//            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonWakeFromSleep");
//            break;
//            
//        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
//            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
//            break;
//            
//        default:
//            break;
//    }
}

@end
