"use strict";

import { Platform } from "react-native";
import BubblesReactBridgeAndroid from "./lib/module.android";
import BubblesReactBridgeIOS from "./lib/module.ios";

function moduleSelector() {
  if (Platform.OS === "android") {
    return BubblesReactBridgeAndroid;
  }
  return BubblesReactBridgeIOS;
}
const BubblesReactBridge = moduleSelector();
BubblesReactBridge.errorCode = {
  PERMISSION_REJECTED: "PERMISSION_REJECTED",
  PERMISSION_REQUIRED: "PERMISSION_REQUIRED",
}

export default BubblesReactBridge;
