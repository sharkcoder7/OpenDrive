//
//  FileDataModel.m
//  OpenDrive
//
//  Created by Bin Jin on 1/24/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "FileDataModel.h"

@implementation FileDataModel

- (id)init
{
    self = [super init];
    if (self)
    {
        self.fileID = nil;
        self.fileName = nil;
        self.groupID = nil;
        self.extension = nil;
        self.fileSize = 0;
        self.views = 0;
        self.version = 0;
        self.downloads = 0;
        self.dateModified = 0;
        self.accessLevel = 0;
        self.link = nil;
        self.downloadLink = nil;
        self.streamingLink = nil;
        self.thumbLink = nil;
        self.password = nil;
        self.editOnline = NO;
    }
    
    return self;
}

- (void)initFileDataMode:(NSDictionary *)dic
{
    self.fileID = [dic objectForKey:File_Id];
    self.fileName = [dic objectForKey:File_Name];
    self.groupID = [dic objectForKey:File_GroupId];
    self.extension = [dic objectForKey:File_Extension];
    self.fileSize = [[dic objectForKey:File_Size] integerValue];
    self.views = [[dic objectForKey:File_Views] integerValue];
    self.version = [[dic objectForKey:File_Views] integerValue];
    self.downloads = [[dic objectForKey:File_Downloads] integerValue];
    self.dateModified = [[dic objectForKey:File_DateModified] integerValue];
    self.accessLevel = [[dic objectForKey:File_Access] integerValue];
    self.link = [dic objectForKey:File_Link];
    self.downloadLink = [dic objectForKey:File_DownloadLink];
    self.streamingLink = [dic objectForKey:File_StreamingLink];
    self.thumbLink = [dic objectForKey:File_ThumbLink];
    self.password = [dic objectForKey:File_Password];
    self.editOnline = [[dic objectForKey:File_EditOnline] boolValue];
}

@end
