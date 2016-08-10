//
//  DataKeeper.m
//  OpenDrive
//
//  Created by ioshero on 1/19/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import "DataKeeper.h"

@implementation DataKeeper

+ (DataKeeper*)sharedInstance
{
    static DataKeeper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataKeeper alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.userDataModel = [[UserDataModel alloc] init];
        self.currentFolderDataModel = [[FolderDataModel alloc] init];
        self.currentFileDataModel = [[FileDataModel alloc] init];
        self.currentBrandDataModel = [[BrandDataModel alloc] init];
        self.pathDepth = -1;
        self.arrayPaths = [NSMutableArray array];
        self.lastRequestTime = 0;
    }
    
    return self;
}

@end
