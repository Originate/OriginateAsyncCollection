//
//  MyEmptyController.h
//  OriginateAsyncCollection-Example
//
//  Created by Philip Kluz on 10/1/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

@import Foundation;
@import DZNEmptyDataSet;

#import "MyDataSource.h"

@protocol MyEmptyControllerDelegate;

@interface MyEmptyController : NSObject <DZNEmptyDataSetSource,
                                         DZNEmptyDataSetDelegate>

#pragma mark - Properties
@property (nonatomic, weak, readwrite) id<MyEmptyControllerDelegate> delegate;

#pragma mark - Methods
- (instancetype)initWithScrollView:(UIScrollView *)scrollView
                        dataSource:(MyDataSource *)dataSource;

@end

@protocol MyEmptyControllerDelegate <NSObject>

#pragma mark - Methods
@required
- (void)emptyControllerRequestsReload:(MyEmptyController *)emptyController;

@end
