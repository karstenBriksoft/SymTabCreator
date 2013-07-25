//
//  Symbol.m
//  SymTabCreator
//
//  Created by Karsten Kusche on 17.06.10.
//  Copyright 2010 Briksoftware.com. All rights reserved.
//

#import "Symbol.h"


@implementation Symbol

- (NSComparisonResult)compareWithSymbol:(Symbol*)otherSymbol
{
	return [self offset] - [otherSymbol offset];
}

+ (id)fromLine:(NSString*) string
{
	if (string == nil || [string length] == 0) return nil;
	
	NSScanner *scanner = [NSScanner scannerWithString:string];
	uint64_t scannedOffset = 0;
	NSString *scannedSymbolName = nil;
	NSUInteger pointerSize = 0;
	BOOL symbolNameOK = NO;
	if ([scanner scanHexLongLong:&scannedOffset])
	{
		pointerSize = [scanner scanLocation] > 10 ? 8 : 4;
		uint64_t imageBase = pointerSize == 8 ? 0x100000000 : 0x1000;
		scannedOffset -= imageBase;
		[scanner scanString:@" " intoString:NULL];
		symbolNameOK = [scanner scanUpToString:@"" intoString:&scannedSymbolName];
	}
	
	if (!symbolNameOK)
	{
		fprintf(stderr,"error parsing line: %s\n",[string UTF8String]);
		return nil;
	}
	
	Symbol *new = [[[self alloc] init] autorelease];
	new.symbolName = scannedSymbolName;
	new.offset = scannedOffset;
	new.pointerSize = pointerSize;
	return new;
}

- (NSInteger)writeToFile: (FILE*)file fromOffset:(NSInteger)startOffset
{
	BOOL isMethodSymbol = ([self.symbolName hasPrefix:@"+["] || [self.symbolName hasPrefix:@"-["]);
	const char *name = [self.symbolName UTF8String];
	const char *nameWithUnderscore = isMethodSymbol ? name : [[@"_" stringByAppendingString:self.symbolName] UTF8String];
	
	fprintf(file,".space %s,0x90\n",[[[NSNumber numberWithInteger:(self.offset - startOffset)] stringValue] UTF8String]);
	fprintf(file,".globl \"%s\" \n \"%s\": \n .stabs \"%s:F(0,1)\",36,0,0,\"%s\" \n", nameWithUnderscore, nameWithUnderscore, name, nameWithUnderscore);
	
	return self.offset;
}

@end
