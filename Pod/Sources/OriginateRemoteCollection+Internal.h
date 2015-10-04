//
//  OriginateRemoteCollection+Internal.h
//  Pods
//
//  Created by Philip Kluz on 10/3/15.
//
//

@import Foundation;

typedef NS_ENUM(NSUInteger, OriginateRemoteCollectionState) {
    OriginateRemoteCollectionStateNone,
    OriginateRemoteCollectionStateIdle,
    OriginateRemoteCollectionStateLoading
};

@interface OriginateRemoteCollection ()
{
    NSArray *_objects;
}

#pragma mark - Properties
@property (nonatomic, assign, readwrite) OriginateRemoteCollectionState state;
@property (nonatomic, strong, readwrite) NSError *lastError;
@property (nonatomic, strong, readwrite) NSArray *objects;

#pragma mark - Methods
- (void)setObjects:(NSArray *)objects;
- (void)setLoading;
- (void)setError:(NSError *)error;
- (void)setState:(OriginateRemoteCollectionState)state error:(NSError *)error;

@end
