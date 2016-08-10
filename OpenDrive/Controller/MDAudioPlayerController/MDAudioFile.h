//
//  MDAudioFile.h
//  OpenDrive
//
//  Created by ioshero on 2/23/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface MDAudioFile : NSObject 
{
	NSURL			*filePath;
	NSDictionary	*fileInfoDict;
    UIImage *coverImage;
}

@property (nonatomic, retain) NSURL *filePath;
@property (nonatomic, retain) NSDictionary *fileInfoDict;

- (MDAudioFile *)initWithPath:(NSURL *)path;
- (NSDictionary *)songID3Tags;
- (NSString *)title;
- (NSString *)artist;
- (NSString *)album;
- (float)duration;
- (NSString *)durationInMinutes;
- (UIImage *)coverImage;

@end
