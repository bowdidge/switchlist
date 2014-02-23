// 
//  FreightCar.m
//  SwitchList
//
//  Created by Robert Bowdidge on 6/9/06.
//
// Copyright (c)2006 Robert Bowdidge,
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.

#import "Cargo.h"
#import "CarType.h"
#import "FreightCar.h"
#import "ScheduledTrain.h"
#import "Industry.h"

#import <Foundation/Foundation.h>

NSInteger compareReportingMarksAlphabetically(FreightCar* s1, FreightCar* s2, void *context) {
	NSArray *marksComponents1 = [[s1 reportingMarks] componentsSeparatedByString: @" "];
	NSArray *marksComponents2 = [[s2 reportingMarks] componentsSeparatedByString: @" "];
	if (([marksComponents1 count] != 2) || ([marksComponents2 count] != 2)) {
		return [[s1 reportingMarks] compare: [s2 reportingMarks]];
	}
	int nameComp = [[marksComponents1 objectAtIndex: 0] compare: [marksComponents2 objectAtIndex: 0]];
	if (nameComp != NSOrderedSame) {
		return nameComp;
	}
	
	NSString *carNumberString1 = [marksComponents1 objectAtIndex: 1];
	NSString *carNumberString2 = [marksComponents2 objectAtIndex: 1];
	int carNumber1 = [carNumberString1 intValue];
	int carNumber2 = [carNumberString2 intValue];
	
	if ((carNumber1 != 0) && (carNumber2 != 0) &&
		(carNumber1 != carNumber2)) {
		return carNumber1 - carNumber2;
	}
	
	return [carNumberString1 compare: carNumberString2];
}

@implementation FreightCar 

- (BOOL) isLoaded {
	return [[self loaded] boolValue];
}

- (void) setIsLoaded: (BOOL) val {
	[self setLoaded: [NSNumber numberWithBool: val]];
}

- (NSNumber *)loaded 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"loaded"];
    tmpValue = [self primitiveValueForKey: @"loaded"];
    [self didAccessValueForKey: @"loaded"];
    
    return tmpValue;
}

// Clear the marking of which train this is assigned to.
- (void) removeFromTrain {
	[self setCurrentTrain: nil];
	[self setIntermediateDestination: nil];
}

- (void)setLoaded:(NSNumber *)value 
{
    [self willChangeValueForKey: @"loaded"];
    [self setPrimitiveValue: value forKey: @"loaded"];
    [self didChangeValueForKey: @"loaded"];
}

- (NSString *)homeDivision 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"homeDivision"];
    tmpValue = [self primitiveValueForKey: @"homeDivision"];
    [self didAccessValueForKey: @"homeDivision"];

    return NormalizeDivisionString(tmpValue);
}

- (void)setHomeDivision:(NSString *)value 
{
    [self willChangeValueForKey: @"homeDivision"];
    [self setPrimitiveValue: value forKey: @"homeDivision"];
    [self didChangeValueForKey: @"homeDivision"];
}

- (NSString *)reportingMarks 
{
    NSString * tmpValue;
    
    [self willAccessValueForKey: @"reportingMarks"];
    tmpValue = [self primitiveValueForKey: @"reportingMarks"];
    [self didAccessValueForKey: @"reportingMarks"];
    
    return tmpValue;
}

