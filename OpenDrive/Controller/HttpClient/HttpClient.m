//
//  HttpClient.m
//  OpenDrive
//
//  Created by ioshero on 12/28/15.
//  Copyright © 2015 ioshero. All rights reserved.
//

#import "HttpClient.h"
#import "AFNetworking.h"
#import "config.h"

@implementation HttpClient

+ (instancetype)sharedClient
{
    static HttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[HttpClient alloc] init];
    });
    
    return _sharedClient;
}

- (void)post:(NSString*)postUrl
        withParam:(NSDictionary*)paramDic
        withSuccessBlock:(void (^)(NSDictionary *responseDic))successBlock
        withFailureBlock:(void (^)(NSError *error))failureBlock
{
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:[responseSerializer acceptableContentTypes]];
    [contentTypes addObject:@"application/json; charset=utf-8"];
    responseSerializer.acceptableContentTypes = [NSSet setWithSet:contentTypes];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:responseSerializer];

    NSString *requestURL = [NSString stringWithFormat:@"%@%@", ServerURL, postUrl];
    NSLog(@"RequestURL - %@", requestURL);
    
    NSError* error;
    if (paramDic)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramDic options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", json);
    }
    
    [manager POST:requestURL parameters:paramDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary*)responseObject;
        NSLog(@"%@", response);
        successBlock(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed : %@", error);
        failureBlock(error);
    }];
}

- (void)get:(NSString*)getUrl
        withParam:(NSDictionary*)paramDic
        withSuccessBlock:(void (^)(NSDictionary *responseDic))successBlock
        withFailureBlock:(void (^)(NSError *error))failureBlock
{
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    NSMutableSet *contentTypes = [NSMutableSet setWithSet:[responseSerializer acceptableContentTypes]];
    [contentTypes addObject:@"application/json; charset=utf-8"];
    responseSerializer.acceptableContentTypes = [NSSet setWithSet:contentTypes];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:responseSerializer];

    NSString *requestURL = [NSString stringWithFormat:@"%@%@", ServerURL, getUrl];
    NSLog(@"RequestURL - %@", requestURL);
    
    if (paramDic != nil)
    {
        NSError* error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramDic options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", json);
    }
    
    [manager GET:requestURL parameters:paramDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary*)responseObject;
        NSLog(@"%@", response);
        successBlock(response);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed : %@", error);
        failureBlock(error);
    }];
}

#define Folder_ListFolderContent_SearchQuery            @"search_query"
#define Folder_ListFolderContent_LastRequestTime        @"last_request_time"
#define Folder_ListFolderContent_SharingId              @"sharing_id"
#define Folder_ListFolderContent_EncryptionSupported    @"encryption_supported"

- (NSDictionary *)getListFolderContentParams:(NSString *)search_query RequestTime:(NSInteger)last_request_time SharingId:(NSString *)sharing_id EncryptionSupported:(BOOL)encryption_supported;
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (search_query != nil && [search_query isEqualToString:@""])
        [param setValue:search_query forKey:Folder_ListFolderContent_SearchQuery];
    
    if (last_request_time != 0)
        [param setValue:[NSNumber numberWithInteger:last_request_time] forKey:Folder_ListFolderContent_LastRequestTime];
    
    if (sharing_id != nil && [sharing_id isEqualToString:@""])
        [param setValue:sharing_id forKey:Folder_ListFolderContent_SharingId];
    
    if (encryption_supported == YES)
        [param setValue:[NSNumber numberWithBool:encryption_supported] forKey:Folder_ListFolderContent_EncryptionSupported];
    
    
    return param;
}

#define Create_User_UserName                    @"username"
#define Create_User_Email                       @"email"
#define Create_User_Password                    @"passwd"
#define Create_User_FirstName                   @"first_name"
#define Create_User_LastName                    @"last_name"
#define Create_User_VerifyPassword              @"verify_passwd"
#define Create_User_CreatedById                 @"created_by_id"

- (NSDictionary *)getCreateUserParams:(NSString *)username Email:(NSString *)email Password:(NSString *)password FirstName:(NSString *)firstName LastName:(NSString *)lastName CreatedById:(NSString*)createdById
{
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:username, Create_User_UserName, email, Create_User_Email, password, Create_User_Password, firstName, Create_User_FirstName, lastName, Create_User_LastName, password, Create_User_VerifyPassword, createdById, Create_User_CreatedById, nil];
    
    return param;
}

#define Session_Login_UserName                  @"username"
#define Session_Login_Password                  @"passwd"

- (NSDictionary *)getSessionLoginParams:(NSString *)username Password:(NSString *)password
{
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:username, Session_Login_UserName, password, Session_Login_Password, nil];
    
    return param;
}

#define Session_Id                              @"session_id"

- (NSDictionary *)getExistSessionParams:(NSString *)sessionId
{
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:sessionId, Session_Id, nil];
    
    return param;
}

#define BrandingInfo_UserId                     @"user_id"
#define BrandingInfo_SessionId                  @"session_id"

- (NSDictionary *)getUserBrandingInfo:(NSString *)userId Session:(NSString *)sessionId
{
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:userId, BrandingInfo_UserId, sessionId, BrandingInfo_SessionId, nil];
    
    return param;
}

#define File_Rename_SessionId                    @"session_id"
#define File_Rename_NewFileName                  @"new_file_name"
#define File_Rename_FileId                       @"file_id"

- (NSDictionary *)getFileRenameParams:(NSString *)sessionId NewFileName:(NSString *)fileName FileId:(NSString *)fileId
{
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:sessionId, File_Rename_SessionId, fileName, File_Rename_NewFileName, fileId, File_Rename_FileId,nil];
    return param;
}

@end
