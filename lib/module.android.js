"use strict";

import { NativeModules, NativeEventEmitter } from "react-native";

const BubblesReactBridge = NativeModules.BubblesReactBridge;

const reactIsUpToDate = () => {
  BubblesReactBridge.reactIsUpToDate();
};

const log = message => {
  BubblesReactBridge.log(message);
};

const getBeaconsAround = () => {
  BubblesReactBridge.getBeaconsAround();
};

const closeService = () => {
  BubblesReactBridge.closeService();
};

const getBluetoothState = () => {
  BubblesReactBridge.getBluetoothState();
};

const getLocalizationPermissionState = () => {
  BubblesReactBridge.getLocalizationPermissionState();
};

const askForUniqueIdPermission = () => {
  BubblesReactBridge.askForUniqueIdPermission();
};

const askForLocalizationPermission = () => {
  BubblesReactBridge.askForLocalizationPermission();
};

const getServices = () => {
  BubblesReactBridge.getServices();
};

const fetchServices = () => {
  BubblesReactBridge.fetchServices();
};

const openService = serviceId => {
  BubblesReactBridge.openService(serviceId);
};

const getVersion = () => {
  BubblesReactBridge.getVersion();
};

const enableBluetooth = () => {
  BubblesReactBridge.enableBluetooth();
};

let nativeEventEmitter;

export default {
  reactIsUpToDate,
  log,
  getBeaconsAround,
  closeService,
  getBluetoothState,
  getLocalizationPermissionState,
  askForUniqueIdPermission,
  askForLocalizationPermission,
  getServices,
  fetchServices,
  openService,
  getVersion,
  enableBluetooth,
  get nativeEventEmitter() {
    if (!nativeEventEmitter) {
      nativeEventEmitter = new NativeEventEmitter(BubblesReactBridge);
    }
    return nativeEventEmitter;
  },
};
