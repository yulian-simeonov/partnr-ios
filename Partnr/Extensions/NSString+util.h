//
//  NSString+util.h
//  Wyldfire
//
//  Created by Aleksey on 3/14/14.
//  Copyright (c) 2014 Wyldfire, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (util)

-(NSString *)stringValue;
-(NSString*)filteredDigitsOfPhoneNumber;
-(NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar;
- (NSString *)convertFormatedPhoneNumberToSimpleNumber;

@end
