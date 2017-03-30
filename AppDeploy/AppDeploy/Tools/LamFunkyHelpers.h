
/// Stringification, see this:
/// http://gcc.gnu.org/onlinedocs/cpp/Stringification.html
#define xstr(s) str(s)
#define str(s) #s



/// Processes the given formatted NSString.
#define StrF StrFmt
#define StrFmt(x, ...) [NSString stringWithFormat:(x), ##__VA_ARGS__]
/// Localizes the given NSString, filename as a comment.
#define StrL StrLoc
#define StrLoc(x, cmt) NSLocalizedString((x), (cmt))



/// Returns NO is the object is nil or empty.
/// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL IsEmpty(id thing) {
	return thing == nil ||
	([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
	([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

static inline NSString* notEmptyString(id thing) {
	if (!IsEmpty(thing)) return thing;
	else return @"";
}


/// Checks if it is possible to get an object at this index, then returns it.
/// Else, returns nil (out of bounds, or does not answer to count or objectAtIndex:).
static inline id safeObjectAtIndex(id aCollection, NSUInteger index) {
    
    if (![aCollection respondsToSelector:@selector(objectAtIndex:)]) return nil;
    if (![aCollection respondsToSelector:@selector(count)]) return nil;
    if (index >= [aCollection count]) return nil;
    
    return [aCollection objectAtIndex:index];
}



/// Returns an empty string if the given object is nil or is not a string.
/// Also works for NSNumbers.
static inline NSString *emptyStringIfNil(id object)
{
    if ([object isKindOfClass:[NSString class]]) return object;
    if ([object isKindOfClass:[NSNumber class]]) return StrFmt(@"%@", object);
    return @"";
}



/// Returns a string containing "0" if the given object is nil or is not an NSNumber.
static inline NSString *zeroStringIfNil(id object)
{
    if ([object isKindOfClass:[NSNumber class]]) return StrFmt(@"%@", object);
    return @"0";
}





