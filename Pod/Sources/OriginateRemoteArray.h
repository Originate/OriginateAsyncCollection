//
//  OriginateRemoteArray.h
//  OriginateRemoteArray
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 Originate Inc. All rights reserved.
//

@import Foundation;

@protocol OriginateRemoteArrayDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef void(^OriginateRemoteArrayLoadCompletion)(NSArray *result, NSError *error);
typedef void(^OriginateRemoteArrayLoadHandler)(OriginateRemoteArrayLoadCompletion);

@interface OriginateRemoteArray<__covariant T> : NSObject

#pragma mark - Properties
@property (nonatomic, weak, readwrite) id<OriginateRemoteArrayDelegate> delegate;
@property (nonatomic, copy, readonly) NSArray *allObjects;

#pragma mark - Methods
- (void)load:(OriginateRemoteArrayLoadHandler)loadHandler;
- (void)loadFromArray:(NSArray<T> *)array;

- (NSUInteger)count;
- (T)objectAtIndex:(NSUInteger)index;
- (T)objectAtIndexedSubscript:(NSUInteger)index;
- (NSUInteger)indexOfObject:(T)object;

@end

@interface OriginateRemoteArray<__covariant T> (States)

#pragma mark - Methods
- (BOOL)isEmpty;
- (BOOL)isLoading;
- (NSError *)lastError;

@end

@protocol OriginateRemoteArrayDelegate <NSObject>

@optional
- (void)remoteArrayWillLoad:(OriginateRemoteArray *)array;
- (void)remoteArrayDidLoad:(OriginateRemoteArray *)array;
- (void)remoteArray:(OriginateRemoteArray *)array didFailWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
