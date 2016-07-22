//
//  AudioStreamingPlayerVC.m
//  OpenDrive
//
//  Created by Bin Jin on 3/29/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "AudioStreamingPlayerVC.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@interface AudioStreamingPlayerVC ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navTitleBar;
@property (weak, nonatomic) IBOutlet UIButton *buttonPlay;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingProgressView;

- (IBAction)playAction:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)doneAction:(id)sender;

@end

@implementation AudioStreamingPlayerVC

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//

- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
			removeObserver:self
			name:ASStatusChangedNotification
			object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer:(NSURL*)url
{
	if (streamer)
        return;

	[self destroyStreamer];
	
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
		[NSTimer
			scheduledTimerWithTimeInterval:0.1
			target:self
			selector:@selector(updateProgress:)
			userInfo:nil
			repeats:YES];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(playbackStateChanged:)
		name:ASStatusChangedNotification
		object:streamer];
    
    [streamer start];
}

//
// viewDidLoad
//
// Creates the volume slider, sets the default path for the local file and
// creates the streamer immediately if we already have a file at the local
// location.
//
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self.progressSlider setEnabled:NO];
    
    [self createStreamer:self.audioURL];
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
    if (!streamer)
        return;
    
    if ([streamer isWaiting])
    {
        [self.loadingProgressView startAnimating];
    }
    else if ([streamer isPlaying])
	{
        [self.buttonPlay setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
        [self.buttonPlay setImage:[UIImage imageNamed:@"AudioPlayerPlay.png"] forState:UIControlStateNormal];
	}
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
		double duration = streamer.duration;
		
		if (duration > 0)
		{
            [self.loadingProgressView stopAnimating];
            [self.labelTitle setText:self.titleFileName];
            [self.progressSlider setEnabled:YES];
			[self.progressSlider setValue:100 * progress / duration];
            [self.buttonPlay setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
		}
		else
		{
			[self.progressSlider setEnabled:NO];
		}
	}
}

- (IBAction)playAction:(id)sender
{
    if (streamer.isPlaying)
    {
        [self.buttonPlay setImage:[UIImage imageNamed:@"AudioPlayerPause.png"] forState:UIControlStateNormal];
        [streamer stop];
    }
    else
    {
        [self.buttonPlay setImage:[UIImage imageNamed:@"AudioPlayerPlay.png"] forState:UIControlStateNormal];
        [streamer start];
    }
}

- (IBAction)sliderChanged:(id)sender
{
    if (streamer.duration)
    {
        double newSeekTime = (self.progressSlider.value / 100.0) * streamer.duration;
        [streamer seekToTime:newSeekTime];
    }
}

- (IBAction)doneAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(audioStreamingPlayerDidClose)])
        [self.delegate audioStreamingPlayerDidClose];
    
    [self destroyStreamer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//
// dealloc
//
// Releases instance memory.
//

- (void)dealloc
{
	[self destroyStreamer];
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
}

@end
