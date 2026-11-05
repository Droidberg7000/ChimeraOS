package com.chimeratube.pearl3g;

import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.ObjectListField;
import net.rim.device.api.ui.component.ButtonField;
import net.rim.device.api.ui.component.EditField;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.FieldChangeListener;
import net.rim.device.api.ui.UiApplication;

public final class MainFeedScreen extends MainScreen implements FieldChangeListener {

    private final EditField urlField;
    private final ObjectListField feedList;
    private final ButtonField playButton;
    private final ButtonField reloadButton;

    private static final String[] PRESET_TITLES = new String[] {
        "Sample 3GP Video (HTTP Progressive)",
        "RTSP Live Stream Endpoint",
        "Custom RTSP / HTTP URL"
    };

    private static final String[] PRESET_URLS = new String[] {
        "http://files.chimeratube.org/streams/sample_360x400.3gp",
        "rtsp://media.chimeratube.org/live/stream.sdp",
        ""
    };

    public MainFeedScreen() {
        super(MainScreen.VERTICAL_SCROLL | MainScreen.VERTICAL_SCROLLBAR);
        setTitle("ChimeraTube (Pearl 3G)");

        LabelField header = new LabelField("Select Video Stream (3GP / RTSP):", LabelField.ELLIPSIS);
        add(header);

        feedList = new ObjectListField();
        feedList.set(PRESET_TITLES);
        feedList.setChangeListener(this);
        add(feedList);

        urlField = new EditField("Stream URL: ", "http://files.chimeratube.org/streams/sample_360x400.3gp");
        add(urlField);

        playButton = new ButtonField("Play Video", ButtonField.CONSUME_CLICK);
        playButton.setChangeListener(this);
        add(playButton);

        reloadButton = new ButtonField("Reload Feed", ButtonField.CONSUME_CLICK);
        reloadButton.setChangeListener(this);
        add(reloadButton);
    }

    public void fieldChanged(Field field, int context) {
        if (field == feedList) {
            int idx = feedList.getSelectedIndex();
            if (idx >= 0 && idx < PRESET_URLS.length && PRESET_URLS[idx].length() > 0) {
                urlField.setText(PRESET_URLS[idx]);
            }
        } else if (field == playButton) {
            String targetUrl = urlField.getText().trim();
            if (targetUrl.length() == 0) {
                Dialog.alert("Please provide a valid stream URL.");
                return;
            }
            UiApplication.getUiApplication().pushScreen(new VideoPlaybackScreen(targetUrl));
        } else if (field == reloadButton) {
            Dialog.inform("Feed updated.");
        }
    }
}
