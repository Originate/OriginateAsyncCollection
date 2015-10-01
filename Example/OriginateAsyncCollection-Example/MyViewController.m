//
//  ViewController.m
//  OriginateAsyncCollection-Example
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "MyViewController.h"
#import "MyDataSource.h"
#import "MyEmptyController.h"

@interface MyViewController () <MyEmptyControllerDelegate,
                                OriginateAsyncCollectionDelegate>

#pragma mark - Properties
@property (nonatomic, strong, readwrite) MyDataSource<NSDate *> *dataSource;
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
    
    // 1. Kickoff Loading.
    [self.dataSource setLoading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.dataSource setElements:@[]];
    });
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (NSString *)title
{
    return @"Async Data Source";
}

#pragma mark - MyViewController

- (void)addContent:(id)sender
{
    self.navigationItem.rightBarButtonItem = [self activityBarButtonItem];
    
    // 2. Kickoff Async / Delayed Content Loading. Think Pull To Refresh.
    [self.dataSource setLoading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray<NSDate *> *existingContent = self.dataSource.elements;
        NSArray<NSDate *> *newContent = [existingContent arrayByAddingObject:[NSDate date]];
        
        [self.dataSource setElements:newContent];
        self.navigationItem.rightBarButtonItem = [self addContentBarButtonItem];
    });
}

- (void)refresh:(UIRefreshControl *)control
{
    [self.dataSource setLoading];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [control endRefreshing];
        [self.dataSource setElements:self.dataSource.elements];
    });
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

- (MyDataSource<NSDate *> *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[MyDataSource alloc] initWithTableView:self.tableView];
        _dataSource.delegate = self;
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

#pragma mark - <OriginateAsyncCollectionDelegate>

- (void)asyncCollectionWillLoad:(OriginateAsyncCollection *)collection
{
    [self.tableView reloadEmptyDataSet];
}

- (void)asyncCollectionDidLoad:(OriginateAsyncCollection *)collection
{
    [self.tableView reloadData];
}

- (void)asyncCollectionWillReload:(OriginateAsyncCollection *)collection
{
    [self.tableView reloadEmptyDataSet];
}

- (void)asyncCollectionDidReload:(OriginateAsyncCollection *)collection
{
    [self.tableView reloadEmptyDataSet];
}

@end
