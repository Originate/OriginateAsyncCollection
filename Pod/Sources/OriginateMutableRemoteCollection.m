//
//  OriginateMutableRemoteCollection.m
//  OriginateRemoteCollection-Example
//
//  Created by Philip Kluz on 10/03/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "OriginateMutableRemoteCollection.h"
#import "OriginateRemoteCollection+Internal.h"

@interface OriginateMutableRemoteCollection ()
{
    NSMutableArray *_objects;
}

@property (nonatomic, strong, readwrite) NSMutableArray *objects;

@end

@implementation OriginateMutableRemoteCollection

@dynamic objects;
@dynamic delegate;


#pragma mark - OriginateRemoteCollection

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

- (void)setObjects:(NSMutableArray *)objects
{
    [super setObjects:objects];
}

- (NSMutableArray *)allObjects
{
    return self.objects;
}


#pragma mark - OriginateMutableRemoteCollection

- (void)addObjects:(NSArray *)objects handler:(OriginateMutableRemoteCollectionMutationHandler)addHandler
{
    [self setLoading];
    
    if ([self.delegate respondsToSelector:@selector(remoteCollection:willAddObjects:)]) {
        [self.delegate remoteCollection:self willAddObjects:objects];
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
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    [self.objects addObjectsFromArray:objects];
    
    if ([self.delegate respondsToSelector:@selector(remoteCollection:didAddObjects:)]) {
        [self.delegate remoteCollection:self didAddObjects:objects];
    }
}

- (void)revertAdditionOfObjects:(NSArray *)objects error:(NSError *)error
{
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    [self.objects removeObjectsInArray:objects];
    
    if ([self.delegate respondsToSelector:@selector(remoteCollection:didRevertAdditionOfObjects:error:)]) {
        [self.delegate remoteCollection:self didRevertAdditionOfObjects:objects error:error];
    }
}

- (void)removeObjects:(NSArray *)objects handler:(OriginateMutableRemoteCollectionMutationHandler)removeHandler
{
    [self setLoading];
    
    if ([self.delegate respondsToSelector:@selector(remoteCollection:willRemoveObjects:)]) {
        [self.delegate remoteCollection:self willRemoveObjects:objects];
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
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    [self.objects removeObjectsInArray:objects];
    
    if ([self.delegate respondsToSelector:@selector(remoteCollection:didRemoveObjects:)]) {
        [self.delegate remoteCollection:self didRemoveObjects:objects];
    }
}

- (void)revertRemovalOfObjects:(NSArray *)objects error:(NSError *)error
{
    [self setState:OriginateRemoteCollectionStateIdle error:nil];
    [self.objects addObjectsFromArray:objects];
    
    if ([self.delegate respondsToSelector:@selector(remoteCollection:didRevertRemovalOfObjects:error:)]) {
        [self.delegate remoteCollection:self didRevertRemovalOfObjects:objects error:error];
    }
}

@end
