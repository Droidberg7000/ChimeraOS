package com.javaboychimera.ui;

import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.ObjectListField;
import net.rim.device.api.ui.component.ButtonField;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.FieldChangeListener;
import net.rim.device.api.ui.Keypad;
import net.rim.device.api.ui.UiApplication;
import com.javaboychimera.platform.FileSystemScanner;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import java.io.InputStream;

public final class RomSelectorScreen extends MainScreen implements FieldChangeListener {

    private final LabelField statusLabel;
    private final ObjectListField romListField;
    private final LabelField metadataLabel;
    private final ButtonField inspectButton;
    private final InputDeviceBridge inputBridge;
    private boolean isScanning;

    public RomSelectorScreen() {
        super(MainScreen.VERTICAL_SCROLL | MainScreen.VERTICAL_SCROLLBAR);
        setTitle("JavaBoyChimera");

        statusLabel = new LabelField("Initializing...", LabelField.ELLIPSIS);
        romListField = new ObjectListField();
        romListField.setChangeListener(this);

        metadataLabel = new LabelField("", LabelField.BR_TO_SPACE);

        inspectButton = new ButtonField("Verify ROM Header", ButtonField.CONSUME_CLICK);
        inspectButton.setChangeListener(this);
        inspectButton.setEditable(false);

        add(statusLabel);
        add(romListField);
        add(metadataLabel);
        add(inspectButton);

        inputBridge = new InputDeviceBridge();
        isScanning = false;
        triggerStorageScan("file:///SDCard/JavaBoy/");
    }

    private void triggerStorageScan(String targetDirectory) {
        if (isScanning) return;
        isScanning = true;
        statusLabel.setText("Scanning /SDCard/JavaBoy/...");
        new Thread(new FileSystemScanner(targetDirectory, this)).start();
    }

    public void handleScanResults(FileSystemScanner.ScanResult result) {
        isScanning = false;
        if (result.errorMessage != null) {
            statusLabel.setText("Status: " + result.errorMessage);
            romListField.set(new RomMenuEntry[0]);
            return;
        }

        int count = result.urls.size();
        statusLabel.setText("Status: " + count + " ROM(s) found");

        RomMenuEntry[] items = new RomMenuEntry[count];
        for (int i = 0; i < count; i++) {
            items[i] = new RomMenuEntry((String) result.urls.elementAt(i), (String) result.names.elementAt(i));
        }
        romListField.set(items);
        fieldChanged(romListField, FieldChangeListener.PROGRAMMATIC);
    }

    public void fieldChanged(Field field, int context) {
        if (field == romListField) {
            int selectedIndex = romListField.getSelectedIndex();
            if (selectedIndex >= 0 && selectedIndex < romListField.getSize()) {
                RomMenuEntry selectedEntry = (RomMenuEntry) romListField.get(romListField, selectedIndex);
                if (!selectedEntry.isParsed && !selectedEntry.isParsing) {
                    asyncProbeHeader(selectedEntry, selectedIndex);
                } else {
                    updateUiForEntry(selectedEntry);
                }
            }
        } else if (field == inspectButton) {
            int selectedIndex = romListField.getSelectedIndex();
            if (selectedIndex >= 0) {
                RomMenuEntry activeEntry = (RomMenuEntry) romListField.get(romListField, selectedIndex);
                if (activeEntry.isParsed) {
                    Dialog.alert("Cartridge Verified:\n" + activeEntry.title 
                        + "\nMapper: 0x" + Integer.toHexString(activeEntry.mapperType).toUpperCase()
                        + "\nChecksum: " + (activeEntry.headerChecksumValid ? "VALID" : "INVALID"));
                }
            }
        }
    }

    private void asyncProbeHeader(final RomMenuEntry targetEntry, final int listIndex) {
        targetEntry.isParsing = true;
        inspectButton.setEditable(false);
        metadataLabel.setText("Reading cartridge header...");

        new Thread(new Runnable() {
            public void run() {
                FileConnection fc = null;
                InputStream is = null;
                byte[] headerBlock = new byte[80];
                boolean success = false;

                try {
                    fc = (FileConnection) Connector.open(targetEntry.url, Connector.READ);
                    if (fc.exists() && fc.fileSize() >= 0x0150) {
                        is = fc.openInputStream();
                        long skipped = 0;
                        while (skipped < 0x0100) {
                            long skipAmount = is.skip(0x0100 - skipped);
                            if (skipAmount <= 0) break;
                            skipped += skipAmount;
                        }

                        if (skipped == 0x0100) {
                            int totalRead = 0;
                            while (totalRead < 80) {
                                int readBytes = is.read(headerBlock, totalRead, 80 - totalRead);
                                if (readBytes == -1) break;
                                totalRead += readBytes;
                            }
                            if (totalRead == 80) {
                                success = true;
                            }
                        }
                    }
                } catch (Exception e) {
                    success = false;
                } finally {
                    try { if (is != null) is.close(); } catch (Exception ignored) {}
                    try { if (fc != null) fc.close(); } catch (Exception ignored) {}
                }

                final boolean finalSuccess = success;
                final byte[] finalHeader = headerBlock;

                UiApplication.getUiApplication().invokeLater(new Runnable() {
                    public void run() {
                        targetEntry.isParsing = false;
                        if (finalSuccess) {
                            targetEntry.parseHeaderBytes(finalHeader);
                        } else {
                            targetEntry.markAsMalformed();
                        }

                        if (romListField.getSelectedIndex() == listIndex) {
                            updateUiForEntry(targetEntry);
                        }
                    }
                });
            }
        }).start();
    }

    private void updateUiForEntry(RomMenuEntry entry) {
        metadataLabel.setText(formatMetadata(entry));
        inspectButton.setEditable(entry.isEligibleForAdapterHandoff);
    }

    private static String formatMetadata(RomMenuEntry entry) {
        if (entry.isParsing) return "Parsing status pending...";
        if (!entry.isParsed) return "Unverified cartridge file.";
        if (entry.cgbFlag == -1) return "Title: " + entry.fileName + "\nError: Inaccessible or corrupted header.";

        return "Title: " + entry.title + "\n"
            + "Mapper: 0x" + Integer.toHexString(entry.mapperType).toUpperCase() + "\n"
            + "Mode: " + entry.getModeLabel() + "\n"
            + "Checksum: " + (entry.headerChecksumValid ? "PASS (Valid)" : "FAIL (Mismatch)");
    }

    protected boolean keyDown(int keycode, int time) {
        char keyChar = Keypad.getAlphanumericKey(keycode);
        if (inputBridge.processCharacter(keyChar, true)) {
            return true;
        }
        return super.keyDown(keycode, time);
    }

    protected boolean keyUp(int keycode, int time) {
        char keyChar = Keypad.getAlphanumericKey(keycode);
        if (inputBridge.processCharacter(keyChar, false)) {
            return true;
        }
        return super.keyUp(keycode, time);
    }
}
