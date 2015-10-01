//
//  MyDataSource.h
//  OriginateAsyncCollection-Example
//
//  Created by Philip Kluz on 10/1/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

@import UIKit;
@import OriginateAsyncCollection;
@import DZNEmptyDataSet;

@interface MyDataSource <__covariant T> : OriginateAsyncCollection <UITableViewDataSource,
                                                                    UITableViewDelegate>

#pragma mark - Properties
- (instancetype)initWithTableView:(UITableView *)tableView;

@end
