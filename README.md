# Desk API Client

The Desk API Client is a lightweight framework that wraps the [Desk.com API V2](http://dev.desk.com), written in Objective-C.

## Installation
DeskAPIClient supports multiple methods for installing the framework in a project.

### Installation with CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager, which automates and simplifies the process of using 3rd-party libraries in your projects.

You can install it with the following command:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
  pod 'DeskAPIClient', '~> 3.2'
end
```
Then, run the following command:

```bash
$ pod install
```

### Installation with Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate DeskAPIClient into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "forcedotcom/DeskApiClient-ObjC" ~> 3.2
```
Run `carthage update` to build the framework and drag the built `DeskAPIClient.framework` into your Xcode project.

**IMPORTANT: Currently we only support prebuilt frameworks. If you run carthage with `--no-use-binaries` option, you will get an error.**

### Installation using prebuilt Framework
Starting with DeskAPIClient version `3.2.0`, prebuilt frameworks are attached in github releases. In order to use prebuilt frameworks:

1. Download the appropriate version `Frameworks.zip` file from [Releases](https://github.com/forcedotcom/DeskApiClient-ObjC/releases)
2. Unarchive the zip file  
3. With your project open in Xcode, select your Target. Under General tab, find Embedded Binaries and then click the + button.
4. Click the Add Other... button, navigate to the framework files (`DeskAPIClient.framework`, `DeskCommon.framework`) and select them. Check the Destination: Copy items if needed checkbox when prompted.

**IMPORTANT: Attached prebuilt frameworks contain binaries which have been built for a number of architectures `(x86_64, i386, armv7, arm64)`. According to [this radar](http://www.openradar.me/radar?id=6409498411401216) before submission to AppStore you must strip off simulator slices `(x86_64, i386)`.**

## Usage

Create an API Oauth2 token client as follows:

```
DSAPIClient *client = [DSAPIClient sharedManager];
[client setHostname:@“mysite.desk.com”
           APIToken:@“my api token”];
```

Create an API OAuth1 client as follows:

```
DSAPIClient *client = [DSAPIClient sharedManager];
[client setHostname:@"mysite.desk.com"
        consumerKey:@"yourConsumerKey"
     consumerSecret:@"yourConsumerSecret"
        callbackURL:@"urlscheme://callback-url"];
```

## Copyright and license

Copyright (c) 2015, Salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

* Neither the name of Salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
