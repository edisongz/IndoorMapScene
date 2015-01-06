//
//  MifFileReader.m
//  WisdomMallAPP
//
//  Created by apple on 13-12-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "MifFileReader.h"
#import "MifHeader.h"

#import "PrimitivePoints.h"
#import "FacilityPoints.h"
#import "NSFileHandle+readLine.h"

@implementation MifFileReader

- (BOOL)openFile:(NSString *)filePath
{
    BOOL result = NO;
    if (!filePath) {
        NSLog(@"file not found");
        return result;
    }
    is = [[NSInputStream alloc] initWithFileAtPath:filePath];
    [is setDelegate:self];
    [is scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [is open];
    if(![is hasBytesAvailable])
    {
        result = NO;
        
    }else
    {
        result = YES;
    }
    return result;
}

- (BOOL)readMifFileHeader:(NSString *)filePath
{
    BOOL result = NO;
    
    MifHeader *mifHeader = [[MifHeader alloc] init];
    if ([self openFile:filePath]) {
        //version
        NSString *strVersion = [self readLine];
        if (strVersion != nil) {
            strVersion = [strVersion stringByReplacingOccurrencesOfString:@"Version" withString:@""];
            strVersion = [strVersion stringByReplacingOccurrencesOfString:@" " withString:@""];
            mifHeader.version = strVersion;
            strVersion = nil;
        }
        
        //charSet
        NSString *strCharset = [self readLine];
        if (strCharset != nil) {
            strCharset = [strCharset stringByReplacingOccurrencesOfString:@"Charset" withString:@""];
            strCharset = [strCharset stringByReplacingOccurrencesOfString:@" " withString:@""];
            mifHeader.charSet = strCharset;
            strCharset = nil;
        }
        
        //Delimiter
        NSString *strDelimiter = [self readLine];
        if (strDelimiter != nil) {
            strDelimiter = [strDelimiter stringByReplacingOccurrencesOfString:@"Delimiter" withString:@""];
            strDelimiter = [strDelimiter stringByReplacingOccurrencesOfString:@" " withString:@""];
            mifHeader.delemiter = strDelimiter;
            strDelimiter = nil;
        }
        
        //Coor and bounds
        NSString *strCoord = [self readLine];
        if (strCoord != nil) {
            strCoord = [strCoord stringByReplacingOccurrencesOfString:@"CoordSys" withString:@""];
            if ([strCoord rangeOfString:@"Bounds"].location != NSNotFound) {
                NSArray *array = [strCoord componentsSeparatedByString:@"Bounds"];
                mifHeader.coordSys = array[0];
                
                NSArray *array1 = [array[1] componentsSeparatedByString:@")"];
                NSString *str1 = [array1[0] stringByReplacingOccurrencesOfString:@"(" withString:@""];
                NSString *str2 = [array1[1] stringByReplacingOccurrencesOfString:@"(" withString:@""];
                
                NSArray *temp1 = [str1 componentsSeparatedByString:@","];
                NSArray *temp2 = [str2 componentsSeparatedByString:@","];
                CGRect frame;
                frame.origin.x = [temp1[0] floatValue];
                frame.origin.y = [temp1[1] floatValue];
                frame.size.width = [temp2[0] floatValue];
                frame.size.height = [temp2[1] floatValue];
                mifHeader.frame = frame;
            }
            strCoord = nil;
        }

    }
    return result;
}

- (NSString *)readLine
{
    uint8_t buf[1];
    NSMutableString *result = [[NSMutableString alloc] init];
    do
    {
        int numBytesRead = [is read:buf maxLength:1];
        if (numBytesRead > 0) {
            NSString *str = [[NSString alloc] initWithBytes:buf length:1 encoding:NSUTF8StringEncoding];
            if (str != nil) {
                [result appendString:str];
            }else{
                [result appendString:@""];
            }

            charRead = buf[0];
            str = nil;
        }else {
            return nil;
        }
        
    } while(charRead != '\n');
    return result;
}

//解析矢量数据内容
- (NSMutableArray *)readMifFileData
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *strRead;
    do {
        strRead = [self readLine];
    } while ([strRead rangeOfString:@"DATA"].location == NSNotFound);
    
    do {
        strRead = [self readLine];
        PrimitivePoints *points = [[PrimitivePoints alloc] init];
        //矩形
        if ([strRead rangeOfString:@"Rect"].location != NSNotFound) {
            
            if (strRead == nil) {
                continue;
            }
            NSArray *array = [strRead componentsSeparatedByString:@" "];
            points.type = array[0];
            CGPoint start = CGPointMake([array[1] floatValue], [array[2] floatValue]);
            CGPoint end = CGPointMake([array[3] floatValue], [array[4] floatValue]);
            points.startPoint = start;
            points.endPoint = end;
            
            [result addObject:points];
        }
        //区域
        else if ([strRead rangeOfString:@"Region"].location != NSNotFound) {
            strRead = [self readLine];
            strRead = [strRead stringByReplacingOccurrencesOfString:@" " withString:@""];
            int count = [strRead intValue];
            points.type = @"Region";
            for (int i = 0; i < count; i++) {
                MPoint *mPoint = [[MPoint alloc] init];
                strRead = [self readLine];
                
                NSArray *array = [strRead componentsSeparatedByString:@" "];
                mPoint.x = [array[0] floatValue];
                mPoint.y = [array[1] floatValue];
                
                [points.pointArray addObject:mPoint];
            }
            NSLog(@"add Region");
            [result addObject:points];
        }
        //PLINE
        else if ([strRead rangeOfString:@"PLINE"].location != NSNotFound)
        {
            NSString *str1 = [strRead stringByReplacingOccurrencesOfString:@"PLINE" withString:@""];
            NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
            points.type = @"PLINE";
            int count = [str2 intValue];
            for (int i = 0; i < count; i++) {
                MPoint *mPoint = [[MPoint alloc] init];
                strRead = [self readLine];
                
                NSArray *array = [strRead componentsSeparatedByString:@" "];
                mPoint.x = [array[0] floatValue];
                mPoint.y = [array[1] floatValue];
                
                [points.pointArray addObject:mPoint];
            }
            [result addObject:points];
        }
    } while (strRead != nil);
    
    
    return result;
}

