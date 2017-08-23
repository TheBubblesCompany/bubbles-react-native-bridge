'use strict';

import React, {Component} from 'react';
import { NativeModules, NativeEventEmitter, DeviceEventEmitter } from 'react-native';

let nativeEventEmitter;

function getVersion() {
  console.log('getVersion');
   NativeModules.RNBubblesReactBridge.getVersion();

   return new Promise((resolve, reject) => {

        BubblesReactBridge.subscriber = (version, error) => {
          if (error) {
            return;
          }

          console.log('subscriberVersion:', version);
          console.log('subscriberError:', error);

          BubblesReactBridge.subscriber = () => {};
          resolve(version);
        };
    });
 }

class BubblesReactBridge {

  subscription: mixed;
  subscriber: Function;

  constructor() {

    const bubbleManagerEmitter = new NativeEventEmitter(NativeModules.RNBubblesReactBridge);
    this.subscription = bubbleManagerEmitter.addListener("getVersion", (e: Event) => {
      console.log('returnListner : ', e.version);
      console.log('returnListner : ', e.error);
      this.subscriber(e.version, e.error);
    });

    this.subscriber = () => {
    }
  }
}

export default {getVersion,
                get nativeEventEmitter() {
                  if (!nativeEventEmitter) {
                    nativeEventEmitter = new NativeEventEmitter(BubblesReactBridge);
                  }
                  return nativeEventEmitter;
                },
              };

export let BubblesModule = new BubblesReactBridge();