- (NSString*) initials {
	NSString *myReportingMarks = [[self reportingMarks] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *components = [myReportingMarks componentsSeparatedByString: @" "];
	return [components objectAtIndex: 0];
}

// Returns the number portion of the reporting marks, or the portion after the first sequence of spaces
// found in the reporting marks.
- (NSString*) number {
	NSString *myReportingMarks = [[self reportingMarks] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	const char *reportingMarksStr = [myReportingMarks UTF8String];
	char *firstNonSpace = strstr(reportingMarksStr, " ");
	
	// No space?  No number.
	if (firstNonSpace == NULL) return @"";
	
	while (*firstNonSpace == ' ') firstNonSpace++;
	return [NSString stringWithUTF8String: firstNonSpace];
}

// Helper to make template language more consistent.
- (NSString*) carType {
	return [[self carTypeRel] carTypeName];
}

- (void)setReportingMarks:(NSString *)value 
{
    [self willChangeValueForKey: @"reportingMarks"];
    [self setPrimitiveValue: value forKey: @"reportingMarks"];
    [self didChangeValueForKey: @"reportingMarks"];
}

- (NSNumber *)doorToSpot {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"doorToSpot"];
    tmpValue = [self primitiveValueForKey: @"doorToSpot"];
    [self didAccessValueForKey: @"doorToSpot"];
    return tmpValue;
}

- (void)setDoorToSpot:(NSNumber *)value {
    [self willChangeValueForKey: @"doorToSpot"];
    [self setPrimitiveValue: value forKey: @"doorToSpot"];
    [self didChangeValueForKey: @"doorToSpot"];
}

- (NSNumber *)currentDoor {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"currentDoor"];
    tmpValue = [self primitiveValueForKey: @"currentDoor"];
    [self didAccessValueForKey: @"currentDoor"];
    
    return tmpValue;
}

- (void)setCurrentDoor:(NSNumber *)value {
    [self willChangeValueForKey: @"currentDoor"];
    [self setPrimitiveValue: value forKey: @"currentDoor"];
    [self didChangeValueForKey: @"currentDoor"];
}

// Unused.
- (unsigned)positionInTrain {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"positionInTrain"];
    tmpValue = [self primitiveValueForKey: @"positionInTrain"];
    [self didAccessValueForKey: @"positionInTrain"];
    
    return [tmpValue intValue];
}

- (void)setPositionInTrain:(unsigned)value {
    [self willChangeValueForKey: @"positionInTrain"];
    [self setPrimitiveValue: [NSNumber numberWithInt: value] forKey: @"positionInTrain"];
    [self didChangeValueForKey: @"positionInTrain"];
}

@dynamic carTypeRel;
@dynamic daysUntilUnloaded;

// These two functions are provided free by CoreData,
// and by not implementing them, we don't need to worry about getting
// the reverse stuff correct.
// - (CarType *)carTypeRel 
// - (void)setCarTypeRel:(CarType *)value 

- (NSNumber *)length 
{
    [self willAccessValueForKey: @"length"];
    NSNumber* tmpValue = [self primitiveValueForKey: @"length"];
    [self didAccessValueForKey: @"length"];
    
    return tmpValue;
}

- (void)setLength:(NSNumber *)value {
    [self willChangeValueForKey: @"length"];
    [self setPrimitiveValue: value forKey: @"length"];
    [self didChangeValueForKey: @"length"];
}

- (InduYard *)currentLocation
{
    id tmpObject;
    
    [self willAccessValueForKey: @"currentLocation"];
    tmpObject = [self primitiveValueForKey: @"currentLocation"];
    [self didAccessValueForKey: @"currentLocation"];
    
    return tmpObject;
}

- (void)setCurrentLocation:(Industry *)value 
{
    [self willChangeValueForKey: @"currentLocation"];
	if ([[value location] isOffline] == YES) {
		printf("Trying to set current loc for %s to offline industry!\n",[[self reportingMarks] UTF8String]);
	}
    [self setPrimitiveValue: value
                     forKey: @"currentLocation"];
    [self didChangeValueForKey: @"currentLocation"];
}

- (Place *) currentTown {
	return [[self currentLocation] location];
}

- (InduYard*) nextIndustry {
	// Is this car whereit's supposed to be?
	// There's three definitions for "arrived". 
	// 1: car is loaded and car has cargo and the current location is the cargo's destination
	// 2: car is empty and car has cargo and current location is car's source
	// 3: car doesn't have cargo and current yard's division contains car's division.

	BOOL isLoaded = [self isLoaded];
	NSManagedObject *cargo = [self valueForKey: @"cargo"];
	if (cargo == nil) {
		return nil;
	}
	
	id cargoDest = [cargo valueForKey: @"destination"];	
	id cargoSrc = [cargo valueForKey: @"source"];	
	
	if (isLoaded == YES) {
		return cargoDest;
	} else {
		return cargoSrc;
	}
	return nil;
}

// Returns name of division of next destination.
- (NSString*) nextDivision {
	InduYard *nextIndustry = [self nextIndustry];
	if (nextIndustry) {
		return [nextIndustry division];
	}
	return [self homeDivision];
}


