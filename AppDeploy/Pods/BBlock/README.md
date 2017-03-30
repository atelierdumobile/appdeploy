##BBNSButton.h

###@interface BBNSButton : NSButton

Set the callback block to be called when the mouse **enters** the button.

```obj-c
- (void)setInCallback:(BBNSButtonCallback)block;
```

Set the callback block to be called when the mouse **exits** the button.

```obj-c
- (void)setOutCallback:(BBNSButtonCallback)block;
```

Set both the **enter* and **exit** callback blocks.

```obj-c
- (void)setInCallback:(BBNSButtonCallback)inBlock andOutCallback:(BBNSButtonCallback)outBlock;
```

##BBlock.h

###@interface BBlock : NSObject

For when you need a weak reference of an object, example: `BBlockWeakObject(obj) wobj = obj;`

For when you need a weak reference to self, example: `BBlockWeakSelf wself = self;`

Execute the block on the main thread

```obj-c
+ (void)dispatchOnMainThread:(void (^)())block;
```

Exectute the block on a background thread but in a synchronous queue

```obj-c
+ (void)dispatchOnSynchronousQueue:(void (^)())block;
```

Exectute the block on a background thread but in a synchronous queue,

This queue should only be used for writing files to disk.

```obj-c
+ (void)dispatchOnSynchronousFileQueue:(void (^)())block;
```

```obj-c
+ (void)dispatchOnDefaultPriorityConcurrentQueue:(void (^)())block;
```

```obj-c
+ (void)dispatchOnLowPriorityConcurrentQueue:(void (^)())block;
```

```obj-c
+ (void)dispatchOnHighPriorityConcurrentQueue:(void (^)())block;
```

##NSApplication+BBlock.h

###@interface NSApplication (BBlock)

```obj-c
- (void)beginSheet:(NSWindow*)sheet modalForWindow:(NSWindow*)modalWindow completionHandler:(void (^)(NSInteger returnCode))handler;
```

##NSArray+BBlock.h

###@interface NSArray(BBlock)

Enumerate each object in the array.

```obj-c
- (void)enumerateEachObjectUsingBlock:(void(^)(id obj))block;
```

Apply the block to each object in the array and return an array of resulting objects

```obj-c
- (NSArray *)arrayWithObjectsMappedWithBlock:(id(^)(id obj))block;
```

##NSButton+BBlock.h

###@interface NSButton(BBlock)

**WARNING**: This category is still in early development.
Currently the order of calling these methods is important:

1. `setImage`
2. `setAlternateBackgroundImage`
3. `setBackgroundImage`

Tries to mimic `UIButton` by exposing a method to set the background image.
The image set with `setImage` is composited on-top of the background image. 

```obj-c
- (void)setBackgroundImage:(NSImage *)backgroundImage;
```

Tries to mimic `UIButton` by exposing a method to set the alternate background image.
The image set with `setAlternateImage` is composited on-top of the alternate background image.
If no `alternateImage` is set `image` will be used instead. 

```obj-c
- (void)setAlternateBackgroundImage:(NSImage *)alternateBackgroundImage;
```

##NSDictionary+BBlock.h

###@interface NSDictionary(BBlock)

Enumerate each key and object in the dictioanry.

```obj-c
- (void)enumerateEachKeyAndObjectUsingBlock:(void(^)(id key, id obj))block;
```

```obj-c
- (void)enumerateEachSortedKeyAndObjectUsingBlock:(void(^)(id key, id obj, NSUInteger idx))block;
```

##NSImage+BBlock.h

###@interface NSImage(BBlock)

Returns a `NSImage` rendered with the drawing code in the block.
This method does not cache the image object. 

```obj-c
+ (NSImage *)imageForSize:(NSSize)size withDrawingBlock:(void(^)())drawingBlock;
```

Returns a cached `NSImage` rendered with the drawing code in the block.
The `NSImage` is cached in an `NSCache` with the identifier provided. 

```obj-c
+ (NSImage *)imageWithIdentifier:(NSString *)identifier forSize:(NSSize)size andDrawingBlock:(void(^)())drawingBlock;
```

##NSObject+BBlock.h

###@interface NSObject(BBlock)

