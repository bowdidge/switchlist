//
//  main.m
//  training_practice
//
//  Created by bowdidge on 8/26/14.
//  Copyright (c) 2014 bowdidge. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TypicalIndustryStore.h"

int tries = 0;
int match = 0;
int nearMatch = 0;

void TestCategorization(TypicalIndustryStore* classifier,
			const char* industryName, const char *category) {
    // Validate truly a category.
    if (![classifier.categoryMap objectForKey: [NSString stringWithUTF8String: category]]) {
        NSLog(@"No such category: %s", category);
        return;
    }
    NSArray* categories = [classifier categoriesForIndustryName: [NSString stringWithUTF8String: industryName]];

	NSString *topGuess = (categories.count > 0) ? [categories objectAtIndex: 0] : @"";
    NSString *secondGuess = (categories.count > 1) ? [categories objectAtIndex: 1] : @"";
    NSString *thirdGuess = (categories.count > 2) ? [categories objectAtIndex: 2] : @"";
    tries++;
    if ([topGuess isEqualToString: [NSString stringWithUTF8String: category]]) {
      match++;
    } else if ([secondGuess isEqualToString: [NSString stringWithUTF8String: category]]) {
      nearMatch++;
    } else if ([thirdGuess isEqualToString: [NSString stringWithUTF8String: category]]) {
        nearMatch++;
    } else {
      fprintf(stderr, "For %s: %s came up as %s or %s or %s\n",
	      industryName, category, [topGuess UTF8String], [secondGuess UTF8String], [thirdGuess UTF8String]);
        [classifier printCategoriesForIndustryName: [NSString stringWithUTF8String: industryName]];
	}
}

