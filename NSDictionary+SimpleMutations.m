#import "NSDictionary+SimpleMutations.h"

@implementation NSDictionary (SimpleMutations)

- (NSDictionary*)dictionaryBySettingValue:(id)value
									forKey:(id)key {
	if (!key) {
		return [NSDictionary dictionaryWithDictionary:self] ;
	}

	NSMutableDictionary* mutant = [self mutableCopy] ;
	[mutant setValue:value
			  forKey:key] ;
	NSDictionary* newDic = [NSDictionary dictionaryWithDictionary:mutant] ;
	[mutant release] ;
	
	return newDic ;
}

- (NSDictionary*)dictionaryByAddingEntriesFromDictionary:(NSDictionary*)otherDic {
	NSMutableDictionary* mutant = [self mutableCopy] ;
	if (otherDic) {
		[mutant addEntriesFromDictionary:otherDic] ;
	}
	NSDictionary* newDic = [NSDictionary dictionaryWithDictionary:mutant] ;
	[mutant release] ;
	
	return newDic ;
}

- (NSDictionary*)dictionaryByAppendingEntriesFromDictionary:(NSDictionary*)otherDic {
	NSMutableDictionary* mutant = [self mutableCopy] ;
	for (id key in otherDic) {
		if ([self objectForKey:key] == nil) {
			[mutant setObject:[otherDic objectForKey:key]
					   forKey:key] ;
		}
	}
	NSDictionary* newDic = [NSDictionary dictionaryWithDictionary:mutant] ;
	[mutant release] ;
	
	return newDic ;
}

+ (void)mutateAdditions:(NSMutableDictionary*)additions
			  deletions:(NSMutableSet*)deletions
		   newAdditions:(NSMutableDictionary*)newAdditions
		   newDeletions:(NSMutableSet*)newDeletions {
	NSSet* immuterator ;
	
	// Remove from newAdditions and newDeletions any members
	// in these new inputs which cancel one another out
	immuterator = [[NSSet alloc] initWithArray:[newAdditions allKeys]] ;
	for (id key in immuterator) {
		id member = [newDeletions member:key] ;
		if (member) {
			[newAdditions removeObjectForKey:key] ;
			[newDeletions removeObject:member] ;
		}
	}
	[immuterator release] ;
	
	// Remove from newAdditions any which cancel out existing deletions,
	// and do the cancellation
	immuterator = [[NSSet alloc] initWithArray:[newAdditions allKeys]] ;
	for (id key in immuterator) {
		id member = [deletions member:key] ;
		if (member) {
			[newAdditions removeObjectForKey:key] ;
			[deletions removeObject:member] ;
		}
	}
	[immuterator release] ;
	// Add surviving new additions to existing additions
	[additions addEntriesFromDictionary:newAdditions] ;
	
	// Remove from newDeletions any which cancel out existing additions,
	// and do the cancellation
	immuterator = [newDeletions copy] ;
	for (id key in immuterator) {
		id object = [additions objectForKey:key] ;
		if (object) {
			[newDeletions removeObject:key] ;
			[additions removeObjectForKey:key] ;
		}
	}
	[immuterator release] ;
	// Add surviving new deletions to existing deletions
	[deletions unionSet:newDeletions] ;
}

@end
