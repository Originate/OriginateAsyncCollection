//
//  OriginateRemoteCollection.m
//  OriginateRemoteCollection
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 Originate Inc. All rights reserved.
//

#import "OriginateRemoteCollection.h"
#import "OriginateRemoteCollection+Internal.h"

@interface OriginateRemoteCollection()
{
    NSHashTable<id<OriginateRemoteCollectionDelegate>> *_delegates;
}

#pragma mark - Propertis
@property (nonatomic, strong, readwrite) NSHashTable<id<OriginateRemoteCollectionDelegate>> *delegates;

@end

@implementation OriginateRemoteCollection

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _state = OriginateRemoteCollectionStateNone;
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}


#pragma mark - OriginateRemoteCollection

- (void)load:(OriginateRemoteCollectionLoadHandler)loadHandler
{
    if (!loadHandler) {
        return;
    }
    
    [self setLoading];
    
    loadHandler(^(NSArray *result, NSError *error) {
        if (!error) {
            [self setObjects:result];
        }
        else {
            [self setError:error];
        }
    });
}

- (void)loadFromArray:(NSArray *)array
{
    [self setObjects:array];
}

- (id)objectAtIndex:(NSUInteger)index
{
    if (index >= self.objects.count) {
        return nil;
    }
    
    return [self.objects objectAtIndex:index];
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

- (NSUInteger)indexOfObject:(id)object
{
    return [self.objects indexOfObject:object];
}

- (NSUInteger)count
{
    return self.objects.count;
}

- (NSArray *)allObjects
{
    return self.objects;
}

- (void)addDelegate:(id<OriginateRemoteCollectionDelegate>)delegate
{
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<OriginateRemoteCollectionDelegate>)delegate
{
    if ([_delegates member:delegate]) {
        [_delegates removeObject: delegate];
    }
}


#pragma mark - OriginateRemoteCollection (Transitions)

- (void)setObjects:(NSArray *)objects
{
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    
    if (![_objects isEqualToArray:objects]) {
        _objects = objects ?: @[];
    }
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollectionDidLoad:)]) {
            [delegate remoteCollectionDidLoad:self];
        }
    }
}

- (void)setLoading
{
    switch (self.state) {
        case OriginateRemoteCollectionStateNone:
        case OriginateRemoteCollectionStateIdle:
        {
            [self setState:OriginateRemoteCollectionStateLoading error:nil];
            
            for (id delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(remoteCollectionWillLoad:)]) {
                    [delegate remoteCollectionWillLoad:self];
                }
            }
            
            break;
        }
        case OriginateRemoteCollectionStateLoading:
        {
            NSLog(@"OriginateRemoteCollection <WARNING> setLoading: Already (re)loading.");
            break;
        }
    }
}

- (void)setError:(NSError *)error
{
    [self setState:OriginateRemoteCollectionStateIdle error:error];
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollection:didFailWithError:)]) {
            [delegate remoteCollection:self didFailWithError:error];
        }
    }
}


#pragma mark - OriginateRemoteCollection (States)

- (BOOL)isLoading
{
    return self.state == OriginateRemoteCollectionStateLoading && [_objects count] == 0;
}

- (BOOL)isReloading
{
    return self.state == OriginateRemoteCollectionStateLoading && _objects;
}

- (BOOL)isEmpty
{
    return self.state == OriginateRemoteCollectionStateIdle &&
           self.lastError == nil &&
           [self count] == 0;
}

- (void)setState:(OriginateRemoteCollectionState)state error:(NSError *)error
{
    _state = state;
    _lastError = error;
}

@end
