//
//  OriginateRemoteArray.m
//  OriginateRemoteArray
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 Originate Inc. All rights reserved.
//

#import "OriginateRemoteArray.h"
#import "OriginateRemoteArray+Internal.h"

@implementation OriginateRemoteArray

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _state = OriginateRemoteArrayStateNone;
    }
    
    return self;
}


#pragma mark - OriginateRemoteArray

- (void)load:(OriginateRemoteArrayLoadHandler)loadHandler
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

- (void)objectsWillUpdate
{
    // intended to be overriden by subclass
}


#pragma mark - OriginateRemoteArray (Transitions)

- (void)setObjects:(NSArray *)objects
{
    [self setState:OriginateRemoteArrayStateIdle error:nil];
    [self objectsWillUpdate];
    
    if (![_objects isEqualToArray:objects]) {
        _objects = objects ?: @[];
    }
    
    if ([self.delegate respondsToSelector:@selector(remoteArrayDidLoad:)]) {
        [self.delegate remoteArrayDidLoad:self];
    }
}

- (void)setLoading
{
    switch (self.state) {
        case OriginateRemoteArrayStateNone:
        case OriginateRemoteArrayStateIdle:
        {
            [self setState:OriginateRemoteArrayStateLoading error:nil];
            
            if ([self.delegate respondsToSelector:@selector(remoteArrayWillLoad:)]) {
                [self.delegate remoteArrayWillLoad:self];
            }
            
            break;
        }
        case OriginateRemoteArrayStateLoading:
        {
            NSLog(@"OriginateRemoteArray <WARNING> setLoading: Already (re)loading.");
            break;
        }
    }
}

- (void)setError:(NSError *)error
{
    [self setState:OriginateRemoteArrayStateIdle error:error];
    
    if ([self.delegate respondsToSelector:@selector(remoteArray:didFailWithError:)]) {
        [self.delegate remoteArray:self didFailWithError:error];
    }
}


#pragma mark - OriginateRemoteArray (States)

- (BOOL)isLoading
{
    return self.state == OriginateRemoteArrayStateLoading && [_objects count] == 0;
}

- (BOOL)isReloading
{
    return self.state == OriginateRemoteArrayStateLoading && _objects;
}

- (BOOL)isEmpty
{
    return self.state == OriginateRemoteArrayStateIdle &&
           self.lastError == nil &&
           [self count] == 0;
}

- (void)setState:(OriginateRemoteArrayState)state error:(NSError *)error
{
    _state = state;
    _lastError = error;
}

@end
