//
//  ViewController.m
//  OriginateRemoteCollection-Example
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "MyViewController.h"
#import "MyDateDataSource.h"
#import "MyEmptyController.h"

@interface MyViewController () <MyEmptyControllerDelegate>

#pragma mark - Properties
@property (nonatomic, strong, readwrite) MyDateDataSource *dataSource;
@property (nonatomic, strong, readwrite) MyEmptyController *emptyController;

@end

@implementation MyViewController


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    self.navigationItem.rightBarButtonItem = [self addContentBarButtonItem];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dataSource load:^(void (^completion)(NSArray *result, NSError *error))
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             completion(@[], nil);
         });
     }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (NSString *)title
{
    return @"Remote Collection Example";
}


#pragma mark - MyViewController

- (void)addContent:(id)sender
{
    self.navigationItem.rightBarButtonItem = [self activityBarButtonItem];

    __weak __typeof(self) weakSelf = self;
    [self.dataSource addObjects:@[[NSDate date]]
                        handler:^(void (^completion)(BOOL success, NSError *error))
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             __strong __typeof(self) strongSelf = weakSelf;
             completion(YES, nil);
             strongSelf.navigationItem.rightBarButtonItem = [strongSelf addContentBarButtonItem];
         });
    }];
}

- (void)refresh:(UIRefreshControl *)control
{
    __weak __typeof(self) weakSelf = self;
    [self.dataSource load:^(void (^completion)(NSArray *result, NSError *error))
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             __strong __typeof(self) strongSelf = weakSelf;
             completion([strongSelf.dataSource allObjects], nil);
             [control endRefreshing];
         });
     }];
}

- (UIBarButtonItem *)addContentBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                         target:self
                                                         action:@selector(addContent:)];
}

- (UIBarButtonItem *)activityBarButtonItem
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    return [[UIBarButtonItem alloc] initWithCustomView:indicator];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleGrouped];
        _tableView.dataSource = self.dataSource;
        _tableView.delegate = self.dataSource;
        _tableView.emptyDataSetDelegate = self.emptyController;
        _tableView.emptyDataSetSource = self.emptyController;
    }
    
    return _tableView;
}

- (MyDateDataSource *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[MyDateDataSource alloc] initWithTableView:self.tableView];
    }
    
    return _dataSource;
}

- (MyEmptyController *)emptyController
{
    if (!_emptyController) {
        _emptyController = [[MyEmptyController alloc] initWithScrollView:self.tableView
                                                              dataSource:self.dataSource];
        _emptyController.delegate = self;
    }
    
    return _emptyController;
}


#pragma mark - <MyEmptyControllerDelegate>

- (void)emptyControllerRequestsReload:(MyEmptyController *)emptyController
{
    [self refresh:nil];
}

@end
