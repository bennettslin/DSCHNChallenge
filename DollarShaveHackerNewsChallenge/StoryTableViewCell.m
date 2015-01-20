//
//  StoryTableViewCell.m
//  DollarShaveHackerNewsChallenge
//
//  Created by Bennett Lin on 1/19/15.
//  Copyright (c) 2015 Bennett Lin. All rights reserved.
//

#import "StoryTableViewCell.h"

@interface StoryTableViewCell ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLRequest *urlRequest;

@end

@implementation StoryTableViewCell

-(void)awakeFromNib {
    // Initialization code
}

#pragma mark - network request methods

-(void)fetchDataForStoryID:(NSNumber *)storyID {
  
  NSString *storyURLString = [NSString stringWithFormat:@"https://hacker-news.firebaseio.com/v0/item/%@.json?print=pretty", storyID];
  
  NSURLRequest *storyURLRequest = [self requestForURLString:storyURLString];
  
  NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:storyURLRequest
                                                   completionHandler:[self storyTaskCompletion]];
  [dataTask resume];
}

#pragma mark - session methods

-(NSURLSession *)session {
  if (!_session) {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:configuration];
  }
  return _session;
}

-(void(^)(NSData *data, NSURLResponse *response, NSError *error))storyTaskCompletion {
  
  __weak typeof(self) weakSelf = self;
  
  void(^storyTaskCompletion)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (!error) {
      NSError *jsonError;
      id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
      
      if (!jsonError) {
        
          // retrieving json dictionary for story
        if ([jsonObject isKindOfClass:NSDictionary.class]) {
          
          NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
          NSString *headline = jsonDictionary[@"title"];
          NSString *urlString = jsonDictionary[@"url"];
          self.urlRequest = [self requestForURLString:urlString];
          
            // now update text label on main thread
          dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.textLabel.text = headline;
          });
        }
        
      } else {
        NSLog(@"%@", jsonError.localizedDescription);
      }
    } else {
      NSLog(@"%@", error.localizedDescription);
    }
  };
  
  return storyTaskCompletion;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

}

#pragma mark - helper methods

-(NSURLRequest *)requestForURLString:(NSString *)urlString {
  NSString *escapedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:escapedString];
  return [NSURLRequest requestWithURL:url];
}

@end
