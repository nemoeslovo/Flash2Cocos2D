//
//  FTCParser.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCParser.h"
#import "FTCCharacter.h"
#import "FTCSprite.h"
#import "FTCFrameInfo.h"
#import "FTCAnimEvent.h"
#import "FTCEventInfo.h"
#import "FTCObjectInfo.h"
#import "FTCAnimationsSet.h"
#import "FTCAnimationInfo.h"
#import "FTCPartInfo.h"

@interface FTCParser()
    +(TBXMLElement*)  getRootElementFromXML:(NSString *)_xmlFile;
    +(FTCFrameInfo *) getFrameInfoFromElement:(TBXMLElement *)_frameInfo;
@end


@implementation FTCParser

+(NSArray *)parseSheetXML:(NSString *)_xmlfile
{
    TBXMLElement *_root  = [self getRootElementFromXML:[NSString stringWithFormat:@"%@_sheets.xml", _xmlfile]];
 
    TBXMLElement   *_texturesheet = [TBXML childElementNamed:@"TextureSheet" parentElement:_root];
    NSMutableArray *objectsList   = [NSMutableArray array];
    
    TBXMLIterateBlock block = ^(TBXMLElement *_texture) {
        FTCObjectInfo *objectInfo = [[FTCObjectInfo alloc] init];

        [objectInfo setName:[TBXML valueOfAttributeNamed:@"name"
                                              forElement:_texture]];
        [objectInfo setPath:[TBXML  valueOfAttributeNamed:@"path"
                                               forElement:_texture]];
        [objectInfo setRegistrationPointX:[[TBXML valueOfAttributeNamed:@"registrationPointX"
                                                             forElement:_texture] floatValue]];
        //don't know why minus
        [objectInfo setRegistrationPointY:-([[TBXML valueOfAttributeNamed:@"registrationPointY"
                                                               forElement:_texture] floatValue])];
        [objectInfo setZIndex:[[TBXML valueOfAttributeNamed:@"zIndex"
                                                 forElement:_texture] intValue]];
        
        [objectsList addObject:objectInfo];
    };
    [TBXML iterateElementsForQuery:@"Texture" fromElement:_texturesheet withBlock:block];
    
    return objectsList;
}

+(FTCAnimationsSet *) parseAnimationXML:(NSString *)_xmlfile
{
    TBXMLElement *_root    = [self getRootElementFromXML: [NSString stringWithFormat:@"%@_animations.xml", _xmlfile]];
    float        frameRate = [[TBXML valueOfAttributeNamed:@"frameRate" forElement:_root] floatValue];
    
    // set the character animation (it will be filled with events)
    NSMutableArray *animations = [NSMutableArray array];
    TBXMLIterateBlock block = ^(TBXMLElement *_animation)
    {
        [animations addObject:[self getAnimationInfoFromElement:_animation]];
    };
    [TBXML iterateElementsForQuery:@"Animation" fromElement:_root withBlock:block];
    
    FTCAnimationsSet *animationsSet = [[FTCAnimationsSet alloc] init];
    
    [animationsSet setFramerate:frameRate];
    [animationsSet setAnimations:animations];
   
    return animationsSet;
}

