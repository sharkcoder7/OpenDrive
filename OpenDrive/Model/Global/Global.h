//
//  Global.h
//  OpenDrive
//
//  Created by Bin Jin on 3/30/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    NONE = 0,
    JPEG,
    PNG,
    BMP,
    TIFF,
    GIF,
    
    MOV,
    MP4,
    AVI,
    
    MP3,
    WAV,
    WMA,
    AIFF,
    M4A,
    
    DOC,
    DOCX,
    
    PPT,
    PPTX,
    
    XLS,
    XLSX,
    XML,
    
    PDF,
    
    TXT,
    RTF,
    
    HTM,
    HTML
} FileType;

@interface Global : NSObject

+ (FileType)getFileType:(NSString *)extension;

@end
