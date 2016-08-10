//
//  DataKeeper.h
//  OpenDrive
//
//  Created by ioshero on 1/19/16.
//  Copyright © 2016 ioshero. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataModel.h"
#import "FolderDataModel.h"
#import "FileDataModel.h"
#import "BrandDataModel.h"

@interface DataKeeper : NSObject

@property (strong, nonatomic) UserDataModel         *userDataModel;
@property (strong, nonatomic) FolderDataModel       *currentFolderDataModel;
@property (strong, nonatomic) FileDataModel         *currentFileDataModel;
@property (strong, nonatomic) BrandDataModel        *currentBrandDataModel;
@property (assign, nonatomic) NSInteger             pathDepth;
@property (strong, nonatomic) NSMutableArray        *arrayPaths;
@property (assign, nonatomic) NSInteger             lastRequestTime;

+ (id)sharedInstance;

@end
