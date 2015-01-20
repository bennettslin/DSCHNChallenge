//
//  StoryTableViewCell.h
//  DollarShaveHackerNewsChallenge
//
//  Created by Bennett Lin on 1/19/15.
//  Copyright (c) 2015 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryTableViewCell : UITableViewCell

@property (readonly, nonatomic) NSURLRequest *urlRequest;

-(void)fetchDataForStoryID:(NSNumber *)storyID;

@end
