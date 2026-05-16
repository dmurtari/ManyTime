# ManyTime

A Menu Bar time app for macOS, to help keep track of times in multiple time zones. 

There's no notarized version (yet?) since I haven't committed to paying for an Apple Developer account... maybe someday.

<img src="images/screenshot.png" width="300">

## Help

### First Launch

On first launch, there won't be any timezones shown yet. To add them, go to 'Options' > 'Preferences' (Or type Cmd + ,). From there, you'll be able to manage and add new timezones. 

**Whatever timezone is _first_ in the list will be shown in the Menu Bar**

### Time Formats

You can choose to set the format for the time shown in the Menu Bar, and the time shown in the dropdown window, independently. I use this to show more information in the Menu Bar (like the screenshot)

There are a few presets you can choose from, but you may find the Custom option most useful. The time formats are SwiftUI's standard [Unicode format](https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Format_Patterns)

For example, to show `Denver: Fri 22:00`, I use the string `'Denver:' E HH:mm`

