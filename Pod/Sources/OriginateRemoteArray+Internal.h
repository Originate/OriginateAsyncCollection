//
//  OriginateRemoteArray+Internal.h
//  OriginateRemoteArray
//
//  Created by Philip Kluz on 10/03/15.
//  Copyright © 2015 Originate Inc. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, OriginateRemoteArrayState) {
    OriginateRemoteArrayStateNone,
    OriginateRemoteArrayStateIdle,
    OriginateRemoteArrayStateLoading
};

@interface OriginateRemoteArray<__covariant T> ()
{
    NSArray<T> *_objects;
}

#pragma mark - Properties
@property (nonatomic, assign, readwrite) OriginateRemoteArrayState state;
@property (nonatomic, strong, readwrite) NSError *lastError;
@property (nonatomic, strong, readwrite) NSArray<T> *objects;

#pragma mark - Methods
- (void)setObjects:(NSArray<T> *)objects;
- (void)setLoading;
- (void)setError:(NSError *)error;
- (void)setState:(OriginateRemoteArrayState)state error:(NSError *)error;

@end
