//
//  FTCObjectInfo.h
//
//  Created by Danila Kolesnikov on 1/9/13.
//  Copyright 2013 Flexymind. All rights reserved.
//
//

#import <Foundation/Foundation.h>

@interface FTCObjectInfo : NSObject

    @property(retain) NSString *name;
    @property(retain) NSString *path;
    @property         float    registrationPointX;
    @property         float    registrationPointY;
    @property         int      zIndex;

-(id)initWithName:(NSString *)name
          andPath:(NSString *)path
           andRPX:(float)rpx
           andRPY:(float)rpy
        andZIndex:(int)zIndex;

@end
