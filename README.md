# GPS Position (Widget)
GPS Position Widget for Garmin ConnectIQ - https://apps.garmin.com/en-US/apps/d46d47fe-57b9-45ab-b4cd-c12f499be97e

Simple widget to display current position information in a variety of different formats:
* Lat/Long in Degrees
* Lat/Long in Degrees/Mins
* Lat/Long in Degrees/Mins/Secs
* UTM (WGS84)
* USNG (WGS84)
* MGRS (WGS84)
* QTH Locator (Maidenhead / IARU)
* UK Grid (OSGB36)
* Swiss Grid (LV95)
* Swiss Grid (LV03)
* SK-42 (Degrees)
* SK-42 (Orthogonal)

Color of position text indicates GPS signal strength. Color of battery text indicates battery life. UTM/USNG/MGRS positions are using NAD83/WGS84 datum, UK Grid (Ordnance Survey National Grid) positions is using OSGB36 datum.

***NOTE: GPS must be turned on first by going to Settings - Sensors - GPS

Tested on simulator for all supported devices and on Forerunner 55 hardware.

Changelog:
* 3.1.4 - Added SK-42 formats.
* 3.1.1 - Better GNSS constellation support.
* 3.1.0 - Added Swiss grid. Major refactor/cleanup. Glance View supports all formats!
* 3.0.9 - Added Maidenhead Locator/QTH Locator/IARU Locator. Heading now displays in mil in MGRS mode.
* 3.0.8 - GPS signal indicator for Instinct 2/2S.
* 3.0.7 - Using built-in CIQ function for MGRS. If you notice issues, use USNG format instead. They should be identical. Refactored out GPS formatting into separate class.
* 3.0.6 - Added degree sign to Degrees, DM, and DMS formats.
* 3.0.5 - Added support for Instinct 2/2S.
* 3.0.4 - Degrees, DM, and DMS are now visible on Glance View. If another format is selected, degrees will be shown.
* 3.0.2 - Changed storage mode to work with CIQ 4.0.0 and above.
* 3.0.1 - Added progress dots animation.
* 3.0.0 - Initial release as a Widget. For the Application version, see: https://apps.garmin.com/en-US/apps/12097123-2f57-4d59-afd7-2887c54c0732