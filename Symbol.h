//
//  Symbol.h
//  SymTabCreator
//
//  Created by Karsten Kusche on 17.06.10.
//  Copyright 2010 Briksoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Symbol : NSObject {
	NSInteger offset;
	NSString* symbolName;
}

- (NSInteger) offset;
- (void) setOffset: (NSInteger) newValue;


+ (id)fromLine:(NSString*) string;
- (NSInteger)writeToFile: (FILE*)file fromOffset:(NSInteger)startOffset;

- (NSString *) symbolName;
- (void) setSymbolName: (NSString *) newValue;
@end
