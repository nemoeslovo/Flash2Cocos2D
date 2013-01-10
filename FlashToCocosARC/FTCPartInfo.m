//
//  FTCPartInfo.m
//  adventurepark
//
//  Created by Danila Kolesnikov on 1/10/13.
//
//

#import "FTCPartInfo.h"

@implementation FTCPartInfo

@synthesize name;
@synthesize framesInfo;

-(void)dealloc
{
    [name dealloc];
    [framesInfo dealloc];
    
    [super dealloc];
}

@end
