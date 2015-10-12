//
//  OriginateMutableRemoteArray.h
//  OriginateRemoteArray
//
//  Created by Philip Kluz on 10/03/15.
//  Copyright © 2015 Originate Inc. All rights reserved.
//

#import "OriginateRemoteArray.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OriginateMutableRemoteArrayMutationCompletion)(BOOL success, NSError *error);
typedef void(^OriginateMutableRemoteArrayMutationHandler)(OriginateMutableRemoteArrayMutationCompletion);

@protocol OriginateMutableRemoteArrayDelegate <OriginateRemoteArrayDelegate>

@optional
- (void)remoteArray:(OriginateRemoteArray *)array willRemoveObjects:(NSArray *)objects;
- (void)remoteArray:(OriginateRemoteArray *)array didRemoveObjects:(NSArray *)objects;
- (void)remoteArray:(OriginateRemoteArray *)array didRevertRemovalOfObjects:(NSArray *)objects error:(NSError *)error;

- (void)remoteArray:(OriginateRemoteArray *)array willAddObjects:(NSArray *)objects;
- (void)remoteArray:(OriginateRemoteArray *)array didAddObjects:(NSArray *)objects;
- (void)remoteArray:(OriginateRemoteArray *)array didRevertAdditionOfObjects:(NSArray *)objects error:(NSError *)error;

@end

@interface OriginateMutableRemoteArray<T> : OriginateRemoteArray

#pragma mark - Properties
@property (nonatomic, weak, readwrite) id<OriginateMutableRemoteArrayDelegate> delegate;

#pragma mark - Methods
- (void)addObjects:(NSArray<T> *)objects
           handler:(OriginateMutableRemoteArrayMutationHandler)addHandler;
- (void)removeObjects:(NSArray<T> *)objects
              handler:(OriginateMutableRemoteArrayMutationHandler)removeHandler;

@end

NS_ASSUME_NONNULL_END