// Returns either the next intermediate stop or final stop.
// If the car has no cargo, then the intermediate destination should have
// been set to final yard.
- (InduYard*) nextStop {
	InduYard *nextIntermediateStop = [self intermediateDestination];
	if (nextIntermediateStop != nil) return nextIntermediateStop;
	return [self nextIndustry];
}

- (BOOL) hasCargo {
  return ([self valueForKey: @"cargo"] != nil);
}

// Returns nil if no cargo defined.
- (Place*) nextTown {
	return [[self nextIndustry] location];
}

- (BOOL) atDestinationTown {
	Place* destTown = [self nextTown];
	Place *currentTown = [self currentTown];
	
	if ((destTown == nil) || (currentTown == nil)) return NO;
	
	if (destTown == currentTown) {
		return YES;
	}
	return NO;
}

- (BOOL) inStaging {
	BOOL carLocIsStaging = [[self valueForKeyPath: @"currentLocation.location.isStaging"] boolValue];
	if (carLocIsStaging == YES) {
		return YES;
	}
	return NO;
}

// Always false if car has no cargo.
- (BOOL) atDestinationIndustry {
	// Is this car whereit's supposed to be?
	// There's three definitions for "arrived". 
	// 1: car is loaded and car has cargo and the current location is the cargo's destination
	// 2: car is empty and car has cargo and current location is car's source

	if ([self cargo] == nil) {
		return NO;
	}

	InduYard *destInd = [self nextIndustry];
	
	BOOL isLoaded = [self isLoaded];
	
	BOOL carLocIsStaging = [[self currentLocation] isStaging];
	BOOL cargoDestIsOffline = [[[self cargo] destination] isStaging];
	BOOL cargoSourceIsOffline = [[[self cargo] source] isOffline];
	
	if ([self currentLocation] == destInd) {
		return YES;
	}

	if ((isLoaded == NO) && (cargoSourceIsOffline) && (carLocIsStaging == YES)) {
		return YES;
	}
	
	if ((isLoaded == YES) && (cargoDestIsOffline) && (carLocIsStaging == YES)) {
		// if the car is in an offstage location and the target industry is in an offstage location
		// and the current offstage location 
		// FIXME: are we in an appropriate staging yard?
		return YES;
	}

	return NO;
}

- (Cargo *)cargo 
{
    id tmpObject;
    
    [self willAccessValueForKey: @"cargo"];
    tmpObject = [self primitiveValueForKey: @"cargo"];
    [self didAccessValueForKey: @"cargo"];
    
    return tmpObject;
}

- (void)setCargo:(Cargo *)value 
{
    [self willChangeValueForKey: @"cargo"];
    [self setPrimitiveValue: value
                     forKey: @"cargo"];
    [self didChangeValueForKey: @"cargo"];
}

- (NSString*) cargoDescription {
	if ([self cargo] == nil) return @"empty";
	if ([self isLoaded] == NO) {
		return @"empty";
	}
	return [[self cargo] cargoDescription];
}

- (NSString*) description {
	NSString *carString = [self reportingMarks];
	BOOL loaded = [self isLoaded];
	NSString *nextIndString=NULL;
	InduYard* nextInd=NULL;
	NSString *contents=NULL;
	NSString *currentStation = [[self currentTown] name];
					
	if ([self cargo] == nil) {
		nextIndString = @"";
		contents = @"empty";
	} else {
		nextInd = (loaded ? [[self cargo] destination]
									: [[self cargo] source]);
		nextIndString =[nextInd name];
	}
	return [NSString stringWithFormat: @"<FreightCar: %@ (%@) at %@ destined for %@, loaded=%d (%@), home division=%@>",
				carString, [[self carTypeRel] carTypeName], currentStation, nextIndString, [self isLoaded], contents, [self homeDivision]];
}

- (ScheduledTrain *)currentTrain 
{
    id tmpObject;
    
    [self willAccessValueForKey: @"currentTrain"];
    tmpObject = [self primitiveValueForKey: @"currentTrain"];
    [self didAccessValueForKey: @"currentTrain"];
    
    return tmpObject;
}

