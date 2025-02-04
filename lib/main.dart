import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Thermal Printer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PrinterSelectionScreen(),
    );
  }
}

class PrinterSelectionScreen extends StatefulWidget {
  const PrinterSelectionScreen({super.key});

  @override
  _PrinterSelectionScreenState createState() {
    return _PrinterSelectionScreenState();
  }
}

class _PrinterSelectionScreenState extends State<PrinterSelectionScreen> {
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _scanForBluetoothDevices();
  }

  // Function to scan Bluetooth devices
  void _scanForBluetoothDevices() async {
    final List<BluetoothInfo> devices = await PrintBluetoothThermal.pairedBluetooths;
    setState(() {
      _devices = devices;
    });
  }

  // Function to connect to the selected Bluetooth device and print
  void _printDemoPage() async {
    if (_selectedDevice == null) {
      return;
    }

    final profile = await CapabilityProfile.load();
    final printer = Generator(PaperSize.mm80, profile);

    // Connect to the selected Bluetooth device
    final isConnected = await PrintBluetoothThermal.connect(macPrinterAddress: _selectedDevice?.macAdress ?? '');

    if (isConnected) {
      print("Failed to connect to printer");
      return;
    }

    // Send print commands
    printer.setStyles(PosStyles(align: PosAlign.center));
    printer.text("Welcome to My Store");
    printer.text("Thank you for your purchase!");
    printer.text("Total: \$12.99");
    printer.text("المبلغ الاجمالي : \$12.99");

    printer.text("************************");
    printer.cut();

    // Disconnect after printing
    await PrintBluetoothThermal.disconnect;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Bluetooth Printer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Available Printers:", style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return ListTile(
                    title: Text(device.name ?? "Unknown"),
                    subtitle: Text(device.macAdress),
                    onTap: () {
                      setState(() {
                        _selectedDevice = device;
                      });
                    },
                    tileColor: _selectedDevice == device ? Colors.blue[100] : null,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedDevice == null ? null : _printDemoPage,
              child: Text("Print Demo Page"),
            ),
          ],
        ),
      ),
    );
  }
}
