//
//  FTCAnimationInfo.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCAnimationInfo.h"

@implementation FTCAnimationInfo

@synthesize name;
@synthesize parts;

-(void)dealloc
{
    [name dealloc];
    [parts dealloc];
    
    [super dealloc];
}

@end