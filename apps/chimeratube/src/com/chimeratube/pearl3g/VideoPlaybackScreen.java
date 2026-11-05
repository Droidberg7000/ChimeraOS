package com.chimeratube.pearl3g;

import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.UiApplication;
import javax.microedition.media.Player;
import javax.microedition.media.Manager;
import javax.microedition.media.control.VideoControl;
import javax.microedition.media.control.VolumeControl;

public final class VideoPlaybackScreen extends MainScreen implements Runnable {

    private final String streamUrl;
    private final LabelField statusLabel;
    private Player player;
    private VideoControl videoControl;
    private VolumeControl volumeControl;
    private Field videoField;
    private boolean isClosing;

    public VideoPlaybackScreen(String streamUrl) {
        super(MainScreen.NO_VERTICAL_SCROLL | MainScreen.NO_HORIZONTAL_SCROLL);
        this.streamUrl = streamUrl;
        this.isClosing = false;

        statusLabel = new LabelField("Connecting to stream...", LabelField.ELLIPSIS);
        add(statusLabel);

        new Thread(this).start();
    }

    public void run() {
        try {
            updateStatus("Opening: " + streamUrl);

            String finalUrl = streamUrl;
            if (finalUrl.startsWith("http://") && finalUrl.indexOf(";deviceside=") == -1) {
                finalUrl = finalUrl + ";deviceside=true";
            }

            player = Manager.createPlayer(finalUrl);
            player.realize();

            videoControl = (VideoControl) player.getControl("VideoControl");
            if (videoControl != null) {
                videoField = (Field) videoControl.initDisplayMode(VideoControl.USE_GUI_PRIMITIVE, "net.rim.device.api.ui.Field");
                
                try {
                    videoControl.setDisplaySize(360, 270);
                } catch (Exception ignored) {}

                UiApplication.getUiApplication().invokeLater(new Runnable() {
                    public void run() {
                        if (!isClosing && videoField != null) {
                            deleteAll();
                            add(videoField);
                        }
                    }
                });
            }

            volumeControl = (VolumeControl) player.getControl("VolumeControl");
            if (volumeControl != null) {
                volumeControl.setLevel(80);
            }

            player.prefetch();
            player.start();

        } catch (final Exception e) {
            updateStatus("Error: " + e.getMessage());
        }
    }

    private void updateStatus(final String text) {
        UiApplication.getUiApplication().invokeLater(new Runnable() {
            public void run() {
                if (!isClosing) {
                    statusLabel.setText(text);
                }
            }
        });
    }

    public boolean onClose() {
        isClosing = true;
        closePlayer();
        return super.onClose();
    }

    private synchronized void closePlayer() {
        if (player != null) {
            try {
                player.stop();
                player.deallocate();
                player.close();
            } catch (Exception ignored) {}
            player = null;
        }
    }
}
