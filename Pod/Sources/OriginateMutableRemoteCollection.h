//
//  OriginateMutableRemoteCollection.h
//  OriginateRemoteCollection-Example
//
//  Created by Philip Kluz on 10/03/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "OriginateRemoteCollection.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OriginateMutableRemoteCollectionMutationCompletion)(BOOL success, NSError *error);
typedef void(^OriginateMutableRemoteCollectionMutationHandler)(OriginateMutableRemoteCollectionMutationCompletion);

@protocol OriginateMutableRemoteCollectionDelegate <OriginateRemoteCollectionDelegate>

@optional
- (void)remoteCollection:(OriginateRemoteCollection *)collection willRemoveObjects:(NSArray *)objects;
- (void)remoteCollection:(OriginateRemoteCollection *)collection didRemoveObjects:(NSArray *)objects;
- (void)remoteCollection:(OriginateRemoteCollection *)collection didRevertRemovalOfObjects:(NSArray *)objects error:(NSError *)error;

- (void)remoteCollection:(OriginateRemoteCollection *)collection willAddObjects:(NSArray *)objects;
- (void)remoteCollection:(OriginateRemoteCollection *)collection didAddObjects:(NSArray *)objects;
- (void)remoteCollection:(OriginateRemoteCollection *)collection didRevertAdditionOfObjects:(NSArray *)objects error:(NSError *)error;

@end

@interface OriginateMutableRemoteCollection : OriginateRemoteCollection

#pragma mark - Properties
@property (nonatomic, weak, readwrite) id<OriginateMutableRemoteCollectionDelegate> delegate;

#pragma mark - Methods
- (void)addObjects:(NSArray *)objects handler:(OriginateMutableRemoteCollectionMutationHandler)addHandler;
- (void)removeObjects:(NSArray *)objects handler:(OriginateMutableRemoteCollectionMutationHandler)removeHandler;

@end

NS_ASSUME_NONNULL_END
