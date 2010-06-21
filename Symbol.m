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

NSInteger valOfHex(char c)
{// converts a hex digit to an int
	if(c >= '0' && c <= '9') {
		return c - '0';
	} else if(c >= 'A' && c <= 'F') {
		return 0xA + (c - 'A');
	}
	
	return 0;
}

NSInteger dehex(NSString *value)
{
	// returns the integer value of a hex-string.
	NSMutableString* fixedValue = [NSMutableString string];

	// this needs to be a bit more error prone
	// should check for 0x...
	// should check that numbers are even sized
	[fixedValue appendString:value];
	
	const char *mstr = [[fixedValue uppercaseString] UTF8String];
	
	char *s = (char*) mstr;
	NSInteger resNumber = 0;
	unsigned char* resBuff = (unsigned char*)&resNumber;
	unsigned char val;
	int maxSize = sizeof(NSInteger);
	int i = 0;
	// iterate over the source and convert two characters into a byte and store it into resBuff
	while (i< maxSize && *s != '\0') 
	{
		i++;
		val = valOfHex(*s) << 4;
		val += valOfHex(*(s+1));
		s+=2;
		*resBuff = val;
		resBuff++;
	}
	NSInteger res;
	if (maxSize > 8)
		res = CFSwapInt64BigToHost((long long)resNumber);
	else
		res = CFSwapInt32BigToHost((long)resNumber);
	return res;
}

- (NSInteger) offset {
  return offset;
}

- (void) setOffset: (NSInteger) newValue {
  offset = newValue;
}

+ (id)fromLine:(NSString*) string
{
	if (string == nil || [string length] == 0) return nil;
	
	NSArray* lineObjects = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([lineObjects count] != 2)
	{
		fprintf(stderr,"error parsing line: %s",[string UTF8String]);
		return nil;
	}
	id new = [[self alloc] init];
	[new autorelease];
	// should check that layout is [offset, name] and not [name, offset]...
	[new setSymbolName: [lineObjects objectAtIndex:1]];
	[new setOffset: dehex([lineObjects objectAtIndex:0])];
	return new;
}

- (NSString *) symbolName {
  return symbolName;
}

- (void) setSymbolName: (NSString *) newValue {
  [symbolName autorelease];
  symbolName = [newValue retain];
}


- (NSInteger)writeToFile: (FILE*)file fromOffset:(NSInteger)startOffset
{
	if (startOffset)
	{// already started, so just skip the gab between the previous symbol and the current symbol
		fprintf(file,".space %s,0x90\n",[[[NSNumber numberWithInteger:(offset - startOffset)] stringValue] UTF8String]);
	}
	else
	{// we start the file, first create a dummy space.
	 // the dummy space is required because we start -0x1000 before the desired offset and now need to fill the gap between 0x0000 and the first offset.
		int initialSpace = offset & 0x0fff;
		if (initialSpace)
			// only print if the initialSpace is > 0. Otherwise the assembler will fail
			fprintf(file,".space %s,0x90\n",[[[NSNumber numberWithInteger:initialSpace] stringValue] UTF8String]);
	}
	const char* name = [symbolName UTF8String];
	fprintf(file,".globl _%s \n _%s: \n .stabs \"%s:F(0,1)\",36,0,0,_%s \n",name, name,name,name);
	return offset;
}

@end
