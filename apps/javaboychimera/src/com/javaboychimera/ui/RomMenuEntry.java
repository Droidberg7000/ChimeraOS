package com.javaboychimera.ui;

public final class RomMenuEntry {
    public final String url;
    public final String fileName;

    public String title;
    public int mapperType;
    public int romSizeCode;
    public int ramSizeCode;
    public int cgbFlag;

    public boolean isParsed;
    public boolean isParsing;
    public boolean isEligibleForAdapterHandoff;
    public boolean headerChecksumValid;

    public RomMenuEntry(String url, String fileName) {
        this.url = url;
        this.fileName = fileName;
        this.title = "";
        this.mapperType = 0;
        this.romSizeCode = 0;
        this.ramSizeCode = 0;
        this.cgbFlag = 0;
        this.isParsed = false;
        this.isParsing = false;
        this.isEligibleForAdapterHandoff = false;
        this.headerChecksumValid = false;
    }

    public void parseHeaderBytes(byte[] rawHeader) {
        if (rawHeader == null || rawHeader.length < 0x50) {
            markAsMalformed();
            return;
        }

        StringBuffer sb = new StringBuffer();
        for (int i = 0x34; i <= 0x42; i++) {
            char b = (char) (rawHeader[i] & 0xFF);
            if (b == 0) break;
            if (b >= 32 && b <= 126) {
                sb.append(b);
            }
        }
        this.title = sb.toString().trim();

        this.cgbFlag = rawHeader[0x43] & 0xFF;
        this.mapperType = rawHeader[0x47] & 0xFF;
        this.romSizeCode = rawHeader[0x48] & 0xFF;
        this.ramSizeCode = rawHeader[0x49] & 0xFF;

        int computedChecksum = 0;
        for (int i = 0x34; i <= 0x4C; i++) {
            computedChecksum = (computedChecksum - (rawHeader[i] & 0xFF) - 1) & 0xFF;
        }

        int storedChecksum = rawHeader[0x4D] & 0xFF;
        this.headerChecksumValid = (computedChecksum == storedChecksum);
        this.isParsed = true;

        if (cgbFlag == 0xC0) {
            this.isEligibleForAdapterHandoff = false;
        } else if (cgbFlag != 0x00 && cgbFlag != 0x80 && (cgbFlag & 0x80) != 0) {
            this.isEligibleForAdapterHandoff = false;
        } else {
            this.isEligibleForAdapterHandoff = true;
        }
    }

    public void markAsMalformed() {
        this.cgbFlag = -1;
        this.isParsed = true;
        this.isEligibleForAdapterHandoff = false;
        this.headerChecksumValid = false;
    }

    public String getModeLabel() {
        if (!isParsed) return "Unverified";
        if (cgbFlag == -1) return "Malformed header";
        if (cgbFlag == 0xC0) return "CGB-only";
        if (cgbFlag == 0x80) return "CGB-enhanced";
        if (cgbFlag == 0x00) return "DMG-compatible";
        return "CGB flag 0x" + Integer.toHexString(cgbFlag).toUpperCase();
    }

    public String toString() {
        return fileName;
    }
}
