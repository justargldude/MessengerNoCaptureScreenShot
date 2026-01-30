// Tweak.xm - ScreenCaptureBypass v6.0 (ULTRA MINIMAL)
#import <UIKit/UIKit.h>

// CHỈ CÓ 1 HOOK DUY NHẤT - KHÔNG THỂ CRASH
%hook UIScreen
- (BOOL)isCaptured {
    return NO;
}
%end

%ctor {
    %init;
}
