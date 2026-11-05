package com.javaboychimera.ui;

public final class InputDeviceBridge {

    public static final int BUTTON_A      = 1 << 0;
    public static final int BUTTON_B      = 1 << 1;
    public static final int BUTTON_SELECT = 1 << 2;
    public static final int BUTTON_START  = 1 << 3;
    public static final int PAD_RIGHT     = 1 << 4;
    public static final int PAD_LEFT      = 1 << 5;
    public static final int PAD_UP        = 1 << 6;
    public static final int PAD_DOWN      = 1 << 7;

    private int activeInputMask = 0;

    public boolean processCharacter(char keyChar, boolean isPressed) {
        int targetBit = 0;

        switch (keyChar) {
            case 'w': case 'W': case '2': targetBit = PAD_UP; break;
            case 's': case 'S': case '8': targetBit = PAD_DOWN; break;
            case 'a': case 'A': case '4': targetBit = PAD_LEFT; break;
            case 'd': case 'D': case '6': targetBit = PAD_RIGHT; break;

            case 'l': case 'L': case '5': case 't': case 'T': targetBit = BUTTON_A; break;
            case 'k': case 'K': case '7': case 'u': case 'U': targetBit = BUTTON_B; break;

            case 'z': case 'Z': case '*': targetBit = BUTTON_SELECT; break;
            case 'x': case 'X': case '#': case '\n': case '\r': targetBit = BUTTON_START; break;

            default:
                return false;
        }

        if (isPressed) {
            activeInputMask |= targetBit;
        } else {
            activeInputMask &= ~targetBit;
        }
        return true;
    }

    public int getActiveInputMask() {
        return this.activeInputMask;
    }

    public void resetInputMask() {
        this.activeInputMask = 0;
    }
}
