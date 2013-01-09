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

@implementation FTCParser


-(BOOL) parseXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character
{
    // animations file
    BOOL animParse  = [self parseAnimationXML:_xmlfile toCharacter:_character];
    
    [_character setFirstPose];
    return (animParse);
}


+(NSArray *)parseSheetXML:(NSString *)_xmlfile
{
    NSString *baseFile   = [NSString stringWithFormat:@"%@_sheets.xml", _xmlfile];
    NSError  *error      = nil;
    TBXML    *_xmlMaster = [[TBXML newTBXMLWithXMLFile:baseFile error:&error] autorelease];
    
    TBXMLElement *_root  = _xmlMaster.rootXMLElement;

    if (_root == nil) {
        CCLOG(error);
    }
    
    TBXMLElement   *_texturesheet = [TBXML childElementNamed:@"TextureSheet" parentElement:_root];
    NSMutableArray *objectsList   = [NSArray array];
    
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
        [objectInfo release];
    };
    [TBXML iterateElementsForQuery:@"Texture" fromElement:_texturesheet withBlock:block];
    
    return objectsList;
}

-(BOOL) parseAnimationXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character
{
    NSString *baseFile = [NSString stringWithFormat:@"%@_animations.xml", _xmlfile];
    
    NSError *error = nil;    
    TBXML *_xmlMaster = [TBXML newTBXMLWithXMLFile:baseFile error:&error];
    
    TBXMLElement *_root = _xmlMaster.rootXMLElement;
    if (!_root) return NO;

    _character.frameRate = [[TBXML valueOfAttributeNamed:@"frameRate" forElement:_root] floatValue];
    
    TBXMLElement *_animation = [TBXML childElementNamed:@"Animation" parentElement:_root];
    
    // set the character animation (it will be filled with events)
    do {                
        NSString *animName = [TBXML valueOfAttributeNamed:@"name" forElement:_animation];
        if ([animName isEqualToString:@""]) animName = @"_init";
        
        TBXMLElement *_part = [TBXML childElementNamed:@"Part" parentElement:_animation];
        do {
        
            NSString *partName = [TBXML valueOfAttributeNamed:@"name" forElement:_part];
            
            NSRange ghostNameRange;
            
            ghostNameRange = [partName rangeOfString:@"ftcghost"];
             
            if (ghostNameRange.location != NSNotFound) continue;
                 
            NSMutableArray *__partFrames = [[NSMutableArray alloc] init];
            
            TBXMLElement *_frameInfo = [TBXML childElementNamed:@"Frame" parentElement:_part];

            FTCSprite *__sprite = [_character getChildByName:partName];

            if (_frameInfo) {
                do {
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
             
                    [__partFrames addObject:fi];
                                        
                } while ((_frameInfo = _frameInfo->nextSibling));
            }
            
            [__sprite.animationsArr setValue:__partFrames forKey:animName];         
            
        } while ((_part = _part->nextSibling));        
        
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
        
        [_character.animationEventsTable setValue:__eventInfo forKey:animName];

        __eventsArr = nil;
        __eventInfo = nil;


    } while ((_animation = _animation->nextSibling));
   
    return YES;
}

@end