void TestAccuracy(TypicalIndustryStore* classifier) {
  tries = 0;
  match = 0;
    nearMatch = 0;
  TestCategorization(classifier, "Pepsi Cola Bottling","food processing plant");
  TestCategorization(classifier, "Agway 2","general warehouse");
  TestCategorization(classifier, "Brick Works","brick factory");
  TestCategorization(classifier, "Max's Millwork","manufacturer");
  TestCategorization(classifier, "Deisel Engine House","engine house");
  TestCategorization(classifier, "Storm Logging","lumber mill");
  TestCategorization(classifier, "Railway Express","freight house");
  TestCategorization(classifier, "Sweet's Candy","food processing plant");
  TestCategorization(classifier, "Copper Valley Ore Mine","mine");
  TestCategorization(classifier, "Redwing Flour Mill","grain mill");
  TestCategorization(classifier, "Golden Valley Canning","cannery");
  TestCategorization(classifier, "Silver Creek Meat Packing Co.","meat packer");
  TestCategorization(classifier, "Coal Tower","coaling tower");
  TestCategorization(classifier, "ADM","grain elevator");
  TestCategorization(classifier, "United Dairy Farmers","dairy");
  TestCategorization(classifier, "Building Supply","building materials");
  TestCategorization(classifier, "Agway 3","general warehouse");
  TestCategorization(classifier, "Sunrise Feed & Seed","feed mill");
  TestCategorization(classifier, "F.C.Rode & Co. Hardware & Lumber","lumberyard");
  TestCategorization(classifier, "Farm Fresh Warehouse","fresh fruit packer");
  TestCategorization(classifier, "Stockyard","stock yard");
  TestCategorization(classifier, "Steam Engine House","coaling tower");
  TestCategorization(classifier, "Neil's Tractors","equipment dealer");
  TestCategorization(classifier, "Northern Light & Power","power plant");
  TestCategorization(classifier, "Villa Armando","wine distributor");
  TestCategorization(classifier, "Sand Spur","sand and gravel");
  TestCategorization(classifier, "Tipple","sand and gravel");
  TestCategorization(classifier, "Steel","steel fabricator");
  TestCategorization(classifier, "Waukesha Electric","manufacturer");
  TestCategorization(classifier, "Racks","auto plant");
  TestCategorization(classifier, "Pabrico","brick factory");
  TestCategorization(classifier, "Richert Lumber","lumberyard");
  TestCategorization(classifier, "Frank-Lin Spirits","beer distributor");
  TestCategorization(classifier, "Smurfit Stone","building materials");
  TestCategorization(classifier, "Parts Dock","auto plant");
  TestCategorization(classifier, "Team Track","team track");
  TestCategorization(classifier, "Milpitas Water","water treatment plant");
  TestCategorization(classifier, "Houndog Music","general warehouse");
  TestCategorization(classifier, "Paper Company","paper mill");
  TestCategorization(classifier, "Wood Turnings","manufacturer");
  TestCategorization(classifier, "Institute Hardware","general warehouse");
  TestCategorization(classifier, "North Shore Freight House","freight house");
  TestCategorization(classifier, "Chestnut Warehouse","general warehouse");
  TestCategorization(classifier, "Team track","team track");
  TestCategorization(classifier, "RIP track","mow track");
  TestCategorization(classifier, "Team Track RL","team track");
  TestCategorization(classifier, "Valley Gas Supply","propane dealer");
  TestCategorization(classifier, "Orr Lumber","lumberyard");
  TestCategorization(classifier, "Tees Building Supplies","building materials");
  TestCategorization(classifier, "Team Track MO","team track");
  TestCategorization(classifier, "Valley Kaolin","chemical plant");
  TestCategorization(classifier, "Grahams Feed and Grain","grain elevator");
  TestCategorization(classifier, "Valley Coal","coal mine");
  TestCategorization(classifier, "York Recycling","scrapyard");
  TestCategorization(classifier, "Tichelaar Cement","concrete batch plant");
  TestCategorization(classifier, "Team Track CF","team track");
  TestCategorization(classifier, "Brownbill Machinery and Tool","equipment dealer");
  TestCategorization(classifier, "Keezletown Coal Tipple","coal mine");
  TestCategorization(classifier, "Saxton Sand and Gravel","sand and gravel");
  TestCategorization(classifier, "Harp Cannery and Packaging","packaging");
  TestCategorization(classifier, "Tynon Coal","coal yard");
  TestCategorization(classifier, "Kurth Malting Load","grain mill");
  TestCategorization(classifier, "Farmers Coop","grain elevator");
  TestCategorization(classifier, "Lundt Ind 2","manufacturer");
  TestCategorization(classifier, "Hasselkuss Milling","grain mill");
  TestCategorization(classifier, "Kurth Malting Unload","grain mill");
  TestCategorization(classifier, "Parts Dock","auto plant");
  TestCategorization(classifier, "MPD - Refuel","locomotive fuel");
  TestCategorization(classifier, "PerWay Trackwork Maint.","mow track");
  TestCategorization(classifier, "Scrap Road","scrapyard");
  TestCategorization(classifier, "Freight & Parcels Depot","freight house");
  TestCategorization(classifier, "Quay Siding","docks");
  TestCategorization(classifier, "Highland Logs","lumber mill");
  TestCategorization(classifier, "Hawkins Chemical","chemical plant");
  TestCategorization(classifier, "Decko Products","manufacturer");
  TestCategorization(classifier, "Veit Companies","manufacturer");
  TestCategorization(classifier, "Interplastic Corporation","packaging");
  TestCategorization(classifier, "CRESCENT CROWN","beer distributor");
  TestCategorization(classifier, "UNIVAR CHEMICALS","chemical plant");
  TestCategorization(classifier, "INTL. PAPER","paper");
  TestCategorization(classifier, "BAY STATE MILLING","grain elevator");
  TestCategorization(classifier, "PHOENIX CEMENT","concrete batch plant");
  TestCategorization(classifier, "MATHESON TRI GAS","propane dealer");
  TestCategorization(classifier, "BLUE LINX BLDG MAT.","building materials");
  TestCategorization(classifier, "PHOENIX TRANSLOAD","freight forwarder");
  TestCategorization(classifier, "WEST COAST BP","oil depot");
  TestCategorization(classifier, "Mine","mine");
  TestCategorization(classifier, "Power Plant","power plant");
  TestCategorization(classifier, "Sunsweet","dried fruit packer");
  TestCategorization(classifier, "Brookfield Box","packaging");
  TestCategorization(classifier, "Tidewater Petroleum","oil depot");
  TestCategorization(classifier, "Hunts Cannery","cannery");
  TestCategorization(classifier, "L.G. Team Trk","team track");
  TestCategorization(classifier, "Lumberyard","lumberyard");
  TestCategorization(classifier, "Del Monte Storage","cannery");
  TestCategorization(classifier, "Standard Oil","oil depot");
  TestCategorization(classifier, "Hyde Cannery","cannery");
  TestCategorization(classifier, "Camp. Team Track","team track");
  TestCategorization(classifier, "Lumber mill","lumber mill");
  TestCategorization(classifier, "Del Monte Oil","oil depot");
  TestCategorization(classifier, "Box Factory","packaging");
  TestCategorization(classifier, "MOW Spur","mow track");
  TestCategorization(classifier, "Del Monte Spur","cannery");
  TestCategorization(classifier, "Del Monte Out","cannery");
  TestCategorization(classifier, "PG&E","power plant");
  TestCategorization(classifier, "Plant 51","dried fruit packer");
  TestCategorization(classifier, "Drew Cannery","cannery");
  TestCategorization(classifier, "Packing House","dried fruit packer");
  TestCategorization(classifier, "Alma Team Trk","team track");
  TestCategorization(classifier, "Wrights Team Tk","team track");
  TestCategorization(classifier, "Del Monte In","cannery");
  TestCategorization(classifier, "Concrete Whse","building materials");
  TestCategorization(classifier, "Jackson & son MOW Waste","trucking line");
  TestCategorization(classifier, "Sterling Rail Inc","");
  TestCategorization(classifier, "Afton Chemical Corporation","chemical plant");
  TestCategorization(classifier, "Necessary Oil Co.","oil depot");
  TestCategorization(classifier, "ArchCoal Lone Mountain Processing Inc.","coal mine");
  TestCategorization(classifier, "OmniSource Metals Recycling","scrapyard");
  TestCategorization(classifier, "Slick Oil & Chemicals Co.","chemical plant");
  TestCategorization(classifier, "Dixie Produce Inc.","fresh fruit packer");
  TestCategorization(classifier, "Jackson & son MOW Delivery","trucking line");
  TestCategorization(classifier, "Cloverleaf Cold Storage - Vegatables & Grain","cold storage");
  // Chicago Belt Line
  TestCategorization(classifier, "team track", "team track");
  TestCategorization(classifier, "Mfrs Ry Interchange", "interchange");
  TestCategorization(classifier, "Ink Factory", "general warehouse");
  TestCategorization(classifier, "Paper Whse", "general warehouse");
  TestCategorization(classifier, "Warehouse", "general warehouse");
  TestCategorization(classifier, "Hawthorne Works", "manufacturer");
  TestCategorization(classifier, "Cold Storage Whse", "cold storage");
  TestCategorization(classifier, "Great Western Steel", "steel mill");
  TestCategorization(classifier, "Biltrite Paper Box", "packaging");
  TestCategorization(classifier, "Appliance Factory", "appliance factory");
  TestCategorization(classifier, "Donaldson Printing", "printing");
  TestCategorization(classifier, "Lumberyard", "lumberyard");
  TestCategorization(classifier, "Western Electric", "manufacturer");
  TestCategorization(classifier, "Scrap Metal Dealer", "scrapyard");
  TestCategorization(classifier, "Auto Parts Whse", "auto parts");
  TestCategorization(classifier, "Team Track", "team track");
  TestCategorization(classifier, "Cereal Plant", "food processing plant");
  TestCategorization(classifier, "East Coast", "offline");
  TestCategorization(classifier, "Meihle Printing", "printing");
  TestCategorization(classifier, "West Coast", "offline");
  TestCategorization(classifier, "Candy Factory", "food processing plant");

  printf("%d matches, %d near matches out of %d tries\n", match, nearMatch, tries);
}
// Reads the typical industry database file, and produces the array of objects
// described in its plist format.
NSArray* ReadIndustryFile(NSString* typicalIndustriesFile) {
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSArray *result;
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath: typicalIndustriesFile];
	result = (NSArray *)[NSPropertyListSerialization
                         propertyListFromData:plistXML
                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                         format:&format
                         errorDescription:&errorDesc];
    
	if (!result) {
		NSLog(@"Error reading plist: %@", errorDesc);
		return nil;
	}
	return result;
}


