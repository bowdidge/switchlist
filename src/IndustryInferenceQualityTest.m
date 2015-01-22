//
//  IndustryInferenceQualityTest.m
//  SwitchList
//
// Test that we are getting adequate quality when inferring industry categories from industry names.
//
//  Created by bowdidge on 8/29/14.
//
//

#import <XCTest/XCTest.h>

#import "BKClassifier.h"
#import "TypicalIndustryStore.h"

@interface IndustryInferenceQualityTest : XCTestCase
@property (retain, nonatomic) TypicalIndustryStore *store;
@property int tries;
@property int matches;
@property int nearMatches;

@end

@implementation IndustryInferenceQualityTest

- (void)setUp
{
    [super setUp];
    NSURL* typicalIndustryFile = [[NSBundle bundleForClass: [self class]] URLForResource: @"typicalIndustry" withExtension: @"plist"];
    self.store = [[TypicalIndustryStore alloc] initWithIndustryPlistFile: [typicalIndustryFile path]];
    
    self.tries = 0;
    self.matches = 0;
    self.nearMatches = 0;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Tests that the provided industry name would have the named category as its
// first, second, or third choice.
- (void) testIndustry: (NSString*) industry hasCategory: (NSString*) category {
    
    // Validate truly a category.
    if (![self.store.categoryMap objectForKey: category]) {
        NSLog(@"No such category: %@", category);
        return;
    }
    NSArray* categories = [self.store categoriesForIndustryName: industry];
    
    NSString *topGuess = (categories.count > 0) ? [categories objectAtIndex: 0] : @"";
    NSString *secondGuess = (categories.count > 1) ? [categories objectAtIndex: 1] : @"";
    NSString *thirdGuess = (categories.count > 2) ? [categories objectAtIndex: 2] : @"";
    self.tries++;
    if ([topGuess isEqualToString: category]) {
        self.matches++;
    } else if ([secondGuess isEqualToString: category]) {
        self.nearMatches++;
    } else if ([thirdGuess isEqualToString: category]) {
        self.nearMatches++;
    } else {
        NSLog(@"For %@: %@ came up as %@ or %@ or %@\n", industry, category, topGuess, secondGuess, thirdGuess);
       [self.store printCategoriesForIndustryName: industry];
    }
}

- (void)testExample {
    XCTAssertTrue(self.store.typicalIndustries.count > 0, @"No suggested industries found.");
    [self testIndustry: @"Pepsi Cola Bottling" hasCategory: @"food processing plant"];
    [self testIndustry: @"Agway 2" hasCategory: @"general warehouse"];
    [self testIndustry: @"Brick Works" hasCategory: @"brick factory"];
    [self testIndustry: @"Max's Millwork" hasCategory: @"manufacturer"];
    [self testIndustry: @"Deisel Engine House" hasCategory: @"engine house"];
    [self testIndustry: @"Storm Logging" hasCategory: @"lumber mill"];
    [self testIndustry: @"Railway Express" hasCategory: @"freight house"];
    [self testIndustry: @"Sweet's Candy" hasCategory: @"food processing plant"];
    [self testIndustry: @"Copper Valley Ore Mine" hasCategory: @"mine"];
    [self testIndustry: @"Redwing Flour Mill" hasCategory: @"grain mill"];
    [self testIndustry: @"Golden Valley Canning" hasCategory: @"cannery"];
    [self testIndustry: @"Silver Creek Meat Packing Co." hasCategory: @"meat packer"];
    [self testIndustry: @"Coal Tower" hasCategory: @"coaling tower"];
    [self testIndustry: @"ADM" hasCategory: @"grain elevator"];
    [self testIndustry: @"United Dairy Farmers" hasCategory: @"dairy"];
    [self testIndustry: @"Building Supply" hasCategory: @"building materials"];
    [self testIndustry: @"Agway 3" hasCategory: @"general warehouse"];
    [self testIndustry: @"Sunrise Feed & Seed" hasCategory: @"feed mill"];
    [self testIndustry: @"F.C.Rode & Co. Hardware & Lumber" hasCategory: @"lumberyard"];
    [self testIndustry: @"Farm Fresh Warehouse" hasCategory: @"fresh fruit packer"];
    [self testIndustry: @"Stockyard" hasCategory: @"stock yard"];
    [self testIndustry: @"Steam Engine House" hasCategory: @"coaling tower"];
    [self testIndustry: @"Neil's Tractors" hasCategory: @"equipment dealer"];
    [self testIndustry: @"Northern Light & Power" hasCategory: @"power plant"];
    [self testIndustry: @"Villa Armando" hasCategory: @"wine distributor"];
    [self testIndustry: @"Sand Spur" hasCategory: @"sand and gravel"];
    [self testIndustry: @"Tipple" hasCategory: @"sand and gravel"];
    [self testIndustry: @"Steel" hasCategory: @"steel fabricator"];
    [self testIndustry: @"Waukesha Electric" hasCategory: @"manufacturer"];
    [self testIndustry: @"Racks" hasCategory: @"auto plant"];
    [self testIndustry: @"Pabrico" hasCategory: @"brick factory"];
    [self testIndustry: @"Richert Lumber" hasCategory: @"lumberyard"];
    [self testIndustry: @"Frank-Lin Spirits" hasCategory: @"beer distributor"];
    [self testIndustry: @"Smurfit Stone" hasCategory: @"building materials"];
    [self testIndustry: @"Parts Dock" hasCategory: @"auto plant"];
    [self testIndustry: @"Team Track" hasCategory: @"team track"];
    [self testIndustry: @"Milpitas Water" hasCategory: @"water treatment plant"];
    [self testIndustry: @"Houndog Music" hasCategory: @"general warehouse"];
    [self testIndustry: @"Paper Company" hasCategory: @"paper mill"];
    [self testIndustry: @"Wood Turnings" hasCategory: @"manufacturer"];
    [self testIndustry: @"Institute Hardware" hasCategory: @"general warehouse"];
    [self testIndustry: @"North Shore Freight House" hasCategory: @"freight house"];
    [self testIndustry: @"Chestnut Warehouse" hasCategory: @"general warehouse"];
    [self testIndustry: @"Team track" hasCategory: @"team track"];
    [self testIndustry: @"RIP track" hasCategory: @"mow track"];
    [self testIndustry: @"Team Track RL" hasCategory: @"team track"];
    [self testIndustry: @"Valley Gas Supply" hasCategory: @"propane dealer"];
    [self testIndustry: @"Orr Lumber" hasCategory: @"lumberyard"];
    [self testIndustry: @"Tees Building Supplies" hasCategory: @"building materials"];
    [self testIndustry: @"Team Track MO" hasCategory: @"team track"];
    [self testIndustry: @"Valley Kaolin" hasCategory: @"chemical plant"];
    [self testIndustry: @"Grahams Feed and Grain" hasCategory: @"grain elevator"];
    [self testIndustry: @"Valley Coal" hasCategory: @"coal mine"];
    [self testIndustry: @"York Recycling" hasCategory: @"scrapyard"];
    [self testIndustry: @"Tichelaar Cement" hasCategory: @"concrete batch plant"];
    [self testIndustry: @"Team Track CF" hasCategory: @"team track"];
    [self testIndustry: @"Brownbill Machinery and Tool" hasCategory: @"equipment dealer"];
    [self testIndustry: @"Keezletown Coal Tipple" hasCategory: @"coal mine"];
    [self testIndustry: @"Saxton Sand and Gravel" hasCategory: @"sand and gravel"];
    [self testIndustry: @"Harp Cannery and Packaging" hasCategory: @"packaging"];
    [self testIndustry: @"Tynon Coal" hasCategory: @"coal yard"];
    [self testIndustry: @"Kurth Malting Load" hasCategory: @"grain mill"];
    [self testIndustry: @"Farmers Coop" hasCategory: @"grain elevator"];
    [self testIndustry: @"Lundt Ind 2" hasCategory: @"manufacturer"];
    [self testIndustry: @"Hasselkuss Milling" hasCategory: @"grain mill"];
    [self testIndustry: @"Kurth Malting Unload" hasCategory: @"grain mill"];
    [self testIndustry: @"Parts Dock" hasCategory: @"auto plant"];
    [self testIndustry: @"MPD - Refuel" hasCategory: @"locomotive fuel"];
    [self testIndustry: @"PerWay Trackwork Maint." hasCategory: @"mow track"];
    [self testIndustry: @"Scrap Road" hasCategory: @"scrapyard"];
    [self testIndustry: @"Freight & Parcels Depot" hasCategory: @"freight house"];
    [self testIndustry: @"Quay Siding" hasCategory: @"docks"];
    [self testIndustry: @"Highland Logs" hasCategory: @"lumber mill"];
    [self testIndustry: @"Hawkins Chemical" hasCategory: @"chemical plant"];
    [self testIndustry: @"Decko Products" hasCategory: @"manufacturer"];
    [self testIndustry: @"Veit Companies" hasCategory: @"manufacturer"];
    [self testIndustry: @"Interplastic Corporation" hasCategory: @"packaging"];
    [self testIndustry: @"CRESCENT CROWN" hasCategory: @"beer distributor"];
    [self testIndustry: @"UNIVAR CHEMICALS" hasCategory: @"chemical plant"];
    [self testIndustry: @"INTL. PAPER" hasCategory: @"paper"];
    [self testIndustry: @"BAY STATE MILLING" hasCategory: @"grain elevator"];
    [self testIndustry: @"PHOENIX CEMENT" hasCategory: @"concrete batch plant"];
    [self testIndustry: @"MATHESON TRI GAS" hasCategory: @"propane dealer"];
    [self testIndustry: @"BLUE LINX BLDG MAT." hasCategory: @"building materials"];
    [self testIndustry: @"PHOENIX TRANSLOAD" hasCategory: @"freight forwarder"];
    [self testIndustry: @"WEST COAST BP" hasCategory: @"oil depot"];
    [self testIndustry: @"Mine" hasCategory: @"mine"];
    [self testIndustry: @"Power Plant" hasCategory: @"power plant"];
    [self testIndustry: @"Sunsweet" hasCategory: @"dried fruit packer"];
    [self testIndustry: @"Brookfield Box" hasCategory: @"packaging"];
    [self testIndustry: @"Tidewater Petroleum" hasCategory: @"oil depot"];
    [self testIndustry: @"Hunts Cannery" hasCategory: @"cannery"];
    [self testIndustry: @"L.G. Team Trk" hasCategory: @"team track"];
    [self testIndustry: @"Lumberyard" hasCategory: @"lumberyard"];
    [self testIndustry: @"Del Monte Storage" hasCategory: @"cannery"];
    [self testIndustry: @"Standard Oil" hasCategory: @"oil depot"];
    [self testIndustry: @"Hyde Cannery" hasCategory: @"cannery"];
    [self testIndustry: @"Camp. Team Track" hasCategory: @"team track"];
    [self testIndustry: @"Lumber mill" hasCategory: @"lumber mill"];
    [self testIndustry: @"Del Monte Oil" hasCategory: @"oil depot"];
    [self testIndustry: @"Box Factory" hasCategory: @"packaging"];
    [self testIndustry: @"MOW Spur" hasCategory: @"mow track"];
    [self testIndustry: @"Del Monte Spur" hasCategory: @"cannery"];
    [self testIndustry: @"Del Monte Out" hasCategory: @"cannery"];
    [self testIndustry: @"PG&E" hasCategory: @"power plant"];
    [self testIndustry: @"Plant 51" hasCategory: @"dried fruit packer"];
    [self testIndustry: @"Drew Cannery" hasCategory: @"cannery"];
    [self testIndustry: @"Packing House" hasCategory: @"dried fruit packer"];
    [self testIndustry: @"Alma Team Trk" hasCategory: @"team track"];
    [self testIndustry: @"Wrights Team Tk" hasCategory: @"team track"];
    [self testIndustry: @"Del Monte In" hasCategory: @"cannery"];
    [self testIndustry: @"Concrete Whse" hasCategory: @"building materials"];
    [self testIndustry: @"Jackson & son MOW Waste" hasCategory: @"trucking line"];
    [self testIndustry: @"Sterling Rail Inc" hasCategory: @""];
    [self testIndustry: @"Afton Chemical Corporation" hasCategory: @"chemical plant"];
    [self testIndustry: @"Necessary Oil Co." hasCategory: @"oil depot"];
    [self testIndustry: @"ArchCoal Lone Mountain Processing Inc." hasCategory: @"coal mine"];
    [self testIndustry: @"OmniSource Metals Recycling" hasCategory: @"scrapyard"];
    [self testIndustry: @"Slick Oil & Chemicals Co." hasCategory: @"chemical plant"];
    [self testIndustry: @"Dixie Produce Inc." hasCategory: @"fresh fruit packer"];
    [self testIndustry: @"Jackson & son MOW Delivery" hasCategory: @"trucking line"];
    [self testIndustry: @"Cloverleaf Cold Storage - Vegatables & Grain" hasCategory: @"cold storage"];
    // Chicago Belt Line
    [self testIndustry: @"team track" hasCategory:  @"team track"];
    [self testIndustry: @"Mfrs Ry Interchange" hasCategory:  @"interchange"];
    [self testIndustry: @"Ink Factory" hasCategory:  @"general warehouse"];
    [self testIndustry: @"Paper Whse" hasCategory:  @"general warehouse"];
    [self testIndustry: @"Warehouse" hasCategory:  @"general warehouse"];
    [self testIndustry: @"Hawthorne Works" hasCategory:  @"manufacturer"];
    [self testIndustry: @"Cold Storage Whse" hasCategory:  @"cold storage"];
    [self testIndustry: @"Great Western Steel" hasCategory:  @"steel mill"];
    [self testIndustry: @"Biltrite Paper Box" hasCategory:  @"packaging"];
    [self testIndustry: @"Appliance Factory" hasCategory:  @"appliance factory"];
    [self testIndustry: @"Donaldson Printing" hasCategory:  @"printing"];
    [self testIndustry: @"Lumberyard" hasCategory:  @"lumberyard"];
    [self testIndustry: @"Western Electric" hasCategory:  @"manufacturer"];
    [self testIndustry: @"Scrap Metal Dealer" hasCategory:  @"scrapyard"];
    [self testIndustry: @"Auto Parts Whse" hasCategory:  @"auto parts"];
    [self testIndustry: @"Team Track" hasCategory:  @"team track"];
    [self testIndustry: @"Cereal Plant" hasCategory:  @"food processing plant"];
    [self testIndustry: @"East Coast" hasCategory:  @"offline"];
    [self testIndustry: @"Meihle Printing" hasCategory:  @"printing"];
    [self testIndustry: @"West Coast" hasCategory:  @"offline"];
    [self testIndustry: @"Candy Factory" hasCategory:  @"food processing plant"];
    
    float matchSuccessThreshold = 0.60; // 60%.
    float nearMatchSuccessThreshold = 0.80; // 85%.
    NSLog(@"Match rate: %0.2f, near-miss: %0.2f", (self.matches / (float) self.tries), (self.matches + self.nearMatches / (float) self.tries));
    XCTAssertTrue(self.tries * matchSuccessThreshold < self.matches, @"Expected 60%% accuracy for matches, got %0.2f.", (self.matches / (float) self.tries));
    XCTAssertTrue(self.tries * nearMatchSuccessThreshold < self.matches + self.nearMatches, @"Expected 80%% accuracy for near misses, got %0.2f.", (self.matches + self.nearMatches / (float) self.tries));
}

@end
