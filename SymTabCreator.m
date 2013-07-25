//
//  SymTabCreator.m
//  SymTabCreator
//
//  Created by Karsten Kusche on 17.06.10.
//  Copyright 2010 Briksoftware.com. All rights reserved.
//

#import "SymTabCreator.h"
#import "Symbol.h"

@implementation SymTabCreator

NSString *readLineAsNSString(FILE *file)
{ // parses a FILE line wise and returns the next line
	
	// copied from stack overflow
	
	
    char buffer[4096];
	
    // tune this capacity to your liking -- larger buffer sizes will be faster, but
    // use more memory
    NSMutableString *result = [NSMutableString stringWithCapacity:256];
	
    // Read up to 4095 non-newline characters, then read and discard the newline
    int charsRead;
    do
    {
        if(fscanf(file, "%4095[^\n]%n%*c", buffer, &charsRead) == 1)
            [result appendFormat:@"%s", buffer];
        else
            break;
    } while(charsRead == 4095);
	
    return result;
}

- (NSArray*)symbolsFromFile:(NSString*)path
{// opens a file, parses its lines and returns an array of Symbol objects
	
	NSMutableArray* symbols = [NSMutableArray array];
	
	FILE *file = fopen([path UTF8String], "r");
	// check for NULL
	while(!feof(file))
	{
		NSString *line = readLineAsNSString(file);

		Symbol* sym = [Symbol fromLine: line];
		if (sym)
		{
			[symbols addObject: sym];
		}
	}
	fclose(file);
	
	return symbols;
}

- (void)writeSymbols:(NSArray*)symbols toFile:(NSString*)outPath
{ // writes assemble commands to outPath that define the stubs that are defined by the symbols
  // at the end an align is written so that the section's size is a multiple of 0x1000
	
	FILE* file = fopen([outPath UTF8String], "w");
	NSInteger offset = 0x0;
	for (Symbol* sym in symbols)
	{
		offset = [sym writeToFile: file fromOffset: offset];
	}
	fprintf(file,".p2align 12\n");
	fclose(file);
}

- (void)convertFrom: (NSString*)sourceFile to: (NSString*)outFile
{ // main function. reads input file, writes an assemble file, assembles it and links it to the final product
	
	NSArray* symbols = [self symbolsFromFile: sourceFile];
	NSArray* sortedSymbols = [symbols sortedArrayUsingSelector:@selector(compareWithSymbol:)];
	
	NSString* tempAssemblyFile = @"/tmp/symtab.s";
	[self writeSymbols: sortedSymbols toFile: tempAssemblyFile];
	NSString *arch = @"x86_64";
	const char* command;
	command = [[NSString stringWithFormat:@"as -arch %@ %@ -o %@",arch,tempAssemblyFile,outFile] UTF8String];
	if (verbose)
		printf("%s\n",command);
	if (!system(command))
	{	
		NSInteger segAddr = [[sortedSymbols objectAtIndex: 0] offset];
		if (segAddr > 0x1000)
		{	
			if (verbose)
				printf("segAddr = %p\n",(void*)segAddr);
			
			segAddr &= ~0x0fff; // make sure the address has the form of 0x12340000
			if (verbose)
				printf("segAddr after & = %p\n",(void*)segAddr);
			
			segAddr -= 0x1000; // subtract 0x1000 so that the linker starts the TEXT segment 0x1000 before the __text section starts. This makes sure the __text section starts where we need it.
			if (verbose)
				printf("segAddr after subtract= %p\n",(void*)segAddr);		
			command = [[NSString stringWithFormat:@"ld_classic -seg1addr %p -o %@ %@",(void*)(segAddr),outFile,outFile] UTF8String];
		}
		else
			command = [[NSString stringWithFormat:@"ld_classic -o %@ %@",outFile,outFile] UTF8String];
		
		if (verbose)
			printf("%s\n",command);
		system(command);
		remove([tempAssemblyFile UTF8String]);
	}
}

//##################### standard stuff below

- (void)printUsage:(FILE *)stream;
{
    ddfprintf(stream, @"%@: Usage [-v | --verbose] [-s sourceFile] [-o outname]\n", DDCliApp);
    ddfprintf(stream, @"default outname is a.out. default source file is stdin\n", DDCliApp);
}

- (void)application:(DDCliApplication *)app
   willParseOptions:(DDGetoptLongParser *)optionsParser;
{
	source = nil;
	output = nil;
    DDGetoptOption optionTable[] = 
    {
		// Long         Short   Argument options
		{@"source",        's',    DDGetoptRequiredArgument},
		{@"output",        'o',    DDGetoptRequiredArgument},
		{@"verbose",       'v',    DDGetoptNoArgument},
		{nil,           0,      0}
    };
    [optionsParser addOptionsFromTable:optionTable];
}

- (int)application:(DDCliApplication *)app
  runWithArguments:(NSArray *)arguments;
{
	NSString* sourceFile = @"/dev/stdin";
	NSString* outFile = @"a.out";
	if (source) {
		sourceFile = source;
	}
	if (output)
	{
		outFile = output;
	}
	[self convertFrom: sourceFile to: outFile];
    return EXIT_SUCCESS;
}

@end
