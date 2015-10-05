//
//  OriginateMutableRemoteCollection.m
//  OriginateRemoteCollection
//
//  Created by Philip Kluz on 10/03/15.
//  Copyright © 2015 Originate Inc. All rights reserved.
//

#import "OriginateMutableRemoteCollection.h"
#import "OriginateRemoteCollection+Internal.h"

@interface OriginateMutableRemoteCollection ()
{
    NSMutableArray *_objects;
    NSHashTable<id<OriginateMutableRemoteCollectionDelegate>> *_delegates;
}

#pragma mark - Propertis
@property (nonatomic, strong, readwrite) NSHashTable<id<OriginateMutableRemoteCollectionDelegate>> *delegates;
@property (nonatomic, strong, readwrite) NSMutableArray *objects;

@end

@implementation OriginateMutableRemoteCollection

@dynamic objects;


#pragma mark - OriginateRemoteCollection

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _objects = [NSMutableArray array];
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}

- (NSMutableArray *)objects
{
    return _objects;
}

- (void)setObjects:(NSArray *)objects
{
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    
    if (![_objects isEqualToArray:objects]) {
        _objects = [objects mutableCopy] ?: [NSMutableArray array];
    }
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollectionDidLoad:)]) {
            [delegate remoteCollectionDidLoad:self];
        }
    }
}

#pragma mark - OriginateMutableRemoteCollection

- (void)addObjects:(NSArray *)objects handler:(OriginateMutableRemoteCollectionMutationHandler)addHandler
{
    if (!addHandler) {
        return;
    }
    
    [self setLoading];
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollection:willAddObjects:)]) {
            [delegate remoteCollection:self willAddObjects:objects];
        }
    }
    
    [self addObjects:objects];
    
    addHandler(^(BOOL success, NSError *error) {
        if (!success) {
            [self revertAdditionOfObjects:objects error:error];
            [self setState:OriginateRemoteCollectionStateIdle error:error];
        }
    });
}

- (void)addObjects:(NSArray *)objects
{
    if (!objects) {
        return;
    }
    
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    [self.objects addObjectsFromArray:objects];
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollection:didAddObjects:)]) {
            [delegate remoteCollection:self didAddObjects:objects];
        }
    }
}

- (void)revertAdditionOfObjects:(NSArray *)objects error:(NSError *)error
{
    if (!objects) {
        return;
    }
    
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    [self.objects removeObjectsInArray:objects];
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollection:didRevertAdditionOfObjects:error:)]) {
            [delegate remoteCollection:self didRevertAdditionOfObjects:objects error:error];
        }
    }
}

- (void)removeObjects:(NSArray *)objects handler:(OriginateMutableRemoteCollectionMutationHandler)removeHandler
{
    if (!removeHandler) {
        return;
    }
    
    [self setLoading];
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollection:willRemoveObjects:)]) {
            [delegate remoteCollection:self willRemoveObjects:objects];
        }
    }
    
    NSMutableSet *intersectRemove = [NSMutableSet setWithArray:self.objects];
    [intersectRemove intersectSet:[NSSet setWithArray:objects]];
    NSArray *toRemove = [intersectRemove allObjects];
    
    [self removeObjects:toRemove];
    
    removeHandler(^(BOOL success, NSError *error) {
        if (!success) {
            [self revertRemovalOfObjects:toRemove error:error];
            [self setState:OriginateRemoteCollectionStateIdle error:error];
        }
    });
}

- (void)removeObjects:(NSArray *)objects
{
    if (!objects) {
        return;
    }
    
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    [self.objects removeObjectsInArray:objects];
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollection:didRemoveObjects:)]) {
            [delegate remoteCollection:self didRemoveObjects:objects];
        }
    }
}

- (void)revertRemovalOfObjects:(NSArray *)objects error:(NSError *)error
{
    if (!objects) {
        return;
    }
    
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    [self.objects addObjectsFromArray:objects];
    
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(remoteCollection:didRevertRemovalOfObjects:error:)]) {
            [delegate remoteCollection:self didRevertRemovalOfObjects:objects error:error];
        }
    }
}

- (void)addDelegate:(id<OriginateMutableRemoteCollectionDelegate>)delegate
{
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<OriginateMutableRemoteCollectionDelegate>)delegate
{
    if ([_delegates member:delegate]) {
        [_delegates removeObject:delegate];
    }
}

@end