+(FTCAnimationInfo *) getAnimationInfoFromElement:(TBXMLElement *)_animation {
    NSString *animName  = [TBXML valueOfAttributeNamed:@"name" forElement:_animation];
    int      frameCount = [[TBXML valueOfAttributeNamed:@"frameCount" forElement:_animation] integerValue];
    
    if ([animName isEqualToString:@""]) {
        animName = @"_init";
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    TBXMLIterateBlock partBlock = ^(TBXMLElement *_part)
    {
        [parts addObject:[self getPartInfoFromElement:_part]];
    };
    [TBXML iterateElementsForQuery:@"Part" fromElement:_animation withBlock:partBlock];
    
    [self processEventsFromElement:_animation];
    
    FTCAnimationInfo *animationInfo = [[FTCAnimationInfo alloc] init];
    [animationInfo setName:animName];
    [animationInfo setParts:parts];
    [animationInfo setFrameCount:frameCount];
    
    return animationInfo;
}

+(FTCPartInfo *) getPartInfoFromElement:(TBXMLElement *)_part
{
    NSString       *partName     = [TBXML valueOfAttributeNamed:@"name" forElement:_part];
    NSMutableArray *__partFrames = [NSMutableArray array];
    
    TBXMLIterateBlock frameBlock = ^(TBXMLElement *_frameInfo)
    {
        [__partFrames addObject:[self getFrameInfoFromElement:_frameInfo]];
    };
    [TBXML iterateElementsForQuery:@"Frame" fromElement:_part withBlock:frameBlock];
     
    FTCPartInfo *partInfo = [[FTCPartInfo alloc] init];
    [partInfo setName:partName];
    [partInfo setFramesInfo:__partFrames];
    
    return partInfo;
}

+(void) processEventsFromElement:(TBXMLElement *)_animation
{
    // Process Events if needed
    int _animationLength = [[TBXML valueOfAttributeNamed:@"frameCount" forElement:_animation] intValue];
    
    NSMutableArray  *__eventsArr = [[NSMutableArray alloc] initWithCapacity:_animationLength];
    for (int ea=0; ea<_animationLength; ea++) { [__eventsArr addObject:[NSNull null]];};
    
    TBXMLElement *_eventXML = [TBXML childElementNamed:@"Marker" parentElement:_animation];
    
    if (_eventXML) {
        do {
            NSString *eventType = [TBXML valueOfAttributeNamed:@"name" forElement:_eventXML];
            int     frameIndex   = [[TBXML valueOfAttributeNamed:@"frame" forElement:_eventXML] intValue];
            
            FTCEventInfo *_eventInfo = [[FTCEventInfo alloc] init];
            [_eventInfo setFrameIndex:frameIndex];
            [_eventInfo setEventType:eventType];
            
            [__eventsArr insertObject:_eventInfo atIndex:frameIndex];
            
        } while ((_eventXML = [TBXML nextSiblingNamed:@"Marker" searchFromElement:_eventXML]));
    }
    
    FTCAnimEvent *__eventInfo = [[FTCAnimEvent alloc] init];
    [__eventInfo setFrameCount:_animationLength];
    [__eventInfo setEventsInfo:__eventsArr];
    
    __eventsArr = nil;
    __eventInfo = nil;
}

+(FTCFrameInfo *) getFrameInfoFromElement:(TBXMLElement *)_frameInfo
{
    FTCFrameInfo *fi = [[FTCFrameInfo alloc] init];
    
    
    fi.index = [[TBXML valueOfAttributeNamed:@"index" forElement:_frameInfo] intValue];
    
    fi.x = [[TBXML valueOfAttributeNamed:@"x" forElement:_frameInfo] floatValue];
    fi.y = -([[TBXML valueOfAttributeNamed:@"y" forElement:_frameInfo] floatValue]);
    
    
    fi.scaleX = [[TBXML valueOfAttributeNamed:@"scaleX" forElement:_frameInfo] floatValue];
    fi.scaleY = [[TBXML valueOfAttributeNamed:@"scaleY" forElement:_frameInfo] floatValue];
    
    fi.rotation = [[TBXML valueOfAttributeNamed:@"rotation" forElement:_frameInfo] floatValue];
    
    NSError *noAlpha;
    
    fi.alpha = [[TBXML valueOfAttributeNamed:@"alpha" forElement:_frameInfo error:&noAlpha] floatValue];
    
    if (noAlpha) fi.alpha = 1.0;
    
    return fi;
}

+(TBXMLElement*) getRootElementFromXML:(NSString *)_xmlFile
{
    NSError  *error      = nil;
    TBXML    *_xmlMaster = [TBXML newTBXMLWithXMLFile:_xmlFile error:&error] ;
    
    TBXMLElement *_root  = _xmlMaster.rootXMLElement;
    
    if (_root == nil) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return _root;
}

@end