NSComparisonResult CompareStrings(id obj1, id obj2) {
	return [obj1 compare: obj2];
}

NSString *EscapedXml(NSString* str) {
	return [[str stringByReplacingOccurrencesOfString: @"&" withString: @""]
			stringByReplacingOccurrencesOfString: @"\n" withString: @""];
}

void WriteXmlDict(NSDictionary* dict) {
	FILE *f = fopen("foo", "w");
	fputs("  <array>\n", f);
	for (NSString *key in [[dict allKeys] sortedArrayUsingSelector: @selector(compare:)]) {
		NSDictionary *item = [dict objectForKey: key];
		fputs("    <dict>\n", f);
		fputs("      <key>IndustryClass</key><string>",f );
		fputs([EscapedXml([item objectForKey: @"IndustryClass"] )UTF8String], f);
		fputs("</string>\n", f);
		fputs("      <key>Synonyms</key>\n", f);
		fputs("      <array>\n", f);
		for (NSString *name in [item objectForKey: @"Synonyms"]) {
			fprintf(f, "        <string>%s</string>\n", [EscapedXml(name) UTF8String]);
		}
		fputs("      </array>\n", f);
		
		fputs("      <key>Cargo</key>\n", f);
		NSArray *cargos = [item objectForKey: @"Cargo"];
		fputs("      <array>\n", f);
		for (NSDictionary *cargo in cargos) {
			fputs("        <dict>\n", f);
			fputs("          <key>Name</key><string>",f );
			fputs([EscapedXml([cargo objectForKey: @"Name"]) UTF8String], f);
			fputs("</string>\n", f);
		
			if ([[cargo objectForKey: @"Incoming"] boolValue]) {
				fputs("          <key>Incoming</key><true/>\n",f );
			} else {
				fputs("          <key>Incoming</key><false/>\n",f );
			}
			fputs("          <key>Rate</key>",f );
			fprintf(f, "<integer>%d</integer>\n", ([[cargo objectForKey: @"Rate"] intValue]));
		
			if ([cargo objectForKey: @"Era"]) {
				fputs("        <key>Era</key>\n", f);
				fprintf(f, "        <integer>%d</integer>\n", ([[cargo objectForKey: @"Era"] intValue]));
			}
			fputs("        </dict>\n", f);
		}
		
		fputs("      </array>\n", f);
		fputs("    </dict>\n", f);
	}
	fputs("  </array>\n", f);
	fclose(f);
}

