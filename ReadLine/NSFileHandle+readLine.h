//
//  NSFileHandle+readLine.h
//
//  Created by Ethan Horger on 11/27/12.
//  Copyright (c) 2012 Ethan Horger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileHandle (readLine)

- (NSData *)readLineWithDelimiter:(NSString *)theDelimier;

@end
