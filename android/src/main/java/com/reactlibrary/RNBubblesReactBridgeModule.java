package com.reactlibrary;

import android.Manifest.permission;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.support.annotation.Nullable;
import android.support.v4.app.ActivityCompat;
import android.widget.Toast;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Observable;
import java.util.Observer;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class RNBubblesReactBridgeModule extends ReactContextBaseJavaModule {

  private static final String TAG = "BubblesReactBridge";

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

  private static final String DURATION_SHORT_KEY = "SHORT";
  private static final String DURATION_LONG_KEY = "LONG";

  public static boolean isReactUpToDate = false;

  private final ReactApplicationContext reactContext;

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
    return "BubblesReactBridge";
  }

  // Optional
  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();
    constants.put(DURATION_SHORT_KEY, Toast.LENGTH_SHORT);
    constants.put(DURATION_LONG_KEY, Toast.LENGTH_LONG);
    return constants;
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
  }

  @ReactMethod
  public void getBeaconsAround() {
    log("getBeaconsAround");

    List<MyBeacon> beaconsList = MyBubblesSDK.getInstance().getCurrentBeacons();

    String ret;
    try {
      JSONObject result = new JSONObject();
      JSONArray beacons = new JSONArray();
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
      result.put("success", true);
      ret = result.toString();
    } catch (JSONException e) {
      ret = "{'success':false}";
    }

    log("list : " + ret);

    WritableMap params = Arguments.createMap();
    params.putString("beaconsList", ret);

    sendEvent("getBeaconsAround", params);
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
  public void openURI(String uri) {
    log("openURI");

    ML.e(TAG, "jsonData : " + uri);

    try {
      JSONObject jsonData = new JSONObject(uri);
      uri = jsonData.getString("uri");
    } catch (JSONException e) {
      return;
    }

    // Otherwise, the link is not for a page on our Service, so launch another Activity that handles URLs
    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
    Activity activity = getCurrentActivity();
    if (activity != null) {
      activity.startActivity(intent);
    }
  }

  @ReactMethod
  public void getBluetoothState() {
    log("getBluetoothState");

    WritableMap params = Arguments.createMap();
    params.putBoolean("isActivated", getPhoneBluetoothState());
    sendEvent("getBluetoothState", params);
  }

  @ReactMethod
  public void getLocalizationPermissionState() {
    log("getLocalizationPermissionState");

    boolean isAuthorized = true;
    if (VERSION.SDK_INT >= VERSION_CODES.M &&
        ActivityCompat.checkSelfPermission(MyBubblesSDK.mInstance.ctx, permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
      isAuthorized = false;
    }

    WritableMap params = Arguments.createMap();
    params.putBoolean("isAuthorized", isAuthorized);
    sendEvent("getLocalizationPermissionState", params);
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
  public void getServices() {
    log("getServices");

    WritableMap params = Arguments.createMap();

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
      result.put("success", true);
      params.putString("result", result.toString());

    } catch (JSONException e) {
      params.putString("result", DEFAULT_FAILED_HANDLER_RETURN);
    }
    sendEvent("getServices", params);
  }

  @ReactMethod
  public void fetchServices() {
    log("fetchServices");

    MyBubblesSDK.mInstance.fetchServices();
  }

  @ReactMethod
  public void openService(String serviceId) {
    log("openService");

    log("jsonData : " + serviceId);

    WritableMap params = Arguments.createMap();
    String ret;

    String id;
    try {
      JSONObject jsonData = new JSONObject(serviceId);
      id = jsonData.getString("service_id");
    } catch (JSONException e) {
      ret = createFormattableFailedReturn(e.getMessage());
      params.putString("callback", ret);
      sendEvent("openService", params);
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
      ret = createFormattableFailedReturn("unknown service");
      params.putString("callback", ret);
      sendEvent("openService", params);
      return;
    }

    Activity activity = getCurrentActivity();
    if (activity != null) {
      activity.startActivity(new Intent(activity, MyBubblesSDK.mInterface.getServiceActivityClass()).putExtra("myBubblesServiceID", id));
    }

    ret = DEFAULT_SUCCESS_HANDLER_RETURN;
    params.putString("callback", ret);
    sendEvent("openService", params);
  }

  @ReactMethod
  public void getVersion() {
    log("getVersion");

    WritableMap params = Arguments.createMap();
    params.putString("version", BuildConfig.BRIDGE_VERSION);
    sendEvent("getVersion", params);
  }


  @ReactMethod
  public void enableBluetooth() {
    log("enableBluetooth");

    MyBubblesSDK.getInstance().enableBluetooth();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////// CALL FROM PHONE OS TO JAVASCRIPT /////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  private class ReactBridgeBluetoothStateObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof BluetoothStateObservable && data instanceof Boolean) {

        log("onBluetoothStateChange");

        WritableMap params = Arguments.createMap();
        params.putBoolean("isActivated", (Boolean) data);
        sendEvent("onBluetoothStateChange", params);
      }
    }
  }

  private class ReactBridgeBeaconsListObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof BeaconsListObservable && data instanceof MyBeacon) {

        log("onBeaconChange");

        final MyBeacon beacon = (MyBeacon) data;

        WritableMap params = Arguments.createMap();
        params.putString("uuid", beacon.uuid);
        params.putString("major", beacon.major);
        params.putString("minor", beacon.minor);
        params.putString("event", beacon.event);
        sendEvent("onBeaconChange", params);
      }
    }
  }

  private class ReactBridgeUniqueIdObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof UniqueIdObservable && data instanceof Boolean) {

        log("onSendUniqueId");

        WritableMap params = Arguments.createMap();
        params.putBoolean("isAuthorized", (Boolean) data);
        sendEvent("onSendUniqueId", params);
      }
    }
  }

  private class ReactBridgeLocalizationObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof LocalizationObservable && data instanceof Boolean) {

        log("onLocalizationPermissionChange");

        WritableMap params = Arguments.createMap();
        params.putBoolean("isAuthorized", (Boolean) data);
        sendEvent("onLocalizationPermissionChange", params);
      }
    }
  }

  private class ReactBridgeServicesListObserver implements Observer {

    @Override
    public void update(Observable observable, Object data) {
      if (observable instanceof ServicesListObservable) {

        log("onServicesChange");

        WritableMap params = Arguments.createMap();
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
          result.put("success", true);
          params.putString("result", result.toString());
        } catch (JSONException e) {
          params.putString("result", DEFAULT_FAILED_HANDLER_RETURN);
        }
        sendEvent("onServicesChange", params);
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////// UTILS ///////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  private void sendEvent(String eventName, @Nullable WritableMap params) {
    reactContext
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit(eventName, params);
  }

  private String createFormattableFailedReturn(final String message) {
    try {
      return FORMATTABLE_FAILED_HANDLER_RETURN.put("error", message).toString();
    } catch (JSONException e) {
      e.printStackTrace();
    }
    return null;
  }

  private boolean getPhoneBluetoothState() {
    final BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
    return adapter != null && adapter.isEnabled();
  }
}
