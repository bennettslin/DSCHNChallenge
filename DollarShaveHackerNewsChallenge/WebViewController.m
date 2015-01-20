//
//  WebViewController.m
//  DollarShaveHackerNewsChallenge
//
//  Created by Bennett Lin on 1/19/15.
//  Copyright (c) 2015 Bennett Lin. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

-(void)viewDidLoad {
  [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.webView loadRequest:self.urlRequest];
}

-(void)viewDidLayoutSubviews {
  self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - web view delegate methods

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  NSLog(@"%@", error.localizedDescription);
}

#pragma mark - system methods

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