void AddSynonymToClass(NSString* newSynonym, NSString* className, NSMutableDictionary *industryXmlDict) {
	NSMutableDictionary* classDictionary = [NSMutableDictionary dictionaryWithDictionary:
											[industryXmlDict objectForKey: className]];
	NSMutableArray *synonyms = [NSMutableArray arrayWithArray: [classDictionary objectForKey: @"Synonyms"]];
	
	for (NSString *synonym in synonyms) {
		if ([synonym isEqualToString: newSynonym]) {
			printf("(Already there)\n");
			return;
		}
	}
	[synonyms addObject: newSynonym];
	[classDictionary setObject: synonyms forKey: @"Synonyms"];
	[industryXmlDict setObject: classDictionary forKey: className];
}

void AddCargoToClass(NSString *newShipOrReceive, NSString* newCargo, NSString* className, NSMutableDictionary *industryXmlDict) {
	printf("Adding cargo %s to %s\n", [newCargo UTF8String], [className UTF8String]);
	NSMutableDictionary* classDictionary = [NSMutableDictionary dictionaryWithDictionary:
											[industryXmlDict objectForKey: className]];
	NSMutableArray *cargos = [NSMutableArray arrayWithArray: [classDictionary objectForKey: @"Cargo"]];
	
	for (NSDictionary *cargoDict in cargos) {
		if ([[cargoDict objectForKey: @"Name"] isEqualToString: newCargo]) {
			printf("(Already there)\n");
			return;
		}
	}
	bool isReceive = [newShipOrReceive isEqualToString: @"R"];
	NSDictionary *cargoDict = [NSDictionary dictionaryWithObjectsAndKeys: newCargo, @"Name", [NSNumber numberWithBool: isReceive], @"Incoming", [NSNumber numberWithInt: 0], @"Rate", nil];
	[cargos addObject: cargoDict];
	[classDictionary setObject: cargos forKey: @"Cargo"];
	[industryXmlDict setObject: classDictionary forKey: className];
}

