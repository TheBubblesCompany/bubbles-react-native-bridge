"use strict";

import React, { Component } from "react";
import { NativeModules, NativeEventEmitter } from "react-native";
const BubblesReactBridge = NativeModules.RNBubblesReactBridge;

let nativeEventEmitter;

const setHardwareEqualityEnforced = () => {
  BubblesReactBridge.getVersion();
};

export default {
  setHardwareEqualityEnforced,
  get nativeEventEmitter() {
    if (!nativeEventEmitter) {
      nativeEventEmitter = new NativeEventEmitter(BubblesReactBridge);
    }
    return nativeEventEmitter;
  },
};
