//
//  FileDataModel.h
//  OpenDrive
//
//  Created by Bin Jin on 1/24/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define File_Id                 @"FileId"
#define File_Name               @"Name"
#define File_GroupId            @"GroupID"
#define File_Extension          @"Extension"
#define File_Size               @"Size"
#define File_Views              @"Views"
#define File_Verson             @"Version"
#define File_Downloads          @"Downloads"
#define File_DateModified       @"DateModified"
#define File_Access             @"Access"
#define File_Link               @"Link"
#define File_DownloadLink       @"DownloadLink"
#define File_StreamingLink      @"StreamingLink"
#define File_ThumbLink          @"ThumbLink"
#define File_Password           @"Password"
#define File_EditOnline         @"EditOnline"

@interface FileDataModel : NSObject

@property (strong, nonatomic) NSString          *fileID;
@property (strong, nonatomic) NSString          *fileName;
@property (strong, nonatomic) NSString          *groupID;
@property (strong, nonatomic) NSString          *extension;
@property (assign, nonatomic) NSInteger         fileSize;
@property (assign, nonatomic) NSInteger         views;
@property (assign, nonatomic) NSInteger         version;
@property (assign, nonatomic) NSInteger         downloads;
@property (assign, nonatomic) NSInteger         dateModified;
@property (assign, nonatomic) NSInteger         accessLevel;
@property (strong, nonatomic) NSString          *link;
@property (strong, nonatomic) NSString          *downloadLink;
@property (strong, nonatomic) NSString          *streamingLink;
@property (strong, nonatomic) NSString          *thumbLink;
@property (strong, nonatomic) NSString          *password;
@property (assign, nonatomic) BOOL              editOnline;

- (void)initFileDataMode:(NSDictionary *)dic;

@end
