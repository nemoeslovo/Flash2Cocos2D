//
//  FTCAnimationsParserDelegate.h
//  F2CExamle
//
//  Created by Danila Kolesnikov on 6/29/13.
//  Copyright (c) 2013 dandandan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTCAnimationsSet.h"

@interface FTCAnimationsParserDelegate : NSObject <NSXMLParserDelegate>

@property (strong) FTCAnimationsSet *animationsSet;

@end
