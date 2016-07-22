//
//  FolderDataModel.m
//  OpenDrive
//
//  Created by Bin Jin on 1/21/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "FolderDataModel.h"

@implementation FolderDataModel

- (id)init
{
    self = [super init];
    if (self)
    {
        self.accessLevel = 0;
        self.folderID = nil;
        self.folderName = nil;
        self.dateCreated = 0;
        self.dateModified = 0;
        self.encrypted = NO;
        self.link = nil;
        self.shared = NO;
        
        self.parentFolderID = nil;
        self.responseType = YES;
        self.lastRequestTime = 0;
        self.directFolderLink = nil;
        self.subFolders = [NSMutableArray array];
        
        self.arrayFiles = [NSMutableArray array];
    }
    
    return self;
}

- (void)reset
{
    self.accessLevel = 0;
    self.folderID = nil;
    self.folderName = nil;
    self.dateCreated = 0;
    self.dateModified = 0;
    self.encrypted = NO;
    self.link = nil;
    self.shared = NO;
    
    self.parentFolderID = nil;
    self.responseType = YES;
    self.lastRequestTime = 0;
    self.directFolderLink = nil;
}

- (void)initFolderDatModel:(NSDictionary *)dic
{
    self.lastRequestTime = [[dic objectForKey:Folder_DirUpdateTime] integerValue];
    self.directFolderLink = [dic objectForKey:Folder_DirectFolderLink];
    self.folderName = [dic objectForKey:Folder_Name];
    self.parentFolderID = [dic objectForKey:Folder_ParentFolderID];
    self.responseType = [[dic objectForKey:Folder_ResponseType] boolValue];
    self.accessLevel = [[dic objectForKey:Folder_Access] integerValue];
    self.dateCreated = [[dic objectForKey:Folder_DateCreated] integerValue];
    self.dateModified = [[dic objectForKey:Folder_DateModified] integerValue];
    self.encrypted = [[dic objectForKey:Folder_Encrypted] boolValue];
    if (self.folderID == nil)
        self.folderID = [dic objectForKey:Folder_FolderID];
    self.link = [dic objectForKey:Folder_Link];
    self.folderName = [dic objectForKey:Folder_Name];
    self.shared = [[dic objectForKey:Folder_Shared] boolValue];
    
    NSMutableArray *arrarySubFolders = [NSMutableArray arrayWithArray:[dic objectForKey:Folder_SubFolders]];
    for (NSInteger i = 0 ; i < arrarySubFolders.count ; i ++)
    {
        NSDictionary *subDic = [arrarySubFolders objectAtIndex:i];
        FolderDataModel *folder = [[FolderDataModel alloc] init];
        [folder initFolderDatModel:subDic];
        [self.subFolders addObject:folder];
    }
    
    NSMutableArray *arrayFiles = [NSMutableArray arrayWithArray:[dic objectForKey:Folder_Files]];
    for (NSInteger i = 0 ; i < arrayFiles.count ; i ++) {
        NSDictionary *subDic = [arrayFiles objectAtIndex:i];
        FileDataModel *file = [[FileDataModel alloc] init];
        [file initFileDataMode:subDic];
        [self.arrayFiles addObject:file];
    }
}

- (BOOL)isRootFolder
{
    if (self.folderID == nil || (self.folderName && [ self.folderName isEqualToString:@""]))
        return YES;
    
    return NO;
}

@end
