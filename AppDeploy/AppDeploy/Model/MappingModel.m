#import "MappingModel.h"

@implementation MappingModel
#define kBundleId @"bundleId"
#define kTemplateKey @"templateKey"
#define kModel @"model"


- (BOOL) isValid {
	if (IsEmpty(self.bundleId) || IsEmpty(self.templateKey) ) {
		return NO;
	}
	return YES;
}

-(id)initWithDictionary:(NSDictionary *)dict {
	self = [super init];
	if (self!=nil) {
		self.bundleId = [dict objectForKey:kBundleId];
		self.templateKey = [dict objectForKey:kTemplateKey];
		self.model = [dict objectForKey:kModel];
	}
	return self;
}


- (NSDictionary *) exportData {
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if (!IsEmpty(self.bundleId)) { [dictionary setObject:self.bundleId forKey:kBundleId];}
	if (!IsEmpty(self.templateKey)) { [dictionary setObject:self.templateKey forKey:kTemplateKey]; }
	
	return dictionary;
}

@end
