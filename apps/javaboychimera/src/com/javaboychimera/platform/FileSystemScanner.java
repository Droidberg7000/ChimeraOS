package com.javaboychimera.platform;

import com.javaboychimera.ui.RomSelectorScreen;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import java.util.Vector;
import java.util.Enumeration;
import net.rim.device.api.ui.UiApplication;

public final class FileSystemScanner implements Runnable {

    private final String targetDirectory;
    private final RomSelectorScreen callbackScreen;

    public FileSystemScanner(String targetDirectory, RomSelectorScreen callbackScreen) {
        this.targetDirectory = targetDirectory;
        this.callbackScreen = callbackScreen;
    }

    public void run() {
        FileConnection fc = null;
        Enumeration fileEnum = null;
        Vector foundUrls = new Vector();
        Vector foundNames = new Vector();
        String errorMsg = null;

        try {
            fc = (FileConnection) Connector.open(targetDirectory, Connector.READ);
            if (!fc.exists()) {
                errorMsg = "ROM directory not found on SDCard.";
            } else if (!fc.isDirectory()) {
                errorMsg = "Target is not a directory.";
            } else {
                fileEnum = fc.list("*", false);
                while (fileEnum.hasMoreElements()) {
                    String name = (String) fileEnum.nextElement();
                    String lower = name.toLowerCase();
                    if (lower.endsWith(".gb") || lower.endsWith(".gbc")) {
                        foundUrls.addElement(targetDirectory + name);
                        foundNames.addElement(name);
                    }
                }

                if (foundUrls.isEmpty()) {
                    errorMsg = "No .gb or .gbc ROMs found.";
                } else {
                    sortFiles(foundUrls, foundNames);
                }
            }
        } catch (java.io.IOException e) {
            errorMsg = "MicroSD card unreadable or missing.";
        } catch (Exception e) {
            errorMsg = "Storage scan failed: " + e.getMessage();
        } finally {
            try { if (fc != null) fc.close(); } catch (Exception ignored) {}
        }

        final ScanResult result = new ScanResult(foundUrls, foundNames, errorMsg);

        UiApplication.getUiApplication().invokeLater(new Runnable() {
            public void run() {
                callbackScreen.handleScanResults(result);
            }
        });
    }

    private static void sortFiles(Vector urls, Vector names) {
        int size = names.size();
        for (int i = 1; i < size; i++) {
            String currentName = (String) names.elementAt(i);
            String currentUrl = (String) urls.elementAt(i);
            int j = i - 1;

            while (j >= 0 && ((String) names.elementAt(j)).toLowerCase().compareTo(currentName.toLowerCase()) > 0) {
                names.setElementAt(names.elementAt(j), j + 1);
                urls.setElementAt(urls.elementAt(j), j + 1);
                j--;
            }
            names.setElementAt(currentName, j + 1);
            urls.setElementAt(currentUrl, j + 1);
        }
    }

    public static final class ScanResult {
        public final Vector urls;
        public final Vector names;
        public final String errorMessage;

        public ScanResult(Vector urls, Vector names, String errorMessage) {
            this.urls = urls;
            this.names = names;
            this.errorMessage = errorMessage;
        }
    }
}
