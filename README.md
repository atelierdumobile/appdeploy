![Png](ReadmeData/AppDeployLogo.png)

Visualize, templatized and deploy your app in a second.
============

AppDeploy is the fastest way to get info and deploy your mobile app Over The Air without specific server configuration (it only uses html).

## Features
- [x] ✨ Get quick info on your iOS and Android App (support of .xcarchive, .ipa and .apk)
- [x] 🗃 iOS: Get fast access to your app resources, plist, embbeded profiles…
- [x] 🚨 iOS: Get notified when an xcarchive is built
- [x] 🌅 Use default template (branded or with app icon) or customize your own one
- [x] 🚀 Deploy to your server without extra configuration just html support is required
- [x] 🎉 Notify build&deployment success with Hipchat or Prowl
- [x] 🚠 Integrate it in your Continuous Integration by using the command line
- [x] 📲 Download the app with a versioned url

## Current usage
- Currently used in our production toolchain with a Jenkins building the app with gym (fastlane) and AppDeploy is generating the download page in script mode from the .ipa or .apk file.
- It is also nice to have info quickly on App by double clicking the files (requires to define AppDeploy as the default App to open your ipa/apk/xarchive files).

## Download and installation
You can build or download a ready to use version available and stay automatically up to date thanks to Sparkle. [Download here](https://www.atelierdumobile.com/apps/releases/appdeploy)

## Requirements
- A mac with OSX10.10

## Presentation

#### Supported files
Drag any apk, xcarchive, ipa

![Gifs](ReadmeData/SupportedFiles.gif)


#### Choose the template you like
You have default template and you can create the one that fits your needs.
![Gifs](ReadmeData/AnyTemplateYouWant.gif)


#### Deploy in a click
Choose your template and network config and deploy.

![Gifs](ReadmeData/ipa.gif)

![Gifs](ReadmeData/apk.gif)

#### Full integration with Xcode archive
Archive -> AppDeploy detects the archive and allow you to handle it.
![Gifs](ReadmeData/FullWorkflow.gif)


#### Rich settings and options
Discovers the settings and discovers the settings and possible customization.
![Png](ReadmeData/SettingsTerminal.png)


## Possible Improvements (feedback appreciated)

Display

	- Display more information such as size of resources and repartition
	- Support Mac application
	- Nicer display among supported plateform
	- MultiWindow support
	- Add a comment section

Signing (iOS)

	- Xcarchive : Weakness of the signing part due to certificate issue and complexity of build. Not sure it is the role of this tool to handle it. Many different option possible.
	- Display output of build/logs -> currently in the console
	- Resiging by choosing a provisionning
	- Upload Dsym
	- Automatically delegate signing to Fastlane (gym) if present

Network

	- Improvement of the network upload reliability
	- SSH mode has no progress bar
	- Dropbox support for sharing
	- Generate random url for privacy

Templating

	- Improvement of the template management
	- Allow a template store to share its template

Uploading

	- Cancel a build/upload in progress

Settings


Notification

	- Slack support

Knowns bugs or assimilated

	- ⚠️ Store SFTP password in keychain or encrypt them in the settings (ssh mode do not store pwd so is currently secured)  

	- clean code, put a CI & and unit test back

## Feature requests and feedback
Ping me on [twitter](http://twitter.com/nlauquin)

If you want to help me, tell me which usage you will use or like to do with this tool:
- 1/ Easy way to consult app technical details
- 2/ Integration in your toolchain (Jenkins)
- 3/ Manual usage for templating and deploy app
- Which part to remove/which to focus on?


## License

This project is licensed under the terms of the BSD license. See the [LICENSE](LICENSE) file.
