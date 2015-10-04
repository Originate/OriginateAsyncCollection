//
//  OriginateRemoteCollection.h
//  OriginateRemoteCollection-Example
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

@import Foundation;

@protocol OriginateRemoteCollectionDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef void(^OriginateRemoteCollectionLoadCompletion)(NSArray *result, NSError *error);
typedef void(^OriginateRemoteCollectionLoadHandler)(OriginateRemoteCollectionLoadCompletion);

@interface OriginateRemoteCollection<__covariant T> : NSObject

#pragma mark - Properties
@property (nonatomic, weak, readwrite) id<OriginateRemoteCollectionDelegate> delegate;

#pragma mark - Methods
- (void)load:(OriginateRemoteCollectionLoadHandler)loadHandler;
- (void)loadFromArray:(NSArray *)array;

- (NSUInteger)count;
- (T)objectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfObject:(T)object;
- (NSArray *)allObjects;

@end

@interface OriginateRemoteCollection<__covariant T> (States)

#pragma mark - Methods
- (BOOL)isEmpty;
- (BOOL)isLoading;
- (NSError *)lastError;

@end

@protocol OriginateRemoteCollectionDelegate <NSObject>

@optional
- (void)remoteCollectionWillLoad:(OriginateRemoteCollection *)collection;
- (void)remoteCollectionDidLoad:(OriginateRemoteCollection *)collection;
- (void)remoteCollection:(OriginateRemoteCollection *)collection failedWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
