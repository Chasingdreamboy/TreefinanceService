
#import "TBSPlugin.h"

@interface TBSControllerPlugin : TBSPlugin {
    // Member variables go here.
}

- (void)push:(NSDictionary*)command;
- (void)pop:(NSDictionary*)command;
- (void)popTo:(NSDictionary*)command;
- (void)exit:(NSDictionary*)command;
- (void)logout:(NSDictionary*)command;
- (void)refresh:(NSDictionary *)command;

@end
