//
//  SymTabCreator.h
//  SymTabCreator
//
//  Created by Karsten Kusche on 17.06.10.
//  Copyright 2010 Briksoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDCommandLineInterface.h"

@interface SymTabCreator : NSObject  <DDCliApplicationDelegate> {
	NSString* source;
	NSString* output;
	BOOL verbose;
	NSString* arch;
}

@end
