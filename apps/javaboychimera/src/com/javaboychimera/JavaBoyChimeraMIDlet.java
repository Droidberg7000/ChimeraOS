package com.javaboychimera;

import javax.microedition.midlet.MIDlet;
import javax.microedition.midlet.MIDletStateChangeException;
import net.rim.device.api.ui.UiApplication;
import com.javaboychimera.ui.RomSelectorScreen;

public final class JavaBoyChimeraMIDlet extends MIDlet {

    private AppInstance app;

    protected void startApp() throws MIDletStateChangeException {
        if (app == null) {
            app = new AppInstance();
            app.enterEventDispatcher();
        }
    }

    protected void pauseApp() {}

    protected void destroyApp(boolean unconditional) {
        if (app != null) {
            app = null;
        }
    }

    private static final class AppInstance extends UiApplication {
        AppInstance() {
            pushScreen(new RomSelectorScreen());
        }
    }
}
