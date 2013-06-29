//
//  FTCParser.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCParser.h"
#import "FTCFrameInfo.h"
#import "FTCAnimEvent.h"
#import "FTCEventInfo.h"
#import "FTCObjectInfo.h"
#import "FTCAnimationsSet.h"
#import "FTCAnimationInfo.h"
#import "FTCPartInfo.h"
#import "FTCSheetsParserDelegate.h"
#import "FTCAnimationsParserDelegate.h"


@implementation FTCParser

+ (NSArray *)parseSheetXML:(NSString *)_xmlfile {
    
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[self dataOfFile:_xmlfile
                                                                  withSuffix:@"sheets"]];
    FTCSheetsParserDelegate *delegate = [[FTCSheetsParserDelegate alloc] init];
    [parser setDelegate:delegate];
    [parser parse];
    return [delegate arrayOfObjects];
}

+ (FTCAnimationsSet *)parseAnimationXML:(NSString *)_xmlfile {
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[self dataOfFile:_xmlfile
                                                                  withSuffix:@"animations"]];
    FTCAnimationsParserDelegate *delegate = [[FTCAnimationsParserDelegate alloc] init];
    [parser setDelegate:delegate];
    [parser parse];
    return [delegate animationsSet];
}

+ (NSData *)dataOfFile:(NSString *)name
            withSuffix:(NSString *)suffix {
    NSString *_xmlWithSuffix  = [NSString stringWithFormat:@"%@_%@", name, suffix];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_xmlWithSuffix ofType:@"xml"];
    return [NSData dataWithContentsOfFile:filePath];
}

+ (CGFloat)iPadFactor {
    CGFloat iPadFactor = 1;
    if (UIUserInterfaceIdiomPad == UIDevice.currentDevice.userInterfaceIdiom) {
        iPadFactor = 2;
    }
    return iPadFactor;
}

/**
* if images bigger then needed use this method for scale down transformation matrix
*/
+ (void)scaleSheet:(NSArray *)_objects withAnimationSet:(FTCAnimationsSet *)_animationsSet byScale:(CGFloat)scale {
    for (FTCObjectInfo *objectInfo in _objects) {
        [objectInfo setRegistrationPointX:scale * [objectInfo registrationPointX]];
        [objectInfo setRegistrationPointY:scale * [objectInfo registrationPointY]];
    }

    for (FTCAnimationInfo *animationInfo in [_animationsSet animations]) {
        for (FTCPartInfo *partInfo in [animationInfo parts]) {
            for (FTCFrameInfo *frameInfo in [partInfo framesInfo]) {
                [frameInfo setTx:scale * [frameInfo tx]];
                [frameInfo setTy:scale * [frameInfo ty]];
            }
        }
    }
}

@end