- (void)setCurrentTrain:(ScheduledTrain *)value 
{
    [self willChangeValueForKey: @"currentTrain"];
    [self setPrimitiveValue: value
                     forKey: @"currentTrain"];
    [self didChangeValueForKey: @"currentTrain"];
}

- (InduYard *)intermediateDestination 
{
    id tmpObject;
    
    [self willAccessValueForKey: @"intermediateDestination"];
    tmpObject = [self primitiveValueForKey: @"intermediateDestination"];
    [self didAccessValueForKey: @"intermediateDestination"];
    
    return tmpObject;
}

- (void)setIntermediateDestination:(InduYard *)value 
{
    [self willChangeValueForKey: @"intermediateDestination"];
    [self setPrimitiveValue: value
                     forKey: @"intermediateDestination"];
    [self didChangeValueForKey: @"intermediateDestination"];
}

- (NSString*) sourceString {
	InduYard *source = [self currentLocation];
	NSString *result = [NSString stringWithFormat: @"%@/%@",
					[source valueForKeyPath: @"location.name"],
					[source valueForKey: @"name"]];
	return result;
}

- (NSString*) sourceIndustryString {
	InduYard *source = [self currentLocation];
	NSString *result = [NSString stringWithFormat: @"%@", 
						[source valueForKey: @"name"]];
	return result;
}

- (NSString*) destinationIndustryString {
	InduYard *source = [self nextStop];
	NSString *result = [NSString stringWithFormat: @"%@", 
						[source valueForKey: @"name"]];
	return result;
}

// Move the car to its next destination, and remove it from its current train.
// Returns false if any problems noted.
- (BOOL) moveOneStep {
	InduYard *nextIndustry=NULL;
	
	// Make sure we have some idea where this car ended up.  Either it was an
	// empty car and the intermediateDestination was used for routing, or it
	// was a loaded car where it had an intermediate location to get partway to
	// its final destination or we can assume it got where it needed.
	// We can't have empty cars that had no known place to go - they shouldn't
	// have gotten on a train otherwise.
	
	assert (([self intermediateDestination] != nil)  ||
			([self cargo] != nil));
	
	if ([self intermediateDestination]) {
		[self setCurrentLocation: [self intermediateDestination]];
	} else if ([self cargo]) {
		nextIndustry = ([self isLoaded] ? [[self cargo] destination]
						: [[self cargo] source]);
		[self setCurrentLocation: nextIndustry];
		// Update door position.

		if (nextIndustry && [nextIndustry hasDoors]) {
			[self setCurrentDoor: [self doorToSpot]];
		}
	} else {
		printf("No idea where car %s goes - no intermediate dest or location!\n",[[self reportingMarks] UTF8String]);
		return false;
	}
	
	// Finally, remove from train and clear info.
	[self removeFromTrain];
	return true;
}

- (NSString*) destString {
	NSString *toIndustry, *toTown;
	BOOL loaded = [self isLoaded];
	if ([self intermediateDestination]) {
		// If freight car's being routed home empty, we use intermediateLocation for next place.
		toIndustry = [[self intermediateDestination] name];
		toTown = [[[self intermediateDestination] location] name];
	} else if ([self cargo]) {
		if (loaded) {
			toIndustry = [self valueForKeyPath: @"cargo.destination.name"];
			toTown = [self valueForKeyPath: @"cargo.destination.location.name"];
		} else {
			toIndustry = [self valueForKeyPath: @"cargo.source.name"];
			toTown = [self valueForKeyPath: @"cargo.source.location.name"];
		}
	} else {
		toIndustry=@"---";
		toTown=@"----";
	} 
	return [NSString stringWithFormat: @"%15s/%-15s",[toTown UTF8String],[toIndustry UTF8String]];
}


// Comparison routine for grouping cars going to the same place.
- (NSComparisonResult) compareNextStop: (FreightCar *) other {
	return [[[self nextStop] name] compare: [[other nextStop] name]];
}

// Sort by reporting marks.
- (NSComparisonResult) compareNames: (FreightCar*) other {
	return [[self reportingMarks] isEqualToString: [other reportingMarks]];
}

@end