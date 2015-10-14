//
//  MyDateDataSource.m
//  OriginateRemoteCollection-Example
//
//  Created by Philip Kluz on 10/1/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "MyDateDataSource.h"

@interface MyDateDataSource () <OriginateMutableRemoteArrayDelegate>

#pragma mark - Properties
@property (nonatomic, weak, readwrite) UITableView *tableView;

@end

@implementation MyDateDataSource

#pragma mark - MyDateDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    
    if (self) {
        self.delegate = self;
        _tableView = tableView;
        [tableView registerClass:[UITableViewCell class]
          forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    return self;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self[indexPath.row]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id objectToRemove = self[indexPath.row];
        [self removeObjects:@[objectToRemove]
                    handler:^(void (^completion)(BOOL success, NSError *error))
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationLeft];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }];
    }
}

#pragma mark - <OriginateRemoteArrayDelegate>

- (void)remoteArrayWillLoad:(OriginateRemoteArray *)array
{
    [self.tableView reloadEmptyDataSet];
}

- (void)remoteArrayDidLoad:(OriginateRemoteArray *)array
{
    [self.tableView reloadData];
}

- (void)remoteArray:(OriginateRemoteArray *)array willAddObjects:(NSArray *)objects
{
    [self.tableView reloadEmptyDataSet];
}

- (void)remoteArray:(OriginateRemoteArray *)array didAddObjects:(NSArray *)objects
{
    [self.tableView reloadData];
}

- (void)remoteArray:(OriginateRemoteArray *)array willRemoveObjects:(NSArray *)objects
{
    [self.tableView reloadEmptyDataSet];
}

- (void)remoteArray:(OriginateRemoteArray *)array didRemoveObjects:(NSArray *)objects
{
    [self.tableView reloadEmptyDataSet];
}

- (void)remoteArray:(OriginateRemoteArray *)array didRevertAdditionOfObjects:(NSArray *)objects error:(NSError *)error
{
    [self.tableView reloadData];
}

- (void)remoteArray:(OriginateRemoteArray *)array didRevertRemovalOfObjects:(NSArray *)objects error:(NSError *)error
{
    [self.tableView reloadData];
}

- (void)remoteArray:(OriginateRemoteArray *)array didFailWithError:(NSError *)error
{
    [self.tableView reloadData];
}

@end
