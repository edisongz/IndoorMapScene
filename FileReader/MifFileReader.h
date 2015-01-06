//
//  MifFileReader.h
//  WisdomMallAPP
//
//  Created by apple on 13-12-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MifFileReader : NSObject <NSStreamDelegate>
{
    NSInputStream *is;
    char charRead;
}

- (BOOL)openFile:(NSString *)filePath;
- (BOOL)readMifFileHeader:(NSString *)filePath;

- (NSMutableArray *)readMifFileData;
- (NSMutableArray *)readMifDataNewVersion:(NSString *)path;
- (NSMutableArray *)readFacilityFileByPath:(NSString *)path;

- (void)closeInputStream;

@end
