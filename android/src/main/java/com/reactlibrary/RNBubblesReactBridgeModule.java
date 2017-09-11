package com.reactlibrary;

import android.Manifest.permission;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.support.v4.app.ActivityCompat;
import android.util.Log;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.gson.GsonBuilder;
import com.mybubbles.sdk.BuildConfig;
import com.mybubbles.sdk.activities.ActivityAllowBluetooth;
import com.mybubbles.sdk.instance.MyBubblesSDK;
import com.mybubbles.sdk.objects.MyBeacon;
import com.mybubbles.sdk.objects.MyBubblesService;
import com.mybubbles.sdk.observables.BeaconsListObservable;
import com.mybubbles.sdk.observables.BluetoothStateObservable;
import com.mybubbles.sdk.observables.LocalizationObservable;
import com.mybubbles.sdk.observables.ServicesListObservable;
import com.mybubbles.sdk.observables.UniqueIdObservable;
import com.mybubbles.sdk.utils.Const;
import com.mybubbles.sdk.utils.ML;
import java.util.Iterator;
import java.util.List;
import java.util.Observable;
import java.util.Observer;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class RNBubblesReactBridgeModule extends ReactContextBaseJavaModule {

  private static final String TAG = "RNBubblesReactBridge";

  private static String DEFAULT_SUCCESS_HANDLER_RETURN = null;
  private static String DEFAULT_FAILED_HANDLER_RETURN = null;
  private static JSONObject FORMATTABLE_FAILED_HANDLER_RETURN = null;

  static {
    try {
      DEFAULT_SUCCESS_HANDLER_RETURN = new JSONObject().put("success", true).toString();
      DEFAULT_FAILED_HANDLER_RETURN = new JSONObject().put("success", false).put("error", "unknown exception").toString();
      FORMATTABLE_FAILED_HANDLER_RETURN = new JSONObject().put("success", false);
    } catch (JSONException e) {
      e.printStackTrace();
    }
  }

  private static final String CALLBACK_CODE_JSON_EXCEPTION = "JSON_EXCEPTION";
  private static final String CALLBACK_CODE_UNKNOWN_SERVICE = "UNKNOWN_SERVICE";
  private static final String CALLBACK_CODE_BRIDGE_VERSION = "UNKNOWN_BRIDGE_VERSION";
  private static final String CALLBACK_CODE_BLUETOOTH_ERROR = "BLUETOOTH_ERROR";
  private static final String CALLBACK_CODE_BLUETOOTH_ON = "BLUETOOTH_ON";
  private static final String CALLBACK_CODE_PERMISSION_REQUIRED = "PERMISSION_REQUIRED";
  private static final String CALLBACK_CODE_INTERNAL_ERROR = "INTERNAL_ERROR";

  private final ReactApplicationContext reactContext;

  public static boolean isReactUpToDate = false;

  public RNBubblesReactBridgeModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    MyBubblesSDK.getInstance().beaconsListObservable.addObserver(new ReactBridgeBeaconsListObserver());
    MyBubblesSDK.getInstance().servicesListObservable.addObserver(new ReactBridgeServicesListObserver());
    MyBubblesSDK.getInstance().bluetoothStateObservable.addObserver(new ReactBridgeBluetoothStateObserver());
    MyBubblesSDK.getInstance().uniqueIdObservable.addObserver(new ReactBridgeUniqueIdObserver());
    MyBubblesSDK.getInstance().localizationObservable.addObserver(new ReactBridgeLocalizationObserver());
  }

  @Override
  public String getName() {
    return "RNBubblesReactBridge";
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// CALL FROM JAVASCRIPT TO PHONE OS /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  @ReactMethod
  public void reactIsUpToDate() {
    isReactUpToDate = true;
  }

  @ReactMethod
  public void log(String data) {
    ML.e(TAG, data);
    Log.e(TAG, data);
  }

  @ReactMethod
  public void getBeaconsAround(Callback callback) {
    log("getBeaconsAround");

    try {
      JSONObject result = new JSONObject();
      JSONArray beacons = new JSONArray();
      List<MyBeacon> beaconsList = MyBubblesSDK.getInstance().getCurrentBeacons();
      for (int i = 0; i < beaconsList.size(); i++) {
        MyBeacon beacon = beaconsList.get(i);
        JSONObject beaconJson = new JSONObject();
        beaconJson.put("uuid", beacon.uuid);
        beaconJson.put("major", beacon.major);
        beaconJson.put("minor", beacon.minor);
        beaconJson.put("event", beacon.event);
        beacons.put(beaconJson);
      }
      result.put("beacons", beacons);
      callback.invoke(null, result.toString());
    } catch (JSONException e) {
      callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
    }
  }

  @ReactMethod
  public void closeService() {
    log("closeService");

    Activity activity = getCurrentActivity();
    if (activity != null) {
      activity.finish();
    }
  }

  @ReactMethod
  public void getBluetoothState(Callback callback) {
    log("getBluetoothState");

    try {
      JSONObject result = new JSONObject();
      result.put("isActivated", getPhoneBluetoothState());
      callback.invoke(null, result.toString());
    } catch (JSONException e) {
      callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
    }
  }

  @ReactMethod
  public void getLocalizationPermissionState(Callback callback) {
    log("getLocalizationPermissionState");

    boolean isAuthorized = true;
    if (VERSION.SDK_INT >= VERSION_CODES.M &&
        ActivityCompat.checkSelfPermission(MyBubblesSDK.mInstance.ctx, permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
      isAuthorized = false;
    }

    try {
      callback.invoke(null, new JSONObject().put("isAuthorized", isAuthorized).toString());
    } catch (JSONException e) {
      callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
    }
  }

  @ReactMethod
  public void getDeviceId(Callback callback) {
    String deviceID = MyBubblesSDK.mInstance.deviceID;
    if (deviceID != null) {
      try {
        JSONObject result = new JSONObject();
        result.put("deviceId", deviceID);
        callback.invoke(null, result.toString());
      } catch (JSONException e) {
        callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
      }
    } else {
      callback.invoke(createRejectCallback(CALLBACK_CODE_INTERNAL_ERROR, "Is SDK init?"), null);
    }
  }

  @ReactMethod
  public void getApplicationId(Callback callback) {
    String apiKey = MyBubblesSDK.mInstance.apiKey;
    if (apiKey != null) {
      try {
        JSONObject result = new JSONObject();
        result.put("applicationId", apiKey);
        callback.invoke(null, result.toString());
      } catch (JSONException e) {
        callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
      }
    } else {
      callback.invoke(createRejectCallback(CALLBACK_CODE_INTERNAL_ERROR, "Is SDK init?"), null);
    }
  }

  @ReactMethod
  public void getUserId(Callback callback) {
    String userID = MyBubblesSDK.mInstance.userID;
    if (userID != null) {
      try {
        JSONObject result = new JSONObject();
        result.put("userId", userID);
        callback.invoke(null, result.toString());
      } catch (JSONException e) {
        callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
      }
    } else {
      callback.invoke(createRejectCallback(CALLBACK_CODE_INTERNAL_ERROR, "Is SDK init?"), null);
    }
  }

  @ReactMethod
  public void getUniqueDeviceId(Callback callback) {
    String uniqueID = MyBubblesSDK.mInstance.uniqueID;
    if (uniqueID != null) {
      try {
        JSONObject result = new JSONObject();
        result.put("isAuthorized", true);
        result.put("uniqueDeviceId", uniqueID);
        callback.invoke(null, result.toString());
      } catch (JSONException e) {
        callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
      }
    } else {
      callback.invoke(createRejectCallback(CALLBACK_CODE_PERMISSION_REQUIRED, "Permission required"), null);
    }
  }

  @ReactMethod
  public void askForUniqueIdPermission() {
    log("askForUniqueIdPermission");

    // Get phone's IMEI for unique identification.
    MyBubblesSDK.mInstance.getIMEI();
  }

  @ReactMethod
  public void askForLocalizationPermission() {
    log("askForLocalizationPermission");

    log("Check BLE permissions for Android >= M");
    if (VERSION.SDK_INT >= VERSION_CODES.M && Const.isAppOnForeground()) {
      if (ActivityCompat.checkSelfPermission(MyBubblesSDK.mInstance.ctx, permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
        if (Const.isActivityAllowBluetoothActive) {
          return;
        }
        // If the SDK is allowed to ask for the permission, ask it.
        Const.isActivityAllowBluetoothActive = true;
        MyBubblesSDK.mInstance.ctx.startActivity(new Intent(MyBubblesSDK.mInstance.ctx, ActivityAllowBluetooth.class).setFlags(Intent.FLAG_ACTIVITY_NEW_TASK));
      }
    }
  }

  @ReactMethod
  public void getServices(Callback callback) {
    log("getServices");

    try {
      JSONObject result = new JSONObject();
      JSONArray services = new JSONArray();
      for (MyBubblesService service : MyBubblesSDK.mInstance.handlerWebServices.services) {
        JSONObject jsonService = new JSONObject();
        jsonService.put("identifier", service.identifier);
        jsonService.put("name", service.name);
        jsonService.put("description", service.description);
        jsonService.put("pictoURL", service.pictoURL);
        jsonService.put("pictoSplashURL", service.pictoSplashURL);
        jsonService.put("pictoColor", service.pictoColor);
        services.put(jsonService);
      }

      // TODO: test data, remove
      JSONObject jsonService = new JSONObject();
      jsonService.put("identifier", "IBC01SRV1337042");
      jsonService.put("name", "Fake Test Service");
      jsonService.put("description", "This is a Fake Test Service");
      jsonService.put("pictoURL", "-");
      jsonService.put("pictoSplashURL", "-");
      jsonService.put("pictoColor", "#DA45CE");
      services.put(jsonService);

      result.put("services", services);
      callback.invoke(null, result.toString());

    } catch (JSONException e) {
      callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
    }
  }

  @ReactMethod
  public void fetchServices() {
    log("fetchServices");

    MyBubblesSDK.mInstance.fetchServices();
  }

  @ReactMethod
  public void openService(String serviceId, Callback callback) {
    log("openService");

    log("jsonData : " + serviceId);

    String ret;

    String id;
    try {
      JSONObject jsonData = new JSONObject(serviceId);
      id = jsonData.getString("service_id");
    } catch (JSONException e) {
      callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
      return;
    }

    boolean flag = false;
    for (MyBubblesService service : MyBubblesSDK.mInstance.handlerWebServices.services) {
      if (service.identifier.equalsIgnoreCase(id)) {
        flag = true;
        break;
      }
    }
    if (!flag) {
      callback.invoke(createRejectCallback(CALLBACK_CODE_UNKNOWN_SERVICE, "unknown service"), null);
      return;
    }

    Activity activity = getCurrentActivity();
    if (activity != null) {
      activity.startActivity(new Intent(activity, MyBubblesSDK.mInterface.getServiceActivityClass()).putExtra("myBubblesServiceID", id));
    }

    ret = DEFAULT_SUCCESS_HANDLER_RETURN;
    callback.invoke(null, ret);
  }

  @ReactMethod
  public void getVersion(Callback callback) {
    log("getVersion");

    String version = BuildConfig.BRIDGE_VERSION;
    if (ML.isValidStr(version)) {
      try {
        callback.invoke(null, new JSONObject().put("version", version).toString());
      } catch (JSONException e) {
        callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
      }
    } else {
      callback.invoke(createRejectCallback(CALLBACK_CODE_BRIDGE_VERSION, "bridge version not found"), null);
    }
  }

  @ReactMethod
  public void enableBluetooth(Callback callback) {
    log("enableBluetooth");

    BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
    if (bluetoothAdapter != null) {
      if (!bluetoothAdapter.isEnabled()) {
        bluetoothAdapter.enable();
        try {
          callback.invoke(null, new JSONObject().put("enabled", true).toString());
        } catch (JSONException e) {
          callback.invoke(createRejectCallback(CALLBACK_CODE_JSON_EXCEPTION, e.getMessage()), null);
        }
        return;
      }
      callback.invoke(createRejectCallback(CALLBACK_CODE_BLUETOOTH_ON, "bluetooth is already activated"), null);
      return;
    }
    callback.invoke(createRejectCallback(CALLBACK_CODE_BLUETOOTH_ERROR, "bluetooth activation failed"), null);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// CALL FROM PHONE OS TO JAVASCRIPT /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  private class ReactBridgeBluetoothStateObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof BluetoothStateObservable && data instanceof Boolean) {
        try {

          log("onBluetoothStateChange");

          JSONObject result = new JSONObject();
          result.put("isActivated", data);
          sendEvent("onBluetoothStateChange", result.toString());

        } catch (JSONException e) {
          e.printStackTrace();
        }
      }
    }
  }

  private class ReactBridgeBeaconsListObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof BeaconsListObservable && data instanceof MyBeacon) {
        try {

          log("onBeaconChange");

          final MyBeacon beacon = (MyBeacon) data;
          JSONObject result = new JSONObject();
          result.put("uuid", beacon.uuid);
          result.put("major", beacon.major);
          result.put("minor", beacon.minor);
          result.put("event", beacon.event);
          sendEvent("onBeaconChange", result.toString());

        } catch (JSONException e) {
          e.printStackTrace();
        }
      }
    }
  }

  private class ReactBridgeUniqueIdObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof UniqueIdObservable && data instanceof Boolean) {
        try {

          log("onSendUniqueId");
          boolean isAuthorized = (Boolean) data;

          JSONObject result = new JSONObject();
          result.put("isAuthorized", isAuthorized);
          if (isAuthorized) {
            result.put("uniqueDeviceId", MyBubblesSDK.mInstance.uniqueID);
          }

          sendEvent("onSendUniqueId", result.toString());

        } catch (JSONException e) {
          e.printStackTrace();
        }
      }
    }
  }

  private class ReactBridgeLocalizationObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof LocalizationObservable && data instanceof Boolean) {
        try {

          log("onLocalizationPermissionChange");

          JSONObject result = new JSONObject();
          result.put("isAuthorized", data);
          sendEvent("onLocalizationPermissionChange", result.toString());

        } catch (JSONException e) {
          e.printStackTrace();
        }
      }
    }
  }

  private class ReactBridgeServicesListObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof ServicesListObservable) {

        log("onServicesChange");

        String eventString;
        try {
          JSONObject result = new JSONObject();
          JSONArray services = new JSONArray();
          for (MyBubblesService service : MyBubblesSDK.mInstance.handlerWebServices.services) {
            JSONObject jsonService = new JSONObject();
            jsonService.put("identifier", service.identifier);
            jsonService.put("name", service.name);
            jsonService.put("description", service.description);
            jsonService.put("pictoURL", service.pictoURL);
            jsonService.put("pictoSplashURL", service.pictoSplashURL);
            jsonService.put("pictoColor", service.pictoColor);
            services.put(jsonService);
          }

          // TODO: test data, remove
          JSONObject jsonService = new JSONObject();
          jsonService.put("identifier", "IBC01SRV1337042");
          jsonService.put("name", "Fake Test Service");
          jsonService.put("description", "This is a Fake Test Service");
          jsonService.put("pictoURL", "-");
          jsonService.put("pictoSplashURL", "-");
          jsonService.put("pictoColor", "#DA45CE");
          services.put(jsonService);

          result.put("services", services);
          eventString = result.toString();
        } catch (JSONException e) {
          eventString = createFormattableFailedReturn(e.getMessage());
        }
        sendEvent("onServicesChange", eventString);
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////// UTILS ///////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  private void sendEvent(String eventName, String json) {
    reactContext
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit(eventName, json);
  }

  private boolean getPhoneBluetoothState() {
    final BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
    return adapter != null && adapter.isEnabled();
  }

  private String createFormattableFailedReturn(final String message) {
    try {
      return FORMATTABLE_FAILED_HANDLER_RETURN.put("error", message).toString();
    } catch (JSONException e) {
      e.printStackTrace();
    }
    return null;
  }

  private WritableMap createRejectCallback(String code, String message) {
    ErrorObject errorObject = new ErrorObject(code, message);
    WritableMap errorMap = null;
    try {
      errorMap = convertJsonToMap(new JSONObject(errorObject.toJsonString()));
    } catch (JSONException e) {
      e.printStackTrace();
    }
    return errorMap;
  }

  private class ErrorObject {

    private String code;
    private String message;

    public ErrorObject(final String code, final String message) {
      this.code = code;
      this.message = message;
    }

    public String toJsonString() {
      return new GsonBuilder().create().toJson(this);
    }
  }

  private static WritableMap convertJsonToMap(JSONObject jsonObject) throws JSONException {
    WritableMap map = new WritableNativeMap();
    Iterator<String> iterator = jsonObject.keys();
    while (iterator.hasNext()) {
      String key = iterator.next();
      Object value = jsonObject.get(key);
      if (value instanceof JSONObject) {
        map.putMap(key, convertJsonToMap((JSONObject) value));
      } else if (value instanceof JSONArray) {
        map.putArray(key, convertJsonToArray((JSONArray) value));
      } else if (value instanceof Boolean) {
        map.putBoolean(key, (Boolean) value);
      } else if (value instanceof Integer) {
        map.putInt(key, (Integer) value);
      } else if (value instanceof Double) {
        map.putDouble(key, (Double) value);
      } else if (value instanceof String) {
        map.putString(key, (String) value);
      } else {
        map.putString(key, value.toString());
      }
    }
    return map;
  }

  private static WritableArray convertJsonToArray(JSONArray jsonArray) throws JSONException {
    WritableArray array = new WritableNativeArray();
    for (int i = 0; i < jsonArray.length(); i++) {
      Object value = jsonArray.get(i);
      if (value instanceof JSONObject) {
        array.pushMap(convertJsonToMap((JSONObject) value));
      } else if (value instanceof JSONArray) {
        array.pushArray(convertJsonToArray((JSONArray) value));
      } else if (value instanceof Boolean) {
        array.pushBoolean((Boolean) value);
      } else if (value instanceof Integer) {
        array.pushInt((Integer) value);
      } else if (value instanceof Double) {
        array.pushDouble((Double) value);
      } else if (value instanceof String) {
        array.pushString((String) value);
      } else {
        array.pushString(value.toString());
      }
    }
    return array;
  }
}
