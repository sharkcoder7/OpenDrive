//
//  UserDataModel.h
//  OpenDrive
//
//  Created by ioshero on 1/19/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "config.h"

#define User_AccType                    @"AccType"
#define User_DriveName                  @"DriveName"
#define User_FVersioning                @"FVersioning"
#define User_IsAccountUser              @"IsAccountUser"
#define User_IsPartner                  @"IsPartner"
#define User_PartnerUserDomain          @"PartnerUserDomain"
#define User_SessionID                  @"SessionID"
#define User_UserDomain                 @"UserDomain"
#define User_UserFirstName              @"UserFirstName"
#define User_ID                         @"UserID"
#define User_Language                   @"UserLang"
#define User_UserLastName               @"UserLastname"
#define User_UserLevel                  @"UserLevel"
#define User_UserName                   @"UserName"

@interface UserDataModel : NSObject

@property (assign, nonatomic) NSInteger     nAccType;
@property (strong, nonatomic) NSString      *driveName;
@property (assign, nonatomic) float         version;
@property (assign, nonatomic) BOOL          isAccountUser;
@property (assign, nonatomic) BOOL          isPartner;
@property (strong, nonatomic) NSString      *partnerUsersDomain;
@property (strong, nonatomic) NSString      *sessionID;
@property (strong, nonatomic) NSString      *userDomain;
@property (strong, nonatomic) NSString      *userFirstName;
@property (strong, nonatomic) NSString      *userID;
@property (assign, nonatomic) UserLanguage  userLanguage;
@property (strong, nonatomic) NSString      *userLastName;
@property (assign, nonatomic) NSInteger     userLevel;
@property (strong, nonatomic) NSString      *userName;

- (void)initUserDataModel:(NSDictionary*)dic;

@end
