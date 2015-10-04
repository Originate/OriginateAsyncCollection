//
//  OriginateRemoteCollection.m
//  OriginateRemoteCollection-Example
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "OriginateRemoteCollection.h"
#import "OriginateRemoteCollection+Internal.h"

@implementation OriginateRemoteCollection


#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _state = OriginateRemoteCollectionStateNone;
    }
    
    return self;
}


#pragma mark - OriginateRemoteCollection

- (void)load:(OriginateRemoteCollectionLoadHandler)loadHandler
{
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


#pragma mark - OriginateRemoteCollection (Transitions)

- (void)setObjects:(NSArray *)objects
{
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    
    if (![_objects isEqualToArray:objects]) {
        _objects = objects ?: @[];
    }
    
    if ([self.delegate respondsToSelector:@selector(remoteCollectionDidLoad:)]) {
        [self.delegate remoteCollectionDidLoad:self];
    }
}

- (void)setLoading
{
    switch (self.state) {
        case OriginateRemoteCollectionStateNone:
        case OriginateRemoteCollectionStateIdle:
        {
            [self setState:OriginateRemoteCollectionStateLoading error:nil];
            
            if ([self.delegate respondsToSelector:@selector(remoteCollectionWillLoad:)]) {
                [self.delegate remoteCollectionWillLoad:self];
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
    
    if ([self.delegate respondsToSelector:@selector(remoteCollection:failedWithError:)]) {
        [self.delegate remoteCollection:self failedWithError:error];
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
