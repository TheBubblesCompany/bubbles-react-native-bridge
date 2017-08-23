# react-native-bubbles-react-bridge

## Getting started

`$ npm i @the-bubbles-company/bubbles-react-native-bridge -S`

### Mostly automatic installation

`$ react-native link @the-bubbles-company/bubbles-react-native-bridge`

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `@the-bubbles-company/bubbles-react-native-bridge` and add `RNBubblesReactBridge.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNBubblesReactBridge.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNBubblesReactBridgePackage;` to the imports at the top of the file
  - Add `new RNBubblesReactBridgePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-bubbles-react-bridge'
  	project(':react-native-bubbles-react-bridge').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-bubbles-react-bridge/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-bubbles-react-bridge')
  	```

## Usage
```javascript
import RNBubblesReactBridge from '@the-bubbles-company/bubbles-react-native-bridge';

// TODO: What to do with the module?
RNBubblesReactBridge;
```

## React Bridge API

### Structures

#### Beacon

```
{
    uuid: "F3077ABE93AC465AACF167F080CB7AEF",
    minor: "CF2F",
    major: "3566",
    event: "IN_NEAR_REGION"
}
```

##### Parameters:

Name | Type | Attributes | Default | Description
-|-|-|-|-
`uuid` | String | | | Beacon UUID in Hexadecimal
`minor` | String | | | Beacon minor in Hexadecimal
`major` | String | | | Beacon major in Hexadecimal
`event` | String | | | Beacon event: ["ENTER", "EXIT", "IN_FAR_REGION", "IN_NEAR_REGION", "IN_IMMEDIATE_REGION"]

#### Service

```
{
    identifier: "IBC01SRV000000000099",
    name: "Test Service",
    description: "Test Service Description",
    pictoURL: "http://api-sdk.staging.bubbles-company.com/assets/img/service/assets/IBC01SRV000000000099/base/X4/picto_5943a7bbaa425998002626.png?date=20170110",
    pictoSplashURL: "http://api-sdk.staging.bubbles-company.com/assets/img/service/assets/IBC01SRV000000000099/base/X4/picto_splashscreen_5943a7bbc1355691342929.png?date=20170110",
    pictoColor: "#45CEDA"
}
```

##### Parameters:

Name | Type | Attributes | Default | Description
-|-|-|-|-
`identifier` | String | | | Service identifier
`name` | String | | | Service name
`description` | String | | | Service description
`pictoURL` | String | | | Service picto URL
`pictoSplashURL` | String | | | Service splash picto URL
`pictoColor` | String | | | Service picto color

### Call from React to Phone OS

#### log(data)

Displays a log in the application's log system for debug purpose.

##### Parameters:

Name | Type | Attributes | Default | Description
-|-|-|-|-
`data` | String | | | Data to add on application log

##### Callbacks:

> No Callbackss

##### Event Listener:

> No Event Listener

#### reactIsUpToDate()

> On Android only

Needs to be called when the React part is up to date _(CodePush integration)_.

##### Parameters:

> No Parameters

##### Callbacks:

> No Callbackss

##### Event Listener:

> No Event Listener

#### getVersion()

Gets the application's current Bridge version.

##### Parameters:

> No Parameters

##### Callbacks:

_Resolve:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`version` | String | | | Application Bridge version

_Reject 1:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `0`
`message` | String | | | Error message `JSON Exception`

_Reject 2:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `2`
`message` | String | | | Error message `Version not found`

##### Event Listener:

> No Event Listener

#### getServices()

Asks for the Services list.

##### Parameters:

> No Parameters

##### Callbacks:

_Resolve:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`services` | Array | | | Services array
`services.row` | Service | | | Service object

_Reject:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `0`
`message` | String | | | Error message `JSON Exception`

##### Event Listener:

> No Event Listener

#### fetchServices()

Asks the application to update the Services list.

##### Parameters:

> No Parameters

##### Callbacks:

> No Callbackss

##### Event Listener:

> See `onServicesChange`

#### openService(service_id)

Asks the application to open a specific Service.

##### Parameters:

Name | Type | Attributes | Default | Description
-|-|-|-|-
`serviceId` | String | | | Service identifier

##### Callbacks:

