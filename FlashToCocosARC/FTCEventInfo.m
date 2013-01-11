//
//  FTCEventInfo.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCEventInfo.h"

@implementation FTCEventInfo

@synthesize eventType;
@synthesize frameIndex;

-(void)dealloc
{
    [eventType dealloc];
    [super dealloc];
}

@end