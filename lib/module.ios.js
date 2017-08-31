import { NativeModules, NativeEventEmitter } from 'react-native';

const { RNBubblesReactBridge } = NativeModules;

RNBubblesReactBridge.nativeEventEmitter = new NativeEventEmitter(NativeModules.RNBubblesReactBridge);

export default RNBubblesReactBridge;
