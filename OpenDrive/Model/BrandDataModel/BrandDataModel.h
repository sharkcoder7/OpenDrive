//
//  BrandDataModel.h
//  OpenDrive
//
//  Created by ioshero on 1/30/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define Brand_UserId            @"UserID"
#define Brand_HostMapping       @"HostMapping"
#define Brand_DriveName         @"DriveName"
#define Brand_MenuColor         @"MenuColor"
#define Brand_FontColor         @"FontColor"
#define Brand_LoginPageHTML     @"LoginPageHtml"
#define Brand_FavIcon           @"FavIcon"
#define Brand_SubDomain         @"Subdomain"
#define Brand_PartnerDomain     @"PartnerDomain"
#define Brand_Logo              @"Logo"

@interface BrandDataModel : NSObject

@property (strong, nonatomic) NSString  *userId;
@property (strong, nonatomic) NSString  *hostMapping;
@property (strong, nonatomic) NSString  *driveName;
@property (strong, nonatomic) UIColor   *menuColor;
@property (strong, nonatomic) UIColor   *fontColor;
@property (strong, nonatomic) NSString  *loginPageHTML;
@property (strong, nonatomic) NSData    *favIconData;
@property (strong, nonatomic) NSString  *subDomain;
@property (strong, nonatomic) NSString  *partnerDomain;
@property (strong, nonatomic) NSURL     *logoURL;

- (void)initBrandInfo:(NSDictionary *)dic;

@end