/*
 *  新版读取mif 文件方式
 */
- (NSMutableArray *)readMifDataNewVersion:(NSString *)path
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    NSData *lineData;
    
    while ((lineData = [fileHandle readLineWithDelimiter:@"\n"]))
    {
        NSString *lineString = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
        
        if ([lineString rangeOfString:@"PLINE"].location != NSNotFound)
        {
            PrimitivePoints *points = [[PrimitivePoints alloc] init];
            points.type = @"PLINE";
            
            BOOL isFinished = NO;
            while (!isFinished) {
                
                BOOL isPoint = YES;
                MPoint *mPoint = [[MPoint alloc] init];
                
                NSData *tempData = [fileHandle readLineWithDelimiter:@"\n"];
                NSString *tempStr = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
                
                if ([tempStr rangeOfString:@"Prop"].location != NSNotFound) {
                    
                    tempStr = [tempStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSArray *propArray = [tempStr componentsSeparatedByString:@" "];
                    if (propArray.count >= 5)//车位
                    {
                        points.property.floorNo = [propArray objectAtIndex:1];
                        points.property.parkingNo = [propArray objectAtIndex:2];
                        points.property.propertyName = [propArray objectAtIndex:3];
                        points.property.propertyNo = [propArray objectAtIndex:4];
                    }
                    points.hasProperty = YES;
                    isPoint = NO;
                    isFinished = YES;
                }
                
                if ([tempStr rangeOfString:@"Pen"].location != NSNotFound) {
                    isPoint = NO;
                    isFinished = YES;
                }
                
                NSArray *array = [tempStr componentsSeparatedByString:@" "];
                
                //不满足条件不添加
                if (array.count > 1 && isPoint) {
                    mPoint.x = [array[0] floatValue];
                    mPoint.y = [array[1] floatValue];
                    
                    [points.pointArray addObject:mPoint];
                }
                
            }

            [result addObject:points];
            points = nil;
            
        }
        else if ([lineString rangeOfString:@"LINE"].location != NSNotFound)
        {
//            NSLog(@"line str ==== %@", lineString);
        }
        else if ([lineString rangeOfString:@"Mark"].location != NSNotFound)
        {
            NSArray *array = [lineString componentsSeparatedByString:@" "];
            
            FacilityPoints *facility = [[FacilityPoints alloc] init];
            
            if (array.count < 5) {
                continue;
            }
            facility.fMark = array[0];
            facility.fIndex = [array[1] intValue];
            facility.fName = array[2];
            facility.point = CGPointMake([array[3] floatValue], [array[4] floatValue]);
            if (array.count == 6) {
                facility.isParking = YES;
            }else{
                facility.isParking = NO;
            }
            [result addObject:facility];
            facility = nil;
        }
    }
    
    return result;
}

/*
 *  读取设施数据
 */
- (NSMutableArray *)readFacilityFileByPath:(NSString *)path
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    // Use readLineWithDelimiter to fill our NSTableView with each line found
    
    NSData *lineData;
    
    int i = 0;
    while ((lineData = [fileHandle readLineWithDelimiter:@"\n"]))
    {
        NSString *lineString = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
        
        if (i == 0) {
            i++;
            continue;
        }
        
        NSArray *array = [lineString componentsSeparatedByString:@" "];
        
        FacilityPoints *facility = [[FacilityPoints alloc] init];
        
        if (array.count < 5) {
            continue;
        }
        facility.fMark = array[0];
        facility.fIndex = [array[1] intValue];
        facility.fName = array[2];
        facility.point = CGPointMake([array[3] floatValue], [array[4] floatValue]);
        if (array.count == 6) {
            facility.isParking = YES;
        }else{
            facility.isParking = NO;
        }
        [result addObject:facility];
        facility = nil;
    }
    
    return result;
}

- (void)closeInputStream
{
    if (is != nil) {
        [is close];
        is = nil;
    }
}

@end
