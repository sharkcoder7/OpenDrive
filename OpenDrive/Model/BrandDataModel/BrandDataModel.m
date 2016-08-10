//
//  BrandDataModel.m
//  OpenDrive
//
//  Created by ioshero on 1/30/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import "BrandDataModel.h"
#import "config.h"

@implementation BrandDataModel

- (id)init
{
    self = [super init];
    if (self)
    {
        self.userId = nil;
        self.hostMapping = nil;
        self.driveName = nil;
        self.menuColor = OpenDrive_Color;
        self.fontColor = [UIColor whiteColor];
        self.loginPageHTML = nil;
        self.favIconData = nil;
        self.subDomain = nil;
        self.partnerDomain = nil;
        self.logoURL = nil;
    }
    
    return self;
}

- (void)initBrandInfo:(NSDictionary *)dic
{
    self.userId = [dic objectForKey:Brand_UserId];
    self.hostMapping = [dic objectForKey:Brand_HostMapping];
    self.driveName = [dic objectForKey:Brand_DriveName];
    self.menuColor = [self getColorFromHexString:[dic objectForKey:Brand_MenuColor]];
    self.fontColor = [self getColorFromHexString:[dic objectForKey:Brand_FontColor]];
    self.loginPageHTML = [dic objectForKey:Brand_LoginPageHTML];
    self.favIconData = [NSData dataWithData:[dic objectForKey:Brand_FavIcon]];
    self.subDomain = [dic objectForKey:Brand_SubDomain];
    self.partnerDomain = [dic objectForKey:Brand_PartnerDomain];
    NSString *logoPath = [dic objectForKey:Brand_Logo];
    if (logoPath != (NSString*)[NSNull null])
        self.logoURL = [NSURL URLWithString:logoPath];
}

- (UIColor *)getColorFromHexString:(NSString*)strHex
{
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:strHex];
    [scanner scanHexInt:&result];
    int r, g, b;
    b = (int)(result & 0xFF);
    g = (int)((result >> 8) & 0xFF);
    r = (int)((result >> 16) & 0xFF);
    
    UIColor *color = [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
    return color;
}

@end
