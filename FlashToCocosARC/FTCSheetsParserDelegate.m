//
//  FTCSheetsParser.m
//  F2CExamle
//
//  Created by Danila Kolesnikov on 6/29/13.
//  Copyright (c) 2013 dandandan. All rights reserved.
//

#import "FTCSheetsParserDelegate.h"
#import "FTCObjectInfo.h"

#define TAG_TEXTURE      @"Texture"

#define ATTR_NAME        @"name"
#define ATTR_PATH        @"path"
#define ATTR_REG_POINT_X @"registrationPointX"
#define ATTR_REG_POINT_Y @"registrationPointY"
#define ATTR_Z_INDEX     @"zIndex"


@implementation FTCSheetsParserDelegate {
    FTCObjectInfo   *_currentObjectInfo;
    NSMutableString *_currentStringValue;
}

@synthesize arrayOfObjects = _arrayOfObjects;

#pragma _parser delegate

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSString *errorString = [NSString stringWithFormat:@"Error code %i", [parseError code]];
    NSLog(@"Error parsing XML: %@", errorString);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    
    
    if ([elementName isEqualToString:TAG_TEXTURE]) {
        _currentObjectInfo = [[FTCObjectInfo alloc] initWithName:[attributeDict objectForKey:ATTR_NAME]
                                                         andPath:[attributeDict objectForKey:ATTR_PATH]
                                                          andRPX:[[attributeDict objectForKey:ATTR_REG_POINT_X] floatValue]
                                                          andRPY:[[attributeDict objectForKey:ATTR_REG_POINT_Y] floatValue]
                                                       andZIndex:[attributeDict objectForKey:ATTR_Z_INDEX]];
        if (!_arrayOfObjects)
            _arrayOfObjects = [[NSMutableArray alloc] init];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    if ( [elementName isEqualToString:TAG_TEXTURE]) {
        [_arrayOfObjects addObject:_currentObjectInfo];
        return;
    }
}

@end
