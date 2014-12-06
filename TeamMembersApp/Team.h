//
//  Team.h
//  TeamMembersApp
//
//  Created by Aleksandra Zajda on 12/6/14.
//  Copyright (c) 2014 Aleksandra Zajda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Team : NSObject

@property (nonatomic, strong) NSString *name;

-(instancetype)initWithName:(NSString*)name members:(NSMutableArray*)members;
-(NSMutableArray*)members;

@end
