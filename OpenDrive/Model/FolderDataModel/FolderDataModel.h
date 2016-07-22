//
//  FolderDataModel.h
//  OpenDrive
//
//  Created by Bin Jin on 1/21/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileDataModel.h"

#define Folder_Access                       @"Access"
#define Folder_DateCreated                  @"DateCreated"
#define Folder_DateModified                 @"DateModified"
#define Folder_Encrypted                    @"Encrypted"
#define Folder_FolderID                     @"FolderID"
#define Folder_Link                         @"Link"
#define Folder_Name                         @"Name"
#define Folder_Shared                       @"Shared"
#define Folder_Files                        @"Files"

#define Folder_DirUpdateTime                @"DirUpdateTime"
#define Folder_DirectFolderLink             @"DirectFolderLink"
#define Folder_SubFolders                   @"Folders"
#define Folder_ParentFolderID               @"ParentFolderID"
#define Folder_ResponseType                 @"ResponseType"

@interface FolderDataModel : NSObject

@property (assign, nonatomic) NSInteger         accessLevel;
@property (strong, nonatomic) NSString          *folderID;
@property (strong, nonatomic) NSString          *folderName;
@property (assign, nonatomic) NSInteger         dateCreated;
@property (assign, nonatomic) NSInteger         dateModified;
@property (assign, nonatomic) BOOL              encrypted;
@property (strong, nonatomic) NSString          *link;
@property (assign, nonatomic) BOOL              shared;

@property (strong, nonatomic) NSString          *parentFolderID;
@property (strong, nonatomic) NSString          *directFolderLink;
@property (assign, nonatomic) NSInteger         lastRequestTime;
@property (assign, nonatomic) BOOL              responseType;
@property (strong, nonatomic) NSMutableArray    *subFolders;

@property (strong, nonatomic) NSMutableArray    *arrayFiles;

- (void)initFolderDatModel:(NSDictionary *)dic;
- (BOOL)isRootFolder;
- (void)reset;

@end
