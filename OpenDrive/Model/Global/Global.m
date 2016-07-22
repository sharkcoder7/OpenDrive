//
//  Global.m
//  OpenDrive
//
//  Created by Bin Jin on 3/30/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "Global.h"

@implementation Global

+ (FileType)getFileType:(NSString *)extension
{
    if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
        return JPEG;
    else if ([extension isEqualToString:@"png"])
        return PNG;
    else if ([extension isEqualToString:@"tiff"])
        return TIFF;
    else if ([extension isEqualToString:@"gif"])
        return GIF;
    
    else if ([extension isEqualToString:@"mov"])
        return MOV;
    else if ([extension isEqualToString:@"avi"])
        return AVI;
    else if ([extension isEqualToString:@"mp4"])
        return MP4;
    
    else if ([extension isEqualToString:@"mp3"])
        return MP3;
    else if ([extension isEqualToString:@"wav"])
        return WAV;
    else if ([extension isEqualToString:@"wma"])
        return WMA;
    else if ([extension isEqualToString:@"aiff"])
        return AIFF;
    else if ([extension isEqualToString:@"M4A"])
        return M4A;
    
    else if ([extension isEqualToString:@"doc"])
        return DOC;
    else if ([extension isEqualToString:@"docx"])
        return DOCX;
    
    else if ([extension isEqualToString:@"xml"])
        return XML;
    else if ([extension isEqualToString:@"xls"])
        return XLS;
    else if ([extension isEqualToString:@"xlsx"])
        return XLSX;
    
    else if ([extension isEqualToString:@"pdf"])
        return PDF;
    
    else if ([extension isEqualToString:@"ppt"])
        return PPT;
   else if ([extension isEqualToString:@"pptx"])
        return PPTX;
    
    else if ([extension isEqualToString:@"txt"])
        return TXT;
    else if ([extension isEqualToString:@"rtf"])
        return RTF;
    
    else if ([extension isEqualToString:@"htm"])
        return HTM;
    else if ([extension isEqualToString:@"html"])
        return HTML;
    else if ([extension isEqualToString:@"dcm"])
        return NONE;
    
    return NONE;
}

@end
