//
//  HttpClient.h
//  OpenDrive
//
//  Created by ioshero on 12/28/15.
//  Copyright © 2015 ioshero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpClient : NSObject

+ (instancetype)sharedClient;

- (void)post:(NSString*)postUrl
        withParam:(NSDictionary*)paramDic
        withSuccessBlock:(void (^)(NSDictionary *responseDic))successBlock
        withFailureBlock:(void (^)(NSError *error))failureBlock;

- (void)get:(NSString*)getUrl
        withParam:(NSDictionary*)paramDic
        withSuccessBlock:(void (^)(NSDictionary *responseDic))successBlock
        withFailureBlock:(void (^)(NSError *error))failureBlock;

- (NSDictionary *)getListFolderContentParams:(NSString *)search_query RequestTime:(NSInteger)last_request_time SharingId:(NSString *)sharing_id EncryptionSupported:(BOOL)encryption_supported;

- (NSDictionary *)getCreateUserParams:(NSString *)username Email:(NSString *)email Password:(NSString *)password FirstName:(NSString *)firstName LastName:(NSString *)lastName CreatedById:(NSString*)createdById;

- (NSDictionary *)getSessionLoginParams:(NSString *)username Password:(NSString *)password;
- (NSDictionary *)getExistSessionParams:(NSString *)sessionId;

- (NSDictionary *)getUserBrandingInfo:(NSString *)userId Session:(NSString *)sessionId;
- (NSDictionary *)getFileRenameParams:(NSString *)sessionId NewFileName:(NSString *)fileName FileId:(NSString *)fileId;

@end
