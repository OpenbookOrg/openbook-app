import 'package:Okuna/models/device.dart';

class DevicesList {
  final List<Device>? devices;

  DevicesList({
    this.devices,
  });

  factory DevicesList.fromJson(List<dynamic> parsedJson) {
    List<Device> devices =
        parsedJson.map((deviceJson) => Device.fromJSON(deviceJson)).toList();

    return new DevicesList(
      devices: devices,
    );
  }
}
