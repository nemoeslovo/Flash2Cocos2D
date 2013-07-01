//
//  FTCAnimationsParserDelegate.m
//  F2CExamle
//
//  Created by Danila Kolesnikov on 6/29/13.
//  Copyright (c) 2013 dandandan. All rights reserved.
//

#import "FTCAnimationsParserDelegate.h"
#import "FTCAnimationInfo.h"
#import "FTCFrameInfo.h"
#import "FTCPartInfo.h"

#define TAG_ANIMATIONS @"Animations"
#define TAG_ANIMATION  @"Animation"
#define TAG_PART       @"Part"
#define TAG_FRAME      @"Frame"

#define ATTR_FRAME_COUNT @"frameCount"
#define ATTR_FRAME_RATE  @"frameRate"
#define ATTR_NAME        @"name"

#define ATTR_RIGHT_MARGIN @"rightMargined"
#define ATTR_LEFT_MARGIN  @"leftMargined"
#define ATTR_TOP_MARGIN   @"topMargined"
#define ATTR_BOTT_MARGIN  @"bottomMargined"


#define ATTR_A         @"a"
#define ATTR_B         @"b"
#define ATTR_C         @"c"
#define ATTR_D         @"d"
#define ATTR_TX        @"tx"
#define ATTR_TY        @"ty"
#define ATTR_ALPHA     @"alpha"
#define ATTR_INDEX     @"index"

@implementation FTCAnimationsParserDelegate {
    FTCAnimationInfo *_currentAnimationInfo;
    FTCFrameInfo     *_currentFrameInfo;
    FTCPartInfo      *_currentPartInfo;
}

@synthesize animationsSet = _animationsSet;

#pragma _parser delegate

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString *errorString = [NSString stringWithFormat:@"Error code %i", [parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    
    
    //frame
    if ([elementName isEqualToString:TAG_FRAME]) {
        _currentFrameInfo = [[FTCFrameInfo alloc] init];
        
        [_currentFrameInfo setA:[[attributeDict objectForKey:ATTR_A] floatValue]];
        [_currentFrameInfo setB:[[attributeDict objectForKey:ATTR_B] floatValue]];
        [_currentFrameInfo setC:[[attributeDict objectForKey:ATTR_C] floatValue]];
        [_currentFrameInfo setD:[[attributeDict objectForKey:ATTR_D] floatValue]];
        
        [_currentFrameInfo setTx:[[attributeDict objectForKey:ATTR_TX] floatValue]];
        [_currentFrameInfo setTy:[[attributeDict objectForKey:ATTR_TY] floatValue]];
        
        
        [_currentFrameInfo setAlpha:[[attributeDict objectForKey:ATTR_ALPHA] floatValue]];
        [_currentFrameInfo setIndex:[[attributeDict objectForKey:ATTR_INDEX] integerValue]];

        [_currentFrameInfo setTopMargined:[[attributeDict objectForKey:ATTR_TOP_MARGIN] boolValue]];
        [_currentFrameInfo setLeftMargined:[[attributeDict objectForKey:ATTR_LEFT_MARGIN] boolValue]];
        [_currentFrameInfo setRightMargined:[[attributeDict objectForKey:ATTR_RIGHT_MARGIN] boolValue]];
        [_currentFrameInfo setBottomMargined:[[attributeDict objectForKey:ATTR_BOTT_MARGIN] boolValue]];
        
        return;
    }
    
    //part
    if ([elementName isEqualToString:TAG_PART]) {
        _currentPartInfo = [[FTCPartInfo alloc] init];
        [_currentPartInfo setName:[attributeDict objectForKey:ATTR_NAME]];
        return;
    }
    
    //animations
    if ([elementName isEqualToString:TAG_ANIMATION]) {
        _currentAnimationInfo = [[FTCAnimationInfo alloc] init];
        [_currentAnimationInfo setName:[attributeDict objectForKey:ATTR_NAME]];
        [_currentAnimationInfo setFrameCount:[[attributeDict objectForKey:ATTR_FRAME_COUNT] integerValue]];
        return;
    }
    
    if ([elementName isEqualToString:TAG_ANIMATIONS]) {
        _animationsSet = [[FTCAnimationsSet alloc] init];
        [[self animationsSet] setFrameRate:[attributeDict objectForKey:ATTR_FRAME_RATE]];
        return;
    }

}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    //frame
    if ( [elementName isEqualToString:TAG_FRAME]) {
        [[_currentPartInfo framesInfo] addObject:_currentFrameInfo];
        return;
    }
    
    //part
    if ( [elementName isEqualToString:TAG_PART]) {
        [[_currentAnimationInfo parts] addObject:_currentPartInfo];
        return;
    }
    
    //animation
    if ( [elementName isEqualToString:TAG_ANIMATION]) {
        [[[self animationsSet] animations] addObject:_currentAnimationInfo];
        return;
    }
    
}


@end
