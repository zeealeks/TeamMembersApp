//
//  MemberDetailsViewController.m
//  TeamMembersApp
//
//  Created by Aleksandra Zajda on 12/6/14.
//  Copyright (c) 2014 Aleksandra Zajda. All rights reserved.
//

#import <objc/runtime.h>
#import "MemberDetailsViewController.h"

#define SKILL_LABEL_TAG 1000
#define SKILL_LEVEL_VIEW_TAG 2000
#define SKILL_LEVEL_LABEL_TAG 3000
#define CORNER_RADIUS 5.0f
#define UNDEFINED_SKILL "??"

@interface MemberDetailsViewController ()

@end

@implementation MemberDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.nameLabel.text = _member.name;
    
    NSArray *skillKeys = [_member.skills allKeys];
    for (int i = 0; i < skillKeys.count; i++) {
        if (i > 2) {
            NSLog(@"%s : %s", __PRETTY_FUNCTION__,
                  [[NSString stringWithFormat:@"Max skills to display by default = 2. Actuall numbers of skills: {%lu}", (unsigned long)skillKeys.count] UTF8String]);
            break;
        }
        UILabel *skillNamelabel = (UILabel*)[self.view viewWithTag:(SKILL_LABEL_TAG+i)];
        NSString *skillName = skillKeys[i];
        skillNamelabel.text = skillName;
        
        UIView *skillView = [self.view viewWithTag:(SKILL_LEVEL_VIEW_TAG+i)];
        float skillLevel = [skillName isEqualToString:@UNDEFINED_SKILL]
                            ? 0 : [_member.skills[skillName] floatValue]/100; // don't draw skill level if not defined
        
        [skillView.superview addConstraint:[NSLayoutConstraint constraintWithItem:skillView attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual toItem:skillView.superview
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:skillLevel constant:0]];
        
        UILabel *skillLevelLabel = (UILabel*)[self.view viewWithTag:(SKILL_LEVEL_LABEL_TAG+i)];
        skillLevelLabel.text = [NSString stringWithFormat:@"%d%%",(int)(skillLevel*100)];
    }
    
    _image.layer.borderWidth = 3.0f;

    if (_member.image) { // if image already downloaded set it up, otherwise download outside main thread
        _image.image = _member.image;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:_member.imageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                _image.image = [UIImage imageWithData:imageData];
            });
        });
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
