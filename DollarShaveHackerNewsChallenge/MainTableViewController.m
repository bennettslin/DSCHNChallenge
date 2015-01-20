//
//  ViewController.m
//  DollarShaveHackerNewsChallenge
//
//  Created by Bennett Lin on 1/19/15.
//  Copyright (c) 2015 Bennett Lin. All rights reserved.
//

#import "MainTableViewController.h"
#import "StoryTableViewCell.h"
#import "WebViewController.h"

@interface MainTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSArray *topStoriesIDs;

@end

@implementation MainTableViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
  NSString *storiesURLString = @"https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty";
  NSURLRequest *storiesURLRequest = [self requestForURLString:storiesURLString];

  NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:storiesURLRequest
                                                   completionHandler:[self storiesTaskCompletion]];
  [dataTask resume];
}

-(void)viewDidLayoutSubviews {
  self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - table view data source and delegate methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.topStoriesIDs.count;
}

-(StoryTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoryCell" forIndexPath:indexPath];
  
  NSNumber *storyID = self.topStoriesIDs[indexPath.row];
  [cell fetchDataForStoryID:storyID];
  
  return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"StorySegue"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    StoryTableViewCell *cell = (StoryTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.urlRequest) {
      WebViewController *webVC = [segue destinationViewController];
      webVC.urlRequest = cell.urlRequest;
    }
  }
}

#pragma mark - session accessor methods

-(NSURLSession *)session {
  if (!_session) {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:configuration];
  }
  return _session;
}

-(void(^)(NSData *data, NSURLResponse *response, NSError *error))storiesTaskCompletion {

  __weak typeof(self) weakSelf = self;
  
  void(^storiesTaskCompletion)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (!error) {
      NSError *jsonError;
      id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
      
      if (!jsonError) {
        
          // retrieving array of ids for top stories
        if ([jsonObject isKindOfClass:NSArray.class]) {
          
          NSArray *jsonArray = (NSArray *)jsonObject;
          weakSelf.topStoriesIDs = [weakSelf storiesArrayFromJsonArray:jsonArray];
          
            // now update views on main thread
          dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
          });
        }

      } else {
        NSLog(@"%@", jsonError.localizedDescription);
      }
    } else {
      NSLog(@"%@", error.localizedDescription);
    }
  };
  
  return storiesTaskCompletion;
}

-(NSArray *)storiesArrayFromJsonArray:(NSArray *)jsonArray {
  
  NSMutableArray *tempArray = [NSMutableArray new];
  
  for (NSString *string in jsonArray) {
    NSNumber *storyID = @([string integerValue]);
    [tempArray addObject:storyID];
  }
  
  return [NSArray arrayWithArray:tempArray];
}

-(void(^)(NSData *data, NSURLResponse *response, NSError *error))storyTaskCompletion {
  
  __weak typeof(self) weakSelf = self;
  
  void(^storyTaskCompletion)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (!error) {
      NSError *jsonError;
      id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
      
      if (!jsonError) {
        
          // retrieving dictionary for
        if ([jsonObject isKindOfClass:NSArray.class]) {
          
          NSArray *jsonArray = (NSArray *)jsonObject;
          self.topStoriesIDs = [self storiesArrayFromJsonArray:jsonArray];
          
            // now update views on main thread
          dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
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

#pragma mark - helper methods

-(NSURLRequest *)requestForURLString:(NSString *)urlString {
  NSString *escapedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:escapedString];
  return [NSURLRequest requestWithURL:url];
}

#pragma mark - system methods

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
