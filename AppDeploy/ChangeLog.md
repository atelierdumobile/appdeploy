AppBuilder
==========

Allow to deploy beta from xcarchive Xcode build-in system and apk basic support for Android.

ChangeLog
==========
#4.2/51
- Fix bug about the script section
- Rename default template file
- Add key for template & server to allow easy usage on script
- Minor bug fixes and text corrections

#4.1/50
- Fix Android issue concerning the detection of the app label
- Android: support for architecture display and locales display in about more information

#4.0/49
- IPA displays provisionning profile & signing information
- Change name to AppDeploy
- Compatibility starting OSX 10.10

#3.1/48
- Distinguish sound success to sound error
- Several bug fix
- Configuration with no network by default
- Settings : new android section, add terminal section, add help for network, documentaiton template
- Update templates tags

#3.0.4/46
- Android : detect ic_launcher whern stored in mipmap folder

#3.0.2/44
- Commun: fix export encoding issue that prevent to generate file.

#3.0.1/43
- Android: improve icone selection for better quality
- Android: fix issue with packagename parsing when _ in the name

#3.0.0/41
- Android now use Aapt to get information about the apk to distribute (taking the bundleid, version, sdk…)
- Adding new value template [[OS_MIN]], [[SDK]], [[BUNDLE_IDENTIFIER]]
- Aapt file is now configurable through the configuration file (and is readonly through the pref yet) 

#2.9.9/40
- Internal Android icone usage 

#2.9.8/39
- Fix url to app binary provided in output command line generation
- export : export the bundleidentifier

#2.9.8/38
- Adding --export=filepath.properties to export some property info about the package
- Template can fill the uniqueintegration number with [[IC_UNIQUE_NUMBER]] value

#2.9.7/37
- IC : using --build_number=20 parameter will use has a subfolder the argument provided instead of the technical build number 
- add integration for support ADM_IC

#2.9.6/36
- update UI to clarity and support network config local
- fix & update command line support to use template and network settings

#2.9.5/35
- update command line support to use configuration

#2.9/34
- Fix ipa detection support

#2.9/33
- Fix template item preference
- Reorganize menu
- Add item "Generate template without binary"
- Add logo url for template

#2.9/32
- Sparkel auto-update

#2.9/31
- Fix issue on 10.9
- Block add new network in adm releases

#2.9/30
- Improve menus && enable in context
- Add shortcut when pressing "cmd" allows to resend the build without regenerating the archive
- Network: support ssh passwordless but no progress bar in such cases
- Network setting : support duplicate label name
- Network : transfert return a error code
- Network & batch : cancelable tasks

#2.8/29
- Change xcarchive build method to support entitlements
- Default ADM config adding
- Use external configuration with global settings including (except the integration services)
- Add icone to app
- Ipa Icone support
- Display Entitlements for ipa & xcarchive

#2.7/28
- New settings to handle network configuration
- New settings to handle template & template preview

#2.6/27
- Restore support for beta & release
- Allow to define a custom output directory
- HipChat support

#2.5/26
- New template with app icone

#2.3.7/25
- Adding a template section in settings
- Date format choosable in the template preference.

#v2.3.6/24
- Display date
- Bugfix for data display when switching app
- Adding fast open url, copy board & notification with shortcuts
- Adding open of mobile provisionning profile
- Xcode setting
- UI enlarge window width

#v2.3.5/22
- adding hardcoded setting and disable settings
- android basic ui fix

#v2.3.0/21
- url is now with the technical version url and not the functionnal version url

#v2.2.0/20
- size of file
- improved settings with credentials

#v2.1.0/18
- support basique CLI
- support ipa

#v2.0.3/17
- drag and drop supported for xcarchive & apk file
- display file source in title

#v2.0.2/16
- wording update
- fix a problem with prowl due to Android implementation
- the "open build folder" button is available as soon as the build is signed (vs when uploaded)
- add extra information when click on the app icone: (sdk, minimum version, app store size)

#v2.0.1/15
- display the CFBundleVersion in the html page (which is the technical version unique identifier of a build)

#v2.0/12
- android support & ios adjustments

#v.9.5/10
- Code refactor
- Name is normalized in lowercase with only normal caracter (letter & number _-)
- Settings for opening or not build folder automatically after a deployment
- Local notification is done at the end of a deployement

#v0.9
- Update preference to support :
 - Can open temporary folder for cleaning
- Automatic last archive check at startup

#v0.8.5
- You can disable prowl notification
- Logs are available in the console
- Remove a certification sigature error which is not blocking anymore on OSX10.9.5

#v0.8
- Network : add a progress status for upload
- Network : catch network errors

#v0.7
- Add on home "last archive detection"
- Fix back button bad state

#v0.6
- Add prowl support
- Add bip at the end of the build

#v0.5
- Add asynchrone task and success status

#v0.3
- Fix for iOS7.1 SSL issue
- Sign the app using the embedded provisionning profile
