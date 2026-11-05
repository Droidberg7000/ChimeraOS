package com.chimeratube.pearl3g;

import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;
import net.rim.device.api.ui.UiApplication;

public final class Pearl3GChimeraTubeMIDlet extends MIDlet {

    private ChimeraTubeApp app;

    protected void startApp() throws MIDletStateChangeException {
        if (app == null) {
            app = new ChimeraTubeApp();
            app.enterEventDispatcher();
        }
    }

    protected void pauseApp() {}

    protected void destroyApp(boolean unconditional) {
        if (app != null) {
            app = null;
        }
    }

    private static final class ChimeraTubeApp extends UiApplication {
        ChimeraTubeApp() {
            pushScreen(new MainFeedScreen());
        }
    }
}