```obj-c
- (NSString *)addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(NSObjectBBlock)block;
```

```obj-c
- (void)removeObserverForToken:(NSString *)identifier;
```

##NSTimer+BBlock.h

###@interface NSTimer(BBlock)

```obj-c
+ (id)timerWithTimeInterval:(NSTimeInterval)timeInterval andBlock:(void (^)())block;
```

```obj-c
+ (id)timerRepeats:(BOOL)repeats withTimeInterval:(NSTimeInterval)timeInterval andBlock:(void (^)())block;
```

```obj-c
+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval andBlock:(void (^)())block;
```

```obj-c
+ (id)scheduledTimerRepeats:(BOOL)repeats withTimeInterval:(NSTimeInterval)timeInterval andBlock:(void (^)())block;
```

##NSURL+BBlock.h

###@interface NSURL(BBlock)

Access a security scoped bookmark for sandboxed mac apps.

This method starts the access, runs the block, then stops the access.

```obj-c
-(void)accessSecurityScopedResourceWithBlock:(void (^)())block;
```

##NSAlert+BBlock.h

###@interface NSAlert(BBlock)

Run NSAlert as sheet for window with completion handler block.

```obj-c
-(void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger returnCode))handler contextInfo:(void *)contextInfo;
```

##SKProductsRequest+BBlock.h

###@interface SKProductsRequest(BBlock)

Request a StoreKit response for a set of product identifiers

```obj-c
+ (id)requestWithProductIdentifiers:(NSSet *)productIdentifiers andBlock:(SKProductsRequestBBlock)block;
```

```obj-c
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers andBlock:(SKProductsRequestBBlock)block;
```

##UIActionSheet+BBlock.h

###@interface UIActionSheet(BBlock)

```obj-c
- (void)setCompletionBlock:(UIActionSheetBBlock)block;
```

```obj-c
- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle destructiveButtonTitle:(NSString *)destructiveTitle otherButtonTitle:(NSString *)otherTitle completionBlock:(UIActionSheetBBlock)block;
```

##UIAlertView+BBlock.h

###@interface UIAlertView(BBlock)

```obj-c
- (void)setCompletionBlock:(UIAlertViewBBlock)block;
```

```obj-c
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle otherButtonTitle:(NSString *)otherButtonTitle completionBlock:(UIAlertViewBBlock)block;
```

##UIButton+BBlock.h

###@interface UIButton(BBlock)

```obj-c
- (void)addActionForControlEvents:(UIControlEvents)events withBlock:(BBlockUIButtonBlock)block;
```

##UIGestureRecognizer+BBlock.h

###@interface UISwipeGestureRecognizer(BBlock)

```obj-c
- (id)initWithDirection:(UISwipeGestureRecognizerDirection)direction andBlock:(UIGestureRecognizerBBlock)block;
```

```obj-c
+ (id)gestureWithDirection:(UISwipeGestureRecognizerDirection)direction andBlock:(UIGestureRecognizerBBlock)block;
```

###@interface UIGestureRecognizer(BBlock)

```obj-c
- (id)initWithBlock:(UIGestureRecognizerBBlock)block;
```

```obj-c
+ (id)gestureWithBlock:(UIGestureRecognizerBBlock)block;
```

##UIImage+BBlock.h

###@interface UIImage(BBlock)

Returns a `UIImage` rendered with the drawing code in the block.
This method does not cache the image object. 

```obj-c
+ (UIImage *)imageForSize:(CGSize)size withDrawingBlock:(void(^)())drawingBlock;
```

```obj-c
+ (UIImage *)imageForSize:(CGSize)size opaque:(BOOL)opaque withDrawingBlock:(void(^)())drawingBlock;
```

Returns a cached `UIImage` rendered with the drawing code in the block.
The `UIImage` is cached in an `NSCache` with the identifier provided. 

```obj-c
+ (UIImage *)imageWithIdentifier:(NSString *)identifier forSize:(CGSize)size andDrawingBlock:(void(^)())drawingBlock;
```

```obj-c
+ (UIImage *)imageWithIdentifier:(NSString *)identifier opaque:(BOOL)opaque forSize:(CGSize)size andDrawingBlock:(void(^)())drawingBlock;
```