void MakeGuess(TypicalIndustryStore* store, NSString* input, NSString *shipOrReceive, NSString* cargo) {
    NSMutableDictionary *industryXmlDict = store.categoryMap;
    NSDictionary *result = [store categoriesAndScoresForIndustryName: input];
    NSString *topGuess = [NSString string];
    double topInputScore = 0.0;
    for (NSString *guess in [result allKeys]) {
        NSNumber *score = [result objectForKey: guess];
        if ([score floatValue] > topInputScore) {
            topInputScore = [score floatValue];
            topGuess = guess;
        }
    }
	
    printf("----------------------------------\n");
    printf("For %s: probably %s.\n  Loads: %s %s\n", [input UTF8String], [topGuess UTF8String], [shipOrReceive UTF8String], [cargo UTF8String]);
    printf("----------------------------------\n");
    NSArray* keys = [result allKeys];
    int i = 1;
    for (NSString *key in keys) {
        NSNumber *score = [result objectForKey: key];
        printf("%d: %s (%f)\n", i, [key UTF8String], [score floatValue]);
        i++;
    }
    printf("Choice? (1,2,3,4,5,6,n/?/q)\n");
	char inputBuf[1000];
	fgets(inputBuf, 1000, stdin);

    if (inputBuf[0] >= '1' && inputBuf[0] <= '9') {
		NSString* className = [keys objectAtIndex: inputBuf[0] - '1'];
		AddSynonymToClass(input, className, industryXmlDict);
		
	} else if (inputBuf[0] == 'y') {
        //[results addObject: [NSString stringWithFormat: @"%@ %@", input, topGuess]] ;
	   AddCargoToClass(shipOrReceive, cargo, topGuess, industryXmlDict);
    } else if (inputBuf[0] == 'n') {
        printf("Name category?\n");
        char inputBuf[1000];
		fgets(inputBuf, 1000, stdin);
        inputBuf[strlen(inputBuf)-1] = '\0';
		NSString *newCategoryName = [NSString stringWithUTF8String: inputBuf];
		NSMutableDictionary* category;
		if ((category = [industryXmlDict objectForKey: newCategoryName])) {
			NSLog(@"Adding to %n\n", newCategoryName);
			AddSynonymToClass(input, newCategoryName, industryXmlDict);
			AddCargoToClass(shipOrReceive, cargo, newCategoryName, industryXmlDict);
		} else {
			NSLog(@"New category is '%@'", newCategoryName);
			NSMutableDictionary *newCategory = [NSMutableDictionary dictionary];
			[newCategory setObject: newCategoryName forKey: @"IndustryClass"];
			[newCategory setObject: [NSArray arrayWithObject: input]forKey: @"Synonyms"];
			[industryXmlDict setObject: newCategory forKey: newCategoryName];  
			AddCargoToClass(shipOrReceive, cargo, newCategoryName, industryXmlDict);
		}
        //[results addObject: [NSString stringWithFormat: @"%@ %s", input, inputBuf]] ;
    } else if (inputBuf[0] == 'q') {
        WriteXmlDict(industryXmlDict);
        exit(1);
    } else {
        // 
	}
}


int main(int argc, const char * argv[]){
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (argc < 3) {
        fprintf(stderr, "Usage: foo training-file industry-file\n");
        exit(1);
    }
    NSString *trainingFile = [NSString stringWithUTF8String: argv[1]];
    NSString *newFile = [NSString stringWithUTF8String: argv[2]];

    TypicalIndustryStore *store = [[TypicalIndustryStore alloc] initWithIndustryPlistFile: trainingFile];
	TestAccuracy(store);
    
    
    NSError* error;
    NSString *newData = [[NSString alloc] initWithContentsOfFile: newFile encoding: NSUTF8StringEncoding error: &error];
    NSArray  *lines = [newData componentsSeparatedByString: @"\n"];
    for (NSString* line in lines) {
        NSArray *terms = [line componentsSeparatedByString: @"\t"];
        MakeGuess(store, [[terms objectAtIndex: 0] lowercaseString], [terms objectAtIndex: 1], [terms objectAtIndex: 2]);

    }
    return 0;
}