_Resolve:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`success` | Boolean | | | Return false when service not found

_Reject 1:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `0`
`message` | String | | | Error message `JSON Exception`

_Reject 2:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `1`
`message` | String | | | Error message `Unknown Service`

##### Event Listener:

> No Event Listener

#### closeService()

Asks the application to close the current Service.

##### Parameters:

> No Parameters

##### Callbacks:

> No Callbackss

##### Event Listener:

> No Event Listener

#### getBeaconsAround()

Retrieves the Beacons list detected by the phone.

##### Parameters:

> No Parameters

##### Callbacks:

_Resolve:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`beacons` | Array | `<optional>` | [] | Beacons array
`beacons.row` | Beacon | | | Beacons object

_Reject:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `0`
`message` | String | | | Error message `JSON Exception`

##### Event Listener:

> No Event Listener

#### getBluetoothState()

Gets the phone's Bluetooth state.

##### Parameters:

> No Parameters

##### Callbacks:

_Resolve:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`isActivated` | Boolean | | | Return Bluetooth state

_Reject:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `0`
`message` | String | | | Error message `JSON Exception`

##### Event Listener:

> No Event Listener

#### getLocalizationPermissionState()

Gets phone's Localization permission state.

##### Parameters:

> No Parameters

##### Callbacks:

_Resolve:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`is_authorized` | Boolean | | | Return Permission state

_Reject:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `0`
`message` | String | | | Error message `JSON Exception`

##### Event Listener:

> No Event Listener

#### askForLocalizationPermission()

Asks for phone's Localization permission.

##### Parameters:

> No Parameters

##### Callbacks:

> No callbacks

##### Event Listener:

> See `onLocalizationPermissionChange`

#### askForUniqueIdPermission()

> On Android only

Asks for phone's Unique Id permission.

##### Parameters:

> No Parameters

##### Callbacks:

> No callbacks

##### Event Listener:

> See `onSendUniqueId`

#### enableBluetooth()

Asks application to enable the Bluetooth _(without prompting it to the user)_.

##### Parameters:

> No Parameters

##### Callbacks:

_Resolve:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`enabled` | Boolean | | | Bluetooth has been enabled successfully

_Reject 1:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `0`
`message` | String | | | Error message `JSON Exception`

_Reject 2:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `3`
`message` | String | | | Error message `Impossible to activate Bluetooth`

_Reject 3:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`code` | Integer | | | Error code `4`
`message` | String | | | Error message `Bluetooth already activated`

##### Event Listener:

> No Event Listener

### Call from Phone OS to React

#### onServicesChange(success, services)

Triggers when the Services list is updated.

##### Parameters:

> No Parameters

##### Callbackw:

> No Callbacks

##### Event Listener:

_If succeeded:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`services` | Array | | | Service list
`services.row` | Service | | | Service object

_If failed:_

Name | Type | Attributes | Default | Description
-|-|-|-|-
`success` | Array | | | `false`
`message` | String | | | Error message

#### onBeaconChange()

Triggers any Beacon data change.

##### Parameters:

> No Parameters

##### Callbacks:

> No Callbacks

##### Event Listener:

Name | Type | Attributes | Default | Description
-|-|-|-|-
`beacon` | Beacon | | | Beacon new state

#### onBluetoothStateChange()

Triggers when the Bluetooth state changes.

##### Parameters:

> No Parameters

##### Callbacks:

> No Callbacks

##### Event Listener:

Name | Type | Attributes | Default | Description
-|-|-|-|-
`isActivated` | Boolean | | | Bluetooth state

#### onLocalizationPermissionChange(success)

Triggers after that the permission question is answered by the user.

##### Parameters:

> No Parameters

##### Callbacks:

> No Callbacks

##### Event Listener:

Name | Type | Attributes | Default | Description
-|-|-|-|-
`isAuthorized` | Boolean | | | Return `false` if user refuse

#### onSendUniqueId()

> On Android only

Triggers after that the permission question is answered by the user.

##### Parameters:

> No Parameters

##### Callbacks:

> No Callbacks

##### Event Listener:

Name | Type | Attributes | Default | Description
-|-|-|-|-
`isAuthorized` | Boolean | | | Return `false` if user refuse
