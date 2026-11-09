// NeonMenu.mm
#import <UIKit/UIKit.h>
#include "imgui.h"

// متغيرات الحالة (يمكنك ربطها بوظائف اللعبة لاحقاً)
static bool g_ShowMenu = false;
static bool g_Toggle_GodMode = false;
static bool g_Toggle_Speed = false;
static bool g_Toggle_Aimbot = false;
static bool g_Toggle_ESP = false;
static ImFont* g_ArabicFont = nullptr;

// إعداد ستايل النيون (أسود وخلفية حمراء)
static void SetupNeonStyle() {
    ImGuiStyle& style = ImGui::GetStyle();
    style.WindowRounding = 10.0f;
    style.FrameRounding = 5.0f;
    style.WindowBorderSize = 2.0f;
    style.FrameBorderSize = 1.0f;
    style.ItemSpacing = ImVec2(10, 8);
    
    // الألوان
    style.Colors[ImGuiCol_WindowBg] = ImVec4(0.02f, 0.02f, 0.02f, 0.95f); // أسود غامق
    style.Colors[ImGuiCol_Border] = ImVec4(0.8f, 0.1f, 0.1f, 1.0f); // أحمر نيون
    style.Colors[ImGuiCol_Text] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f); // أبيض
    style.Colors[ImGuiCol_Button] = ImVec4(0.1f, 0.1f, 0.1f, 1.0f); // زر رمادي داكن
    style.Colors[ImGuiCol_ButtonHovered] = ImVec4(0.3f, 0.0f, 0.0f, 1.0f); // زر أحمر عند التمرير
    style.Colors[ImGuiCol_ButtonActive] = ImVec4(0.5f, 0.0f, 0.0f, 1.0f); // زر أحمر عند الضغط
}

// تحميل الخط العربي (تأكد من وجود ملف الخط في المشروع)
static void LoadArabicFont() {
    ImGuiIO& io = ImGui::GetIO();
    // يفضل استخدام خط يدعم العربية مثل NotoNaskhArabic أو Cairo
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"Cairo-Regular" ofType:@"ttf"]; 
    if (fontPath) {
        ImFontConfig config;
        config.OversampleH = 2;
        config.OversampleV = 2;
        static const ImWchar ranges[] = {
            0x0020, 0x00FF, // Basic Latin
            0x0600, 0x06FF, // Arabic
            0,
        };
        g_ArabicFont = io.Fonts->AddFontFromFileTTF([fontPath UTF8String], 18.0f, &config, ranges);
    } else {
        io.Fonts->AddFontDefault(); // خط احتياطي
    }
}

// دالة رسم زر بنمط الصورة (أيقونة + نص)
static void DrawMenuButton(const char* label, bool* toggle, const char* icon = "") {
    ImGui::PushID(label);
    // تأثير الحواف الحمراء للزر
    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.15f, 0.05f, 0.05f, 1.0f));
    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.4f, 0.0f, 0.0f, 1.0f));
    
    char buffer[256];
    if (icon[0] != '\0') {
        sprintf(buffer, "%s %s", icon, label);
    } else {
        sprintf(buffer, "%s", label);
    }

    if (ImGui::Button(buffer, ImVec2(ImGui::GetContentRegionAvail().x, 35))) {
        *toggle = !(*toggle);
    }
    ImGui::PopStyleColor(2);
    
    // رسم خط أحمر سفلي بسيط كتأثير نيون
    ImDrawList* draw_list = ImGui::GetWindowDrawList();
    ImVec2 p = ImGui::GetItemRectMin();
    ImVec2 size = ImGui::GetItemRectSize();
    draw_list->AddRectFilled(ImVec2(p.x, p.y + size.y - 2), ImVec2(p.x + size.x, p.y + size.y), ImColor(255, 0, 0, 255));
    
    ImGui::PopID();
}

extern "C" void RenderNeonMenu() {
    if (!g_ShowMenu) return;
    
    static bool initialized = false;
    if (!initialized) {
        SetupNeonStyle();
        LoadArabicFont();
        initialized = true;
    }
    
    if (g_ArabicFont) ImGui::PushFont(g_ArabicFont);
    
    // تحديد حجم وموقع القائمة (على اليمين كما في الصورة)
    ImGui::SetNextWindowSize(ImVec2(320, 550), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(20, 50), ImGuiCond_FirstUseEver);
    
    // إطار أحمر مضيء
    ImGui::PushStyleColor(ImGuiCol_Border, ImVec4(1.0f, 0.0f, 0.0f, 1.0f));
    
    ImGui::Begin(u8"التحكم", &g_ShowMenu, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
    
    // --- كلمة افيونه المطلوبة ---
    ImGui::SetCursorPosX((ImGui::GetWindowWidth() - ImGui::CalcTextSize("افيونه").x) * 0.5f);
    ImGui::TextColored(ImVec4(1.0f, 0.2f, 0.2f, 1.0f), u8"افيونه"); 
    ImGui::Separator();
    // ---------------------------

    // --- القسم الأول: التحكم ---
    ImGui::TextColored(ImVec4(0.8f, 0.2f, 0.2f, 1.0f), u8"التحكم");
    DrawMenuButton(u8"اطلاق الهوست وخذ مكانه", &g_Toggle_GodMode, u8"🌐");
    DrawMenuButton(u8"شيل الهوست", &g_Toggle_Speed, u8"🔒");
    DrawMenuButton(u8"خلي حد هوست", &g_Toggle_Aimbot, u8"🔴");
    DrawMenuButton(u8"اطرد لاعب", &g_Toggle_ESP, u8"💧");
    
    ImGui::Spacing();

    // --- القسم الثاني: الشات والهوية ---
    ImGui::TextColored(ImVec4(0.8f, 0.2f, 0.2f, 1.0f), u8"الشات والهوية");
    DrawMenuButton(u8"شات وهمي", &g_Toggle_GodMode, u8"👤");
    DrawMenuButton(u8"خذ هوية", &g_Toggle_Speed, u8"👁️");
    DrawMenuButton(u8"سبام شات", &g_Toggle_Aimbot, u8"📝");
    DrawMenuButton(u8"غير هويات الكل", &g_Toggle_ESP, u8"👁️");
    DrawMenuButton(u8"CRASHED", &g_Toggle_ESP, u8"⭕"); // تمت إضافته بناء على الصورة

    ImGui::Spacing();

    // --- القسم الثالث: الأدوات ---
    ImGui::TextColored(ImVec4(0.8f, 0.2f, 0.2f, 1.0f), u8"الأدوات");
    DrawMenuButton(u8"إدارة البالد", &g_Toggle_GodMode, u8"🔒");
    DrawMenuButton(u8"طرد تلقائي: مقفول", &g_Toggle_Speed, u8"💧");
    DrawMenuButton(u8"انقاذ: مقفول", &g_Toggle_Aimbot, u8"🔴");
    DrawMenuButton(u8"عكس الهجوم: مقفول", &g_Toggle_ESP, u8"👁️");
    DrawMenuButton(u8"القائمة السوداء", &g_Toggle_ESP, u8"🔒");
    DrawMenuButton(u8"البروفايلات", &g_Toggle_ESP, u8"👁️");

    ImGui::Separator();
    ImGui::Spacing();
    
    // زر الإغلاق
    if (ImGui::Button(u8"إغلاق القائمة", ImVec2(-1, 40))) {
        g_ShowMenu = false;
    }
    
    ImGui::End();
    ImGui::PopStyleColor();
    
    if (g_ArabicFont) ImGui::PopFont();
}

extern "C" void ToggleMenu() {
    g_ShowMenu = !g_ShowMenu;
}
