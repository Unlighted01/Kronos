#include <windows.h>
#include <cstdlib>

// A tiny, silent Win32 application that forces a specific HWND to be Topmost
int main(int argc, char* argv[]) {
    if (argc < 3) return 1;
    
    // Get the exact Window Handle (HWND) passed by Godot
    HWND hwnd = (HWND)_atoi64(argv[1]);
    int state = atoi(argv[2]); // 1 for Topmost, 0 for Not Topmost
    
    if (state == 1) {
        SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    } else {
        SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
    }
    
    return 0;
}
