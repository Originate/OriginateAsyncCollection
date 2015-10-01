//
//  OriginateAsyncCollection.h
//  OriginateAsyncCollection-Example
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

@import Foundation;

@protocol OriginateAsyncCollectionDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface OriginateAsyncCollection<__covariant T> : NSObject

#pragma mark - Properties
@property (nonatomic, strong, readwrite) NSArray<T> *elements;
@property (nonatomic, weak, readwrite) id<OriginateAsyncCollectionDelegate> delegate;

#pragma mark - Methods
/*
 Will transitions async collection into LOADED state.
 */
- (void)setElements:(NSArray<T> *)elements;

/*
 Will transition async collection into LOADING state IF it was NONE.
 Will transition async collection into RELOADING state otherwise.
 */
- (void)setLoading;

/*
 Will transition async collection into LOADING FAILED state IF it was LOADING.
 Will transition async collection into RELOADING FAILED state otherwise.
 */
- (void)setError:(NSError *)error;

- (BOOL)isEmpty;
- (BOOL)isLoading;
- (BOOL)isReloading;

- (T)elementAtIndex:(NSUInteger)index;
- (void)removeElementAtIndex:(NSUInteger)index;

@end

@protocol OriginateAsyncCollectionDelegate <NSObject>

@optional
- (void)asyncCollectionWillLoad:(OriginateAsyncCollection *)collection;
- (void)asyncCollectionDidLoad:(OriginateAsyncCollection *)collection;

- (void)asyncCollectionWillReload:(OriginateAsyncCollection *)collection;
- (void)asyncCollectionDidReload:(OriginateAsyncCollection *)collection;

- (void)asyncCollection:(OriginateAsyncCollection *)collection didFailLoadingWithError:(NSError *)error;
- (void)asyncCollection:(OriginateAsyncCollection *)collection didFailReloadingWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
