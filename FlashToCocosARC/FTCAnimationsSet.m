//
//  AnimationsSet.m
//  adventurepark
//
//  Created by Danila Kolesnikov on 1/10/13.
//
//

#import "FTCAnimationsSet.h"

@implementation FTCAnimationsSet

@synthesize framerate;
@synthesize animations;

-(void)dealloc
{
    [animations dealloc];
    [super dealloc];
}

@end
