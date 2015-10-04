//
//  OriginateRemoteCollection+Internal.h
//  OriginateRemoteCollection
//
//  Created by Philip Kluz on 10/03/15.
//  Copyright © 2015 Originate Inc. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, OriginateRemoteCollectionState) {
    OriginateRemoteCollectionStateNone,
    OriginateRemoteCollectionStateIdle,
    OriginateRemoteCollectionStateLoading
};

@interface OriginateRemoteCollection<__covariant T> ()
{
    NSArray<T> *_objects;
}

#pragma mark - Properties
@property (nonatomic, assign, readwrite) OriginateRemoteCollectionState state;
@property (nonatomic, strong, readwrite) NSError *lastError;
@property (nonatomic, strong, readwrite) NSArray<T> *objects;

#pragma mark - Methods
- (void)setObjects:(NSArray<T> *)objects;
- (void)setLoading;
- (void)setError:(NSError *)error;
- (void)setState:(OriginateRemoteCollectionState)state error:(NSError *)error;

@end
