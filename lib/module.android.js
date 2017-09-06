"use strict";

import { NativeModules, NativeEventEmitter } from "react-native";

const BubblesReactBridge = NativeModules.RNBubblesReactBridge;

const reactIsUpToDate = () => {
  BubblesReactBridge.reactIsUpToDate();
};

const log = message => {
  BubblesReactBridge.log(message);
};

const getBeaconsAround = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getBeaconsAround((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const closeService = () => {
  BubblesReactBridge.closeService();
};

const getBluetoothState = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getBluetoothState((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const getLocalizationPermissionState = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getLocalizationPermissionState((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const getUniqueDeviceId = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getUniqueDeviceId((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const getApplicationId = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getApplicationId((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const getDeviceId = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getDeviceId((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const getUserId = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getUserId((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const getNotificationPermissionState = async () => {
  return new Promise((resolve, reject) => {
    resolve(JSON.stringify({isAuthorized: true}));
  });
};

const askForUniqueIdPermission = () => {
  BubblesReactBridge.askForUniqueIdPermission();
};

const askForLocalizationPermission = () => {
  BubblesReactBridge.askForLocalizationPermission();
};

const getServices = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getServices((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const fetchServices = () => {
  BubblesReactBridge.fetchServices();
};

const openService = async serviceId => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.openService(serviceId, (error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const getVersion = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.getVersion((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

const enableBluetooth = async () => {
  return new Promise((resolve, reject) => {
    BubblesReactBridge.enableBluetooth((error, status) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(status);
    });
  });
};

let nativeEventEmitter;

export default {
  reactIsUpToDate,
  log,
  getUserId,
  getDeviceId,
  getApplicationId,
  getBeaconsAround,
  closeService,
  getBluetoothState,
  getLocalizationPermissionState,
  getNotificationPermissionState,
  getUniqueDeviceId,
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
