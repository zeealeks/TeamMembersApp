//
//  Team.m
//  TeamMembersApp
//
//  Created by Aleksandra Zajda on 12/6/14.
//  Copyright (c) 2014 Aleksandra Zajda. All rights reserved.
//

#import "Team.h"

@interface Team ()

@property (nonatomic, strong) NSMutableArray *members;

@end

@implementation Team

-(instancetype)initWithName:(NSString*)name members:(NSMutableArray*)members {
    self = [super init];
    if (self) {
        _name = name;
        _members = members;
    }
    
    return self;
}

-(NSMutableArray*)members {
    return _members;
}

@end
