import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/app_state.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _manualIdController = TextEditingController();
  final _manualNameController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualIdController.dispose();
    _manualNameController.dispose();
    super.dispose();
  }

  Future<void> _processCheckin(String id, {String? name}) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final result = await ref.read(currentEventParticipantsProvider.notifier).checkInUser(id, name: name);
    
    if (!mounted) return;
    
    setState(() => _isProcessing = false);

    if (result == "SUCCESS") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in Successful!'), backgroundColor: Colors.green),
      );
      _manualIdController.clear();
      _manualNameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(LucideIcons.qrCode), text: 'Scan QR'),
            Tab(icon: Icon(LucideIcons.keyboard), text: 'Manual Entry'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQRScanner(),
          _buildManualEntry(),
        ],
      ),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _processCheckin(barcodes.first.rawValue!);
              }
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: const Center(
              child: Text(
                'Point the camera at a QR code to check in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildManualEntry() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Manual Check-in', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _manualIdController,
            decoration: const InputDecoration(
              labelText: 'Participant ID (Required)',
              prefixIcon: Icon(LucideIcons.hash),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _manualNameController,
            decoration: const InputDecoration(
              labelText: 'Participant Name (Optional)',
              prefixIcon: Icon(LucideIcons.user),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () {
                    final id = _manualIdController.text.trim();
                    if (id.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID is required.')),
                      );
                      return;
                    }
                    _processCheckin(id, name: _manualNameController.text.trim());
                  },
            child: _isProcessing 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Confirm Check-in'),
          ),
        ],
      ),
    );
  }
}
