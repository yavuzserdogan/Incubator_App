import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:path/path.dart' as path;
import '../../core/constants/color_constant.dart';
import '../../core/constants/widget_size_constant.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen>
    with TickerProviderStateMixin {
  final String serviceUuid = "2220";
  final String characteristicUuid = "2221";

  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  bool _connected = false;
  bool _connecting = false;
  late final Stream<List<ScanResult>> _scanStream;

  final List<String> _receivedData = [];

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scanStream = FlutterBluePlus.scanResults;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      final scan = await Permission.bluetoothScan.request();
      final connect = await Permission.bluetoothConnect.request();
      final location = await Permission.location.request();
      return scan.isGranted && connect.isGranted && location.isGranted;
    }
    return true;
  }

  Future<void> connectToDevice() async {
    setState(() {
      _connecting = true;
    });

    print("Cihaz taranıyor...");

    final hasPermissions = await _checkAndRequestPermissions();
    if (!hasPermissions) {
      print("Gerekli izinler verilmedi!");
      setState(() {
        _connecting = false;
      });
      return;
    }

    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();

    bool deviceFound = false;

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _scanSubscription = _scanStream.listen((results) async {
      for (ScanResult result in results) {
        if (result.device.platformName.trim() == "INCUBATOR") {
          deviceFound = true;

          print("Cihaz bulundu: ${result.device.platformName}");
          await FlutterBluePlus.stopScan();
          await _scanSubscription?.cancel();

          _device = result.device;

          try {
            await _device!.connect(timeout: const Duration(seconds: 10));
          } catch (e) {
            print("Zaten bağlı olabilir veya bağlantı hatası: $e");
          }

          final services = await _device!.discoverServices();

          for (var service in services) {
            if (service.uuid.toString().toLowerCase().endsWith(serviceUuid)) {
              for (var c in service.characteristics) {
                if (c.uuid.toString().toLowerCase().endsWith(
                  characteristicUuid,
                )) {
                  _characteristic = c;

                  await _characteristic!.setNotifyValue(true);
                  _characteristic!.lastValueStream.listen((value) {
                    final decoded = utf8.decode(value);
                    print("String veri: $decoded");
                    setState(() {
                      _receivedData.insert(0, decoded);
                    });
                  });

                  setState(() {
                    _connected = true;
                    _connecting = false;
                  });

                  print("Karakteristik bulundu ve veri alımı başladı.");
                  return;
                }
              }
            }
          }
        }
      }
    });

    Future.delayed(const Duration(seconds: 10), () async {
      if (!deviceFound) {
        await FlutterBluePlus.stopScan();
        await _scanSubscription?.cancel();
        setState(() {
          _connecting = false;
        });
        print("Tarama süresi doldu, cihaz bulunamadı.");
      }
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _device?.disconnect();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildConnectionStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenSize.height * 0.02),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              _connected
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : _connecting
                  ? [Colors.orange.shade400, Colors.orange.shade600]
                  : [Colors.grey.shade400, Colors.grey.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ScreenSize.height * WidgetSizeConstant.borderCircular,
        ),
        boxShadow: [
          BoxShadow(
            color: (_connected
                    ? Colors.green
                    : _connecting
                    ? Colors.orange
                    : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _connected
                ? Icons.bluetooth_connected
                : _connecting
                ? Icons.bluetooth_searching
                : Icons.bluetooth_disabled,
            size: ScreenSize.height * WidgetSizeConstant.iconSize,
            color: Colors.white,
          ),
          SizedBox(height: ScreenSize.height * 0.01),
          Text(
            _connected
                ? "Cihaza Bağlı"
                : _connecting
                ? "Bağlanıyor..."
                : "Bağlantı Yok",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ScreenSize.height * 0.01),
          Text(
            _connected
                ? "İnkübatör cihazı aktif"
                : _connecting
                ? "Lütfen bekleyin"
                : "Cihaza bağlanmak için butona basın",
            style: const TextStyle(fontSize: 14, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton() {
    return Container(
      width: double.infinity,
      height: ScreenSize.height * 0.06,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ScreenSize.height * WidgetSizeConstant.borderCircular,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (_connected || _connecting) ? null : connectToDevice,
          borderRadius: BorderRadius.circular(
            ScreenSize.height * WidgetSizeConstant.borderCircular,
          ),
          child: Center(
            child:
                _connecting
                    ? SizedBox(
                      width: ScreenSize.width * 0.065,
                      height: ScreenSize.height * 0.035,
                      child: CircularProgressIndicator(
                        strokeWidth: ScreenSize.width * 0.01,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _connected ? Icons.check_circle : Icons.bluetooth,
                          color: Colors.white,
                          size: ScreenSize.height * 0.035,
                        ),
                        SizedBox(width: ScreenSize.width * 0.02),
                        Text(
                          _connected ? "Bağlandı" : "Cihaza Bağlan",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScreenSize.height * WidgetSizeConstant.borderCircular,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ScreenSize.height * 0.015),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderCircular,
                ),
                topRight: Radius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderCircular,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ScreenSize.height * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(
                      ScreenSize.height * WidgetSizeConstant.borderCircular,
                    ),
                  ),
                  child: Icon(
                    Icons.data_usage,
                    color: Colors.blue.shade700,
                    size: ScreenSize.height * 0.03,
                  ),
                ),
                SizedBox(width: ScreenSize.width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gelen Veriler",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${_receivedData.length} veri alındı",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: ScreenSize.height * 0.25,
            padding: EdgeInsets.all(ScreenSize.height * 0.02),
            child:
                _receivedData.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: ScreenSize.height*0.07,
                            color: Colors.grey.shade400,
                          ),
                           SizedBox(height: ScreenSize.height*0.02),
                          Text(
                            "Henüz veri alınmadı",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: ScreenSize.height*0.02),
                          Text(
                            "Cihaz bağlandığında veriler burada görünecek",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      itemCount: _receivedData.length,
                      separatorBuilder:
                          (context, index) =>  Divider(height: ScreenSize.height*0.01),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color:
                                index == 0
                                    ? Colors.blue.shade50
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      index == 0
                                          ? Colors.green
                                          : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormattedData(
                                  _receivedData[index],
                                  index == 0,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedData(String rawData, bool isLatest) {
    // Veriyi parse et
    final co2Match = RegExp(r'CO2:\s*(\d+\.?\d*)\s*ppm').firstMatch(rawData);
    final humMatch = RegExp(r'HUM:\s*%(\d+\.?\d*)').firstMatch(rawData);
    final tempMatch = RegExp(r'TEMP:\s*(\d+\.?\d*)\s*C').firstMatch(rawData);

    if (co2Match != null && humMatch != null && tempMatch != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.air, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 4),
              Text(
                'CO₂: ${co2Match.group(1)} ppm',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isLatest ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.water_drop, size: 16, color: Colors.cyan.shade600),
              const SizedBox(width: 4),
              Text(
                'Nem: %${humMatch.group(1)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isLatest ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.thermostat, size: 16, color: Colors.orange.shade600),
              const SizedBox(width: 4),
              Text(
                'Sıcaklık: ${tempMatch.group(1)}°C',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isLatest ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Parse edilemezse ham veriyi göster
      return Text(
        rawData,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: isLatest ? FontWeight.w500 : FontWeight.normal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(ColorConstant.screenBackground),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionStatusCard(),
            const SizedBox(height: 24),
            _buildConnectButton(),
            const SizedBox(height: 32),
            _buildDataSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
