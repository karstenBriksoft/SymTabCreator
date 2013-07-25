//
//  Symbol.h
//  SymTabCreator
//
//  Created by Karsten Kusche on 17.06.10.
//  Copyright 2010 Briksoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Symbol : NSObject

@property (assign) uint64_t offset;
@property (copy) NSString *symbolName;
@property (assign) NSUInteger pointerSize; // in bytes

+ (id)fromLine:(NSString*) string;
- (NSInteger)writeToFile: (FILE*)file fromOffset:(NSInteger)startOffset;

@end
