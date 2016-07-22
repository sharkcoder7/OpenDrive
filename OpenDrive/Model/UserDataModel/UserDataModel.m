//
//  UserDataModel.m
//  OpenDrive
//
//  Created by Bin Jin on 1/19/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "UserDataModel.h"

@implementation UserDataModel

- (id)init
{
    self = [super init];
    if (self)
    {
        self.nAccType = 0;
        self.driveName = nil;
        self.version = 1.0;
        self.isAccountUser = NO;
        self.isPartner = YES;
        self.partnerUsersDomain = nil;
        self.sessionID = nil;
        self.userDomain = nil;
        self.userFirstName = nil;
        self.userID = nil;
        self.userLanguage = ENGLISH;
        self.userLastName = nil;
        self.userLevel = 0;
        self.userName = nil;
    }
    
    return self;
}

- (void)initUserDataModel:(NSDictionary*)dic
{
    self.nAccType = [[dic objectForKey:User_AccType] integerValue];
    self.driveName = [dic objectForKey:User_DriveName];
    self.version = [[dic objectForKey:User_FVersioning] floatValue];
    self.isAccountUser = [[dic objectForKey:User_IsAccountUser] boolValue];
    self.isPartner = [[dic objectForKey:User_IsPartner] boolValue];
    self.partnerUsersDomain = [dic objectForKey:User_PartnerUserDomain];
    self.sessionID = [dic objectForKey:User_SessionID];
    self.userDomain = [dic objectForKey:User_UserDomain];
    self.userFirstName = [dic objectForKey:User_UserFirstName];
    self.userID = [dic objectForKey:User_ID];
    self.userLanguage = (UserLanguage)[[dic objectForKey:User_Language] integerValue];
    self.userLastName = [dic objectForKey:User_UserLastName];
    self.userLevel = [[dic objectForKey:User_UserLevel] integerValue];
    self.userName = [dic objectForKey:User_UserName];
}

@end
