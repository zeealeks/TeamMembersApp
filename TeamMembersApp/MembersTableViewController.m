//
//  MembersTableViewController.m
//  TeamMembersApp
//
//  Created by Aleksandra Zajda on 12/6/14.
//  Copyright (c) 2014 Aleksandra Zajda. All rights reserved.
//

#import "SDWebImage/UIImageView+WebCache.h"
#import "MembersTableViewController.h"
#import "MemberDetailsViewController.h"
#import "Team.h"
#import "Member.h"
#import "TFHpple.h"

#define SOURCE_URL "http://lab.farmaprom.pl/zespol/"
#define DEFAULT_KEY_VALUE "unknown"
#define DID_SELECT_ROW_SEGUE "Select Member"

@interface MembersTableViewController ()

@end

@implementation MembersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(loadDataAsync) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self.refreshControl beginRefreshing];
    [self loadDataAsync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.refreshControl beginRefreshing];
    [self loadDataAsync];
}

#pragma mark - getters/setters

- (NSArray*) members {
    if (!_members) {
        _members = [[NSArray alloc] init];
    }
    return _members;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.members count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Team *team = self.members[section];
    return [team.members count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Team *team = self.members[section];
    return  team.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Team *team = self.members[indexPath.section];
    Member *member = team.members[indexPath.row];
    cell.textLabel.text = member.name ;

    [cell.imageView sd_setImageWithURL:member.imageURL placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    [cell.imageView sd_setImageWithURL:member.imageURL
                   placeholderImage:[UIImage imageNamed:@"avatar.png"]
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                              member.image = image;
                          }];
    
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@DID_SELECT_ROW_SEGUE]) {
        UIViewController *destinationViewController = segue.destinationViewController;
        if ([destinationViewController isKindOfClass:[MemberDetailsViewController class]]) {
            NSIndexPath *path = [self.tableView indexPathForSelectedRow];
            Team *team = self.members[path.section];
            Member *member = team.members[path.row];
            ((MemberDetailsViewController*)destinationViewController).member = member;
        }
    }
}

# pragma mark - HTML parsing

-(void) loadDataAsync {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        NSArray *allMembers = [self loadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.members = allMembers;
            [self.tableView reloadData];
        });
    });
}

-(NSArray*) loadData {
    
    NSURL *url = [NSURL URLWithString:@SOURCE_URL];
    NSData *htmlContentData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlContentData];
    NSArray *membersNodes = [parser searchWithXPathQuery:@"//div[@id='team-members']/div[@class='team-member']"];
    
    NSMutableDictionary *teams = [[NSMutableDictionary alloc] init];

    for (TFHppleElement *element in membersNodes) {
        NSString *name = @"";
        NSString *imageURL = @"";
        NSString *position = @DEFAULT_KEY_VALUE;
        NSMutableDictionary *skillsDict = [[NSMutableDictionary alloc] init];
        
        for (TFHppleElement *child in element.children) {

            if ([child.tagName isEqualToString:@"div"]) { //member-image + title
                for (TFHppleElement *grandchild in child.children) {
                    if ([grandchild.tagName isEqualToString:@"h3"]) {
                        name = grandchild.firstChild.content;
                    } else if ([grandchild.tagName isEqualToString:@"p"]) {
                        position = grandchild.firstChild.content;
                    } else if ([grandchild.tagName isEqualToString:@"img"]) {
                        imageURL = grandchild[@"src"];
                    }
                }
            }
            else if([child.tagName isEqualToString:@"ul"]) { // list of skills
                for (TFHppleElement *grandchild in child.children) {
                    if ([grandchild.tagName isEqualToString:@"li"]) {
                        NSString *skillName;
                        NSString *skillLevel;
                        
                        for (TFHppleElement *skill in grandchild.children) {
                            for (id attrName in [skill.attributes allKeys]) {
                                if ([skill.attributes[attrName] isEqualToString:@"skill-title"]) skillName = skill.content;
                                else if ([attrName isEqualToString:@"data-skill"]) skillLevel = skill.attributes[attrName];
                                if (skillName && skillLevel) {
                                    [skillsDict setObject:skillLevel forKey:skillName];
                                    skillLevel = nil;
                                    skillName = nil;
                                }
                            }
                        }
                    }
                }
            }
        }
        
#ifdef DEBUG
        NSLog(@"Member data: %@ : %@ : %@", name, position, imageURL);
        for (NSString *skill in skillsDict.allKeys) {
            NSLog(@"%@ : %@", skill, skillsDict[skill]);
        }
#endif
        
        Member *member = [[Member alloc] initWithName:name imageURL:imageURL skills:skillsDict];
        NSMutableArray *teamMembers = [teams objectForKey:position];
        if (!teamMembers) {
            teamMembers = [[NSMutableArray alloc] initWithObjects:member, nil];
        } else {
            [teamMembers addObject:member];
        }
        [teams setObject:teamMembers forKey:position];
    }
    
    NSMutableArray *allMembers = [[NSMutableArray alloc] init];
    for (id teamName in [teams allKeys]) {
        
        // Sort members by name
        NSSortDescriptor *memberNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES comparator:^(id name1, id name2) {
            return [(NSString *)name1 localizedStandardCompare:(NSString *)name2];
        }];
        
        Team *team = [[Team alloc] initWithName:teamName  members:teams[teamName]];
        [team.members sortUsingDescriptors:@[memberNameSortDescriptor]];
        [allMembers addObject:team];
    }
    
    
    // Sort section_titles by position
    NSSortDescriptor *positionSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES comparator:^(id name1, id name2) {
        return [(NSString *)name1 localizedStandardCompare:(NSString *)name2];
    }];
    [allMembers sortUsingDescriptors:@[positionSortDescriptor]];

    return allMembers;
}


@end
