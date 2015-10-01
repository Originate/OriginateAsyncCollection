//
//  OriginateAsyncCollection.m
//  OriginateAsyncCollection-Example
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "OriginateAsyncCollection.h"
#import <libkern/OSAtomic.h>

typedef NS_ENUM(NSUInteger, OriginateAsyncCollectionState) {
  OriginateAsyncCollectionStateIdle,
  OriginateAsyncCollectionStateLoading,
  OriginateAsyncCollectionStateLoaded,
  OriginateAsyncCollectionStateLoadingFailed,
  OriginateAsyncCollectionStateReloading,
  OriginateAsyncCollectionStateReloadingFailed
};

@interface OriginateAsyncCollection ()
{
  NSArray *_elements;
  OSSpinLock _spinlock;
}

#pragma mark - Properties
@property (nonatomic, assign, readwrite) OriginateAsyncCollectionState state;

@end

@implementation OriginateAsyncCollection

- (instancetype)init
{
  self = [super init];
  
  if (self) {
    _spinlock = OS_SPINLOCK_INIT;
  }
  
  return self;
}

- (void)setElements:(NSArray *)elements
{
  OSSpinLockLock(&_spinlock);
  
  if (elements) {
    _elements = elements;
    self.state = OriginateAsyncCollectionStateLoaded;
    
    // Allow transition to LOADED state from all other states.
    if ([self.delegate respondsToSelector:@selector(asyncCollectionDidLoad:)]) {
      [self.delegate asyncCollectionDidLoad:self];
    }
  }
  else {
    NSLog(@"OriginateAsyncCollection <WARNING> setElements: called with nil value. Pass @[] (empty array) instead. Failing gracefully.");
  }
  
  OSSpinLockUnlock(&_spinlock);
}

- (NSArray *)elements
{
  if (!_elements) {
    _elements = @[];
  }
  
  return _elements;
}

- (id)elementAtIndex:(NSUInteger)index
{
  if (index >= self.elements.count) {
    return nil;
  }
  
  return [self.elements objectAtIndex:index];
}

- (void)removeElementAtIndex:(NSUInteger)index
{
  OSSpinLockLock(&_spinlock);
  
  if (index < self.elements.count) {
    if ([self.delegate respondsToSelector:@selector(asyncCollectionWillReload:)]) {
      [self.delegate asyncCollectionWillReload:self];
    }
    
    NSMutableArray *mutableElements = [self.elements mutableCopy];
    [mutableElements removeObjectAtIndex:index];
    _elements = [mutableElements copy];
    
    if ([self.delegate respondsToSelector:@selector(asyncCollectionDidReload:)]) {
      [self.delegate asyncCollectionDidReload:self];
    }
  }
  
  OSSpinLockUnlock(&_spinlock);
}

- (void)setLoading
{
  OSSpinLockLock(&_spinlock);
  
  switch (self.state) {
    case OriginateAsyncCollectionStateIdle:
    case OriginateAsyncCollectionStateLoadingFailed:
    {
      self.state = OriginateAsyncCollectionStateLoading;
      
      if ([self.delegate respondsToSelector:@selector(asyncCollectionWillLoad:)]) {
        [self.delegate asyncCollectionWillLoad:self];
      }
      
      break;
    }
    case OriginateAsyncCollectionStateLoaded:
    {
      if (self.elements.count == 0) {
        self.state = OriginateAsyncCollectionStateLoading;
        if ([self.delegate respondsToSelector:@selector(asyncCollectionWillLoad:)]) {
          [self.delegate asyncCollectionWillLoad:self];
        }
      }
      else {
        self.state = OriginateAsyncCollectionStateReloading;
        if ([self.delegate respondsToSelector:@selector(asyncCollectionWillReload:)]) {
          [self.delegate asyncCollectionWillReload:self];
        }
      }
      break;
    }
    case OriginateAsyncCollectionStateReloadingFailed:
    {
      self.state = OriginateAsyncCollectionStateReloading;
      
      if ([self.delegate respondsToSelector:@selector(asyncCollectionWillReload:)]) {
        [self.delegate asyncCollectionWillReload:self];
      }
      
      break;
    }
    case OriginateAsyncCollectionStateReloading:
    case OriginateAsyncCollectionStateLoading:
    {
      NSLog(@"OriginateAsyncCollection <WARNING> setLoading: Already (re)loading.");
      break;
    }
  }
  
  OSSpinLockUnlock(&_spinlock);
}

- (void)setError:(NSError *)error
{
  OSSpinLockLock(&_spinlock);
  
  if (error) {
    switch (self.state) {
      case OriginateAsyncCollectionStateLoading:
      case OriginateAsyncCollectionStateIdle:
      {
        self.state = OriginateAsyncCollectionStateLoadingFailed;
        if ([self.delegate respondsToSelector:@selector(asyncCollection:didFailLoadingWithError:)]) {
          [self.delegate asyncCollection:self didFailLoadingWithError:error];
        }
        break;
      }
        
      case OriginateAsyncCollectionStateReloading:
      {
        self.state = OriginateAsyncCollectionStateReloadingFailed;
        if ([self.delegate respondsToSelector:@selector(asyncCollection:didFailReloadingWithError:)]) {
          [self.delegate asyncCollection:self didFailReloadingWithError:error];
        }
      }
      case OriginateAsyncCollectionStateLoaded:
      {
        NSLog(@"OriginateAsyncCollection <ERROR> setError: called on loaded collection.");
        break;
      }
      case OriginateAsyncCollectionStateLoadingFailed:
      case OriginateAsyncCollectionStateReloadingFailed:
      {
        NSLog(@"OriginateAsyncCollection <WARNING> setError: Already in failed state. Not failing again.");
      }
    }
  }
  else {
    NSLog(@"OriginateAsyncCollection <ERROR> setError: called with nil value. Failing gracefully.");
  }
  
  OSSpinLockUnlock(&_spinlock);
}

- (BOOL)isReloading
{
  return self.state == OriginateAsyncCollectionStateReloading;
}

- (BOOL)isLoading
{
  return self.state == OriginateAsyncCollectionStateLoading;
}

- (BOOL)isEmpty
{
  return (self.state == OriginateAsyncCollectionStateLoaded ||
          self.state == OriginateAsyncCollectionStateReloading ||
          self.state == OriginateAsyncCollectionStateReloadingFailed) &&
  self.elements.count == 0;
}

@end
