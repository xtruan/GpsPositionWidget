using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

(:glance)
class GpsPositionGlanceView extends Ui.GlanceView {
    
    function initialize() {
        GlanceView.initialize();
    }
    
    function onUpdate(dc) {
        // Set background color
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        
        var string = Ui.loadResource(Rez.Strings.AppName);
        
        // Check if position is valid
        // if (App.getApp().getLat() != 999 && App.getApp().getLon() != 999) {
        //     string = string + "!";
        // }
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        dc.drawText(
		        0, //dc.getWidth() / 2,                 // gets the width of the device and divides by 2
		        (dc.getHeight() / 2) - (Gfx.getFontHeight(Gfx.FONT_SMALL) / 2), // gets the height of the device and divides by 2
		        Gfx.FONT_SMALL,                         // sets the font size
		        string,                                 // the String to display
		        Gfx.TEXT_JUSTIFY_LEFT                   // sets the justification for the text
		           );
    }
}