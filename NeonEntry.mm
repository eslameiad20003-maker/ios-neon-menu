// NeonEntry.mm
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

extern "C" void RenderNeonMenu(void);
extern "C" void ToggleMenu(void);

// دالة مساعدة للبحث عن النافذة الرئيسية للعبة
static UIWindow* GetKeyWindow() {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                    if (window.isKeyWindow) return window;
                }
            }
        }
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
    return nil;
}

// إعداد ImGui (يجب استدعاؤها بمجرد توفر سياق الرسم للعبة)
static void SetupImGui() {
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.IniFilename = NULL; // تعطيل حفظ الإعدادات لتجنب مشاكل المسارات
    // ملاحظة: يجب ربط الـ Backend (مثل Metal أو OpenGL) هنا حسب محرك اللعبة
}

// دالة إنشاء الزر العائم
static void CreateFloatingButton() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = GetKeyWindow();
        if (!keyWindow) {
            // إعادة المحاولة إذا لم تكن النافذة جاهزة
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CreateFloatingButton();
            });
            return;
        }
        
        // إنشاء الزر (أيقونة حمراء شفافة)
        UIButton *floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatBtn.frame = CGRectMake(keyWindow.bounds.size.width - 70, keyWindow.bounds.size.height / 2, 50, 50);
        floatBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.0 blue:0.0 alpha:0.8];
        floatBtn.layer.cornerRadius = 25;
        floatBtn.layer.borderWidth = 2.0;
        floatBtn.layer.borderColor = [UIColor redColor].CGColor;
        [floatBtn setTitle:@"N" forState:UIControlStateNormal];
        [floatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        floatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        
        // إضافة حدث الضغط
        [floatBtn addTarget:[NeonHelper class] action:@selector(onFloatButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        // إضافة حدث السحب
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[NeonHelper class] action:@selector(handlePan:)];
        [floatBtn addGestureRecognizer:pan];
        
        [keyWindow addSubview:floatBtn];
        [keyWindow bringSubviewToFront:floatBtn];
    });
}

// كلاس مساعد للتعامل مع الأحداث في Objective-C
@interface NeonHelper : NSObject
+ (void)onFloatButtonTapped;
+ (void)handlePan:(UIPanGestureRecognizer *)gesture;
@end

@implementation NeonHelper
+ (void)onFloatButtonTapped {
    // تبديل ظهور القائمة
    ToggleMenu();
}

+ (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    CGPoint translation = [gesture translationInView:view.superview];
    view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:view.superview];
}
@end

// نقطة الدخول (Constructor) التي تعمل بمجرد حقن الملف
__attribute__((constructor))
static void NeonEntryPoint() {
    NSLog(@"[NeonMenu] Dylib loaded. Waiting 5 seconds...");
    
    // الانتظار 5 ثوانٍ لضمان تحميل اللعبة بالكامل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[NeonMenu] Initializing UI...");
        SetupImGui();
        CreateFloatingButton();
        
        // ملاحظة: يجب عليك استدعاء RenderNeonMenu() داخل حلقة الرسم الخاصة باللعبة (Render Loop)
        // يمكنك استخدام CADisplayLink هنا لتحديث الواجهة
    });
}
