# GPS Position (Widget)
GPS Position Widget for Garmin ConnectIQ - https://apps.garmin.com/en-US/apps/d46d47fe-57b9-45ab-b4cd-c12f499be97e

Simple widget to display current position information in a variety of different formats. Color of position text indicates GPS signal strength, color of battery text indicates battery life. UTM/USNG/MGRS positions are using NAD83/WGS84 datum, UK Grid (Ordnance Survey National Grid) positions is using OSGB36 datum.

***NOTE: GPS must be turned on first by going to Settings - Sensors - GPS

Tested on simulator for all supported devices and on Forerunner 55 hardware.

Changelog:
* 3.0.8 - GPS signal indicator for Instinct 2/2S.
* 3.0.7 - Using built-in CIQ function for MGRS. If you notice issues, use USNG format instead. They should be identical. Refactored out GPS formatting into separate class.
* 3.0.6 - Added degree sign to Degrees, DM, and DMS formats.
* 3.0.5 - Added support for Instinct 2/2S.
* 3.0.4 - Degrees, DM, and DMS are now visible on Glance View. If another format is selected, degrees will be shown.
* 3.0.2 - Changed storage mode to work with CIQ 4.0.0 and above.
* 3.0.1 - Added progress dots animation.
* 3.0.0 - Initial release as a Widget. For the Application version, see: https://apps.garmin.com/en-US/apps/12097123-2f57-4d59-afd7-2887c54c0732