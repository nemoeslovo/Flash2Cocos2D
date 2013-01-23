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
    
    FTCAnimationsSet *animationSet = [[FTCAnimationsSet alloc] init];
    NSString *baseFile = [NSString stringWithFormat:@"%@_animations.xml", _xmlfile];
    
    NSError *error = nil;
    TBXML *_xmlMaster = [TBXML newTBXMLWithXMLFile:baseFile error:&error];
    
    TBXMLElement *_root = _xmlMaster.rootXMLElement;
    if (!_root) return NO;
    
    [animationSet setFrameRate:[TBXML valueOfAttributeNamed:@"frameRate" forElement:_root]];
    
    TBXMLElement *_animation = [TBXML childElementNamed:@"Animation" parentElement:_root];
    NSMutableArray *animations = [NSMutableArray array];
    
    // set the character animation (it will be filled with events)
    do {
        FTCAnimationInfo *animation = [[FTCAnimationInfo alloc] init];
        [animation setName:[TBXML valueOfAttributeNamed:@"name" forElement:_animation]];
        
        TBXMLElement *_part = [TBXML childElementNamed:@"Part" parentElement:_animation];
        NSMutableArray *parts = [NSMutableArray array];
        do {
            
            FTCPartInfo *partInfo = [[FTCPartInfo alloc] init];
            [partInfo setName:[TBXML valueOfAttributeNamed:@"name" forElement:_part]];
            
            TBXMLElement *_frameInfo = [TBXML childElementNamed:@"Frame" parentElement:_part];
            NSMutableArray *frames = [NSMutableArray array];
            
            if (_frameInfo) {
                do {
                    FTCFrameInfo *fi = [[FTCFrameInfo alloc] init];
                    
                    
                    fi.index = [[TBXML valueOfAttributeNamed:@"index" forElement:_frameInfo] intValue];
                    
                    fi.a = [[TBXML valueOfAttributeNamed:@"a" forElement:_frameInfo] floatValue];
                    fi.b = ([[TBXML valueOfAttributeNamed:@"b" forElement:_frameInfo] floatValue]);
                    
                    
                    fi.c = [[TBXML valueOfAttributeNamed:@"c" forElement:_frameInfo] floatValue];
                    fi.d = [[TBXML valueOfAttributeNamed:@"d" forElement:_frameInfo] floatValue];
                    
                    fi.tx = [[TBXML valueOfAttributeNamed:@"tx" forElement:_frameInfo] floatValue];
                    fi.ty = [[TBXML valueOfAttributeNamed:@"ty" forElement:_frameInfo] floatValue];

                    NSError *error = nil;
                    fi.alpha = [[TBXML valueOfAttributeNamed:@"alpha" forElement:_frameInfo error:&error] floatValue];
                    if (error) {
                        fi.alpha = 1.0;
                    }

                    error = nil;
                    fi.rightMargined = [[TBXML valueOfAttributeNamed:@"rightMargined" forElement:_frameInfo error:&error] boolValue];
                    if (error) {
                        fi.rightMargined = NO;
                    }

                    error = nil;
                    fi.bottomMargined = [[TBXML valueOfAttributeNamed:@"bottomMargined" forElement:_frameInfo error:&error] boolValue];
                    if (error) {
                        fi.bottomMargined = NO;
                    }

                    [frames addObject:fi];
                    
                } while ((_frameInfo = _frameInfo->nextSibling));
            }
            
            [partInfo setFramesInfo:frames];
            [parts addObject:partInfo];
            
        } while ((_part = _part->nextSibling));
        [animation setParts:parts];
        [animation setFrameCount:[[TBXML valueOfAttributeNamed:@"frameCount" forElement:_animation] intValue]];
        [animations addObject:animation];
        
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
        
        
    } while ((_animation = _animation->nextSibling));
    [animationSet setAnimations:animations];
    
    return animationSet;
}

+(FTCAnimationInfo *) getAnimationInfoFromElement:(TBXMLElement *)_animation {
    NSString *animName  = [TBXML valueOfAttributeNamed:@"name" 
                                            forElement:_animation];
    
    int      frameCount = [[TBXML valueOfAttributeNamed:@"frameCount" 
                                             forElement:_animation] integerValue];
    
    if ([animName isEqualToString:@""]) {
        animName = @"_init";
    }
    
    NSMutableArray *parts = [NSMutableArray array];
    
    TBXMLElement *_part = [TBXML childElementNamed:@"Part" parentElement:_animation];
    while (_part) {
        [parts addObject:[self getPartInfoFromElement:_part]];
        _part = _part->nextSibling;
    }
    
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
    
    TBXMLElement *_frameInfo = [TBXML childElementNamed:@"Frame" parentElement:_part];
    while (_frameInfo) {
        [__partFrames addObject:[self getFrameInfoFromElement:_frameInfo]];
        _frameInfo = _frameInfo ->nextSibling;
    }
     
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
    if (_frameInfo) {
        NSLog(@"herna");
        return nil;
    }
    FTCFrameInfo *fi = [[FTCFrameInfo alloc] init];
//
//    fi.x = [[TBXML valueOfAttributeNamed:@"x" forElement:_frameInfo] floatValue];
//    fi.y = -([[TBXML valueOfAttributeNamed:@"y" forElement:_frameInfo] floatValue]);
//
//
//    fi.scaleX = [[TBXML valueOfAttributeNamed:@"scaleX" forElement:_frameInfo] floatValue];
//    fi.scaleY = [[TBXML valueOfAttributeNamed:@"scaleY" forElement:_frameInfo] floatValue];
//
//    fi.rotation = [[TBXML valueOfAttributeNamed:@"rotation" forElement:_frameInfo] floatValue];
//
//    fi.skewX = [[TBXML valueOfAttributeNamed:@"skewX" forElement:_frameInfo] floatValue];
//    fi.skewY = [[TBXML valueOfAttributeNamed:@"skewY" forElement:_frameInfo] floatValue];
//
    
    
    NSError *noAlpha = nil;
    fi.alpha = [[TBXML valueOfAttributeNamed:@"alpha" forElement:_frameInfo error:&noAlpha] floatValue];
    
    if (noAlpha != nil) {
        fi.alpha = 1.0f;
    }
    
    fi.index = [[TBXML valueOfAttributeNamed:@"index" forElement:_frameInfo] intValue];
    
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
