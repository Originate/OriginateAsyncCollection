//
//  OriginateMutableRemoteArray.m
//  OriginateRemoteArray
//
//  Created by Philip Kluz on 10/03/15.
//  Copyright © 2015 Originate Inc. All rights reserved.
//

#import "OriginateMutableRemoteArray.h"
#import "OriginateRemoteArray+Internal.h"

@interface OriginateMutableRemoteArray ()
{
    NSMutableArray *_objects;
}

#pragma mark - Propertis
@property (nonatomic, strong, readwrite) NSMutableArray *objects;

@end

@implementation OriginateMutableRemoteArray

@dynamic objects;
@dynamic delegate;


#pragma mark - OriginateRemoteArray

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _objects = [NSMutableArray array];
    }
    
    return self;
}

- (NSMutableArray *)objects
{
    return _objects;
}

- (void)setObjects:(NSArray *)objects
{
    [self setState:OriginateRemoteArrayStateIdle error:nil];
    
    if (![_objects isEqualToArray:objects]) {
        [self willChangeValueForKey:NSStringFromSelector(@selector(allObjects))];
        _objects = [objects mutableCopy] ?: [NSMutableArray array];
        [self didChangeValueForKey:NSStringFromSelector(@selector(allObjects))];
    }
    
    if ([self.delegate respondsToSelector:@selector(remoteArrayDidLoad:)]) {
        [self.delegate remoteArrayDidLoad:self];
    }
}

#pragma mark - OriginateMutableRemoteArray

- (void)addObjects:(NSArray *)objects handler:(OriginateMutableRemoteArrayMutationHandler)addHandler
{
    if (!addHandler) {
        return;
    }
    
    [self setLoading];
    
    if ([self.delegate respondsToSelector:@selector(remoteArray:willAddObjects:)]) {
        [self.delegate remoteArray:self willAddObjects:objects];
    }
    
    [self addObjects:objects];
    
    addHandler(^(BOOL success, NSError *error) {
        if (!success) {
            [self revertAdditionOfObjects:objects error:error];
            [self setState:OriginateRemoteArrayStateIdle error:error];
        }
    });
}

- (void)addObjects:(NSArray *)objects
{
    if (!objects) {
        return;
    }
    
    [self setState:OriginateRemoteArrayStateIdle error:nil];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(allObjects))];
    [self.objects addObjectsFromArray:objects];
    [self didChangeValueForKey:NSStringFromSelector(@selector(allObjects))];
    
    if ([self.delegate respondsToSelector:@selector(remoteArray:didAddObjects:)]) {
        [self.delegate remoteArray:self didAddObjects:objects];
    }
}

- (void)revertAdditionOfObjects:(NSArray *)objects error:(NSError *)error
{
    if (!objects) {
        return;
    }
    
    [self setState:OriginateRemoteArrayStateIdle error:nil];
    [self.objects removeObjectsInArray:objects];
    
    if ([self.delegate respondsToSelector:@selector(remoteArray:didRevertAdditionOfObjects:error:)]) {
        [self.delegate remoteArray:self didRevertAdditionOfObjects:objects error:error];
    }
}

- (void)removeObjects:(NSArray *)objects handler:(OriginateMutableRemoteArrayMutationHandler)removeHandler
{
    if (!removeHandler) {
        return;
    }
    
    [self setLoading];
    
    if ([self.delegate respondsToSelector:@selector(remoteArray:willRemoveObjects:)]) {
        [self.delegate remoteArray:self willRemoveObjects:objects];
    }
    
    NSMutableSet *intersectRemove = [NSMutableSet setWithArray:self.objects];
    [intersectRemove intersectSet:[NSSet setWithArray:objects]];
    NSArray *toRemove = [intersectRemove allObjects];
    
    [self removeObjects:toRemove];
    
    removeHandler(^(BOOL success, NSError *error) {
        if (!success) {
            [self revertRemovalOfObjects:toRemove error:error];
            [self setState:OriginateRemoteArrayStateIdle error:error];
        }
    });
}

- (void)removeObjects:(NSArray *)objects
{
    if (!objects) {
        return;
    }
    
    [self setState:OriginateRemoteArrayStateIdle error:nil];
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(allObjects))];
    [self.objects removeObjectsInArray:objects];
    [self didChangeValueForKey:NSStringFromSelector(@selector(allObjects))];
    
    if ([self.delegate respondsToSelector:@selector(remoteArray:didRemoveObjects:)]) {
        [self.delegate remoteArray:self didRemoveObjects:objects];
    }
}

- (void)revertRemovalOfObjects:(NSArray *)objects error:(NSError *)error
{
    if (!objects) {
        return;
    }
    
    [self setState:OriginateRemoteArrayStateIdle error:nil];
    [self.objects addObjectsFromArray:objects];
    
    if ([self.delegate respondsToSelector:@selector(remoteArray:didRevertRemovalOfObjects:error:)]) {
        [self.delegate remoteArray:self didRevertRemovalOfObjects:objects error:error];
    }
}

@end
