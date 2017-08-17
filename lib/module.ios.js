'use strict';

import React, {Component} from 'react';
import { NativeModules, NativeEventEmitter } from 'react-native';
const BubblesReactBridge = NativeModules.RNBubblesReactBridge;

let nativeEventEmitter;

const getVersion = () => {
    BubblesReactBridge.getVersion();
};

const getBeaconsAround = () => {
    BubblesReactBridge.getBeaconsAround();
};

const closeService = () => {
    BubblesReactBridge.closeService();
};

const getLocalizationPermissionState = () => {
    BubblesReactBridge.getLocalizationPermissionState();
};

const getNotificationPermissionState = () => {
    BubblesReactBridge.getNotificationPermissionState();
};

const getBluetoothState = () => {
    BubblesReactBridge.getBluetoothState();
};

const askForLocalizationPermission = () => {
    BubblesReactBridge.askForLocalizationPermission();
};

const askForNotificationPermission = () => {
    BubblesReactBridge.askForNotificationPermission();
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

const openBluetoothSettings = () => {
  BubblesReactBridge.openBluetoothSettings();
};





export default {
  getVersion,
  getBeaconsAround,
  closeService,
  getLocalizationPermissionState,
  getNotificationPermissionState,
  getBluetoothState,
  askForLocalizationPermission,
  askForNotificationPermission,
  getServices,
  fetchServices,
  openService,
  openBluetoothSettings,
  get nativeEventEmitter() {
    if (!nativeEventEmitter) {
      nativeEventEmitter = new NativeEventEmitter(BubblesReactBridge);
    }
    return nativeEventEmitter;
  }
};
