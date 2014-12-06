//
//  Member.h
//  TeamMembersApp
//
//  Created by Aleksandra Zajda on 12/6/14.
//  Copyright (c) 2014 Aleksandra Zajda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Member : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *skills;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;

-(instancetype)initWithName:(NSString*)name imageURL:(NSString*)url skills:(NSMutableDictionary*)skills;

@end
