//
//  MemberDetailsViewController.h
//  TeamMembersApp
//
//  Created by Aleksandra Zajda on 12/6/14.
//  Copyright (c) 2014 Aleksandra Zajda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Member.h"

@interface MemberDetailsViewController : UIViewController

@property (strong, nonatomic) Member *member;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
