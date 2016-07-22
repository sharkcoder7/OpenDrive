//
//  config.h
//  OpenDrive
//
//  Created by Bin Jin on 12/28/15.
//  Copyright © 2015 Bin Jin. All rights reserved.
//

#ifndef config_h
#define config_h

#define AppVersion                                  @"2.4.3"

#define UserDefault_SessionID_Key                   @"SessionID"
#define UserDefault_UserID_Key                      @"UserID"

#define ServerURL                                   @"https://dev.opendrive.com/api"

////////////////////////////////////// API //////////////////////////////////////////////
// Session
#define Post_LoginURL                               @"/v1/session/login.json"
#define Post_SessionExistURL                         @"/v1/session/exists.json"
#define Post_SessionLogOutURL                       @"/v1/session/logout.json"

// Users
#define Post_SignURL                                @"/v1/users.json"

// Folder
#define Get_ListFolderContentURL                    @"/v1/folder/list.json"

// AccountUser
#define Get_AccountUser_ListFolderContentURL        @"/v1/accountusers/folderslist.json"

// Branding
#define Get_UserBrandingInfoURL                     @"/v1/branding.json"

// File
#define Post_FileRenameURL                          @"/v1/file/rename.json"
//////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////// Request Type ////////////////////////////////////////
// Users Request Type
#define Request_Login                               @"Login"

// Session Request Type
#define Request_Signup                              @"Signup"
#define Request_SessionExist                        @"SessionExist"

// AccountUser Request Type
#define Request_ListFolderContent                   @"ListFolderContent"

// File Request Type
#define Request_FileRename                          @"FileRename"
//////////////////////////////////////////////////////////////////////////////////////////

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define OpenDrive_Color                             [UIColor colorWithRed:33.0f/255.0f green:42.0f/255.0f blue:55.0f/255.0f alpha:1.0f]
#define SideBar_Color                               [UIColor colorWithRed:56.0f/255.0f green:64.0f/255.0f blue:75.0f/255.0f alpha:1.0f]
#define Folder_Text_Color                           [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]
#define SizeDate_Text_Color                         [UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f]
#define OpenDrive_TightGrayColor                    [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]
#define OpenDrive_Preview_BackgroundColor           [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]

#define Default_TableViewCell_Height                50

typedef enum
{
    ENGLISH = 0,
    RUSSIAN,
    
} UserLanguage;

#endif /* config_h */
