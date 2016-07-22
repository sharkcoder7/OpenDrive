//
//  AudioStreamingPlayerVC.h
//  OpenDrive
//
//  Created by Bin Jin on 3/29/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@protocol AudioStreamingPlayerDelegate <NSObject>

@optional
- (void)audioStreamingPlayerDidClose;

@end

@interface AudioStreamingPlayerVC : UIViewController
{
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
	NSString *currentImageName;
}

@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSString *titleFileName;
@property (nonatomic, assign) id <AudioStreamingPlayerDelegate> delegate;

- (void)updateProgress:(NSTimer *)aNotification;

@end

