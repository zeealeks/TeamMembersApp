//
//  Member.m
//  TeamMembersApp
//
//  Created by Aleksandra Zajda on 12/6/14.
//  Copyright (c) 2014 Aleksandra Zajda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Member.h"

@implementation Member

-(instancetype)initWithName:(NSString*)name imageURL:(NSString*)url skills:(NSMutableDictionary*)skills {
    self = [super init];
    if (self) {
        _name = name;
        _imageURL = [NSURL URLWithString:url];
        _skills = skills;
        _image = nil;
    }
    
    return self;
}

@end
