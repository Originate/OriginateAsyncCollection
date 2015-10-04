//
//  MyEmptyController.m
//  OriginateRemoteCollection-Example
//
//  Created by Philip Kluz on 10/1/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "MyEmptyController.h"

@interface MyEmptyController ()

#pragma mark - Methods
@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) MyDateDataSource *dataSource;

@end

@implementation MyEmptyController

#pragma mark - MyEmptyController

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
                        dataSource:(MyDateDataSource *)dataSource
{
    self = [super init];
    
    if (self) {
        _dataSource = dataSource;
        _scrollView = scrollView;
    }
    
    return self;
}

- (void)setDataSource:(MyDateDataSource *)dataSource
{
    _dataSource = dataSource;
    [self.scrollView reloadEmptyDataSet];
}


#pragma mark - <DZNEmptyDataSetDelegate>

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return [self.dataSource isEmpty] || [self.dataSource isLoading];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    if ([self.delegate respondsToSelector:@selector(emptyControllerRequestsReload:)]) {
        [self.delegate emptyControllerRequestsReload:self];
    }
}

#pragma mark - <DZNEmptyDataSetSource>

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    if ([self.dataSource isEmpty]) {
        return [[NSAttributedString alloc] initWithString:@"No Content"];
    }
    else if ([self.dataSource isLoading]) {
        return [[NSAttributedString alloc] initWithString:@"Loading…"];
    }
    
    return nil;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if ([self.dataSource isEmpty]) {
        return [[NSAttributedString alloc] initWithString:@"Sorry about that. Try creating some content +."];
    }
    
    return nil;
}

@end
