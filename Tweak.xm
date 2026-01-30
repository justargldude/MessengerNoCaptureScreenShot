#import <UIKit/UIKit.h>

// Chỉ giữ lại Hook quan trọng nhất và an toàn nhất
%hook UIScreen
- (BOOL)isCaptured {
    // Luôn trả về NO để đánh lừa mọi logic quay/chụp màn hình
    return NO; 
}
%end

%hook MSGQuicksnapScreenCaptureProtectedView
- (void)didMoveToWindow {
    %orig;
    self.hidden = YES;
    self.alpha = 0;
}
%end

%hook NSNotificationCenter
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject {
    // Chặn thông báo chụp ảnh một cách im lặng
    if ([aName isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"] ||
        [aName isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
        return; 
    }
    %orig;
}
%end

%ctor {
    NSLog(@"[Bypass] Tweak Active!");
}
