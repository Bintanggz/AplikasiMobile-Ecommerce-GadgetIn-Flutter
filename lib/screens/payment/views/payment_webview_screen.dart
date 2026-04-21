import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shop/constants.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentToken;
  final String orderId;
  final String clientKey;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentToken,
    required this.orderId,
    required this.clientKey,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  double _progress = 0;

  // HTML content untuk Midtrans Snap
  String get _htmlContent => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script type="text/javascript" src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="${widget.clientKey}"></script>
  <style>
    body {
      margin: 0;
      padding: 20px;
      font-family: Arial, sans-serif;
      background: #f5f5f5;
    }
    #snap-container {
      max-width: 500px;
      margin: 0 auto;
    }
    .loading {
      text-align: center;
      padding: 50px;
      color: #666;
    }
  </style>
</head>
<body>
  <div id="snap-container">
    <div class="loading">Memuat halaman pembayaran...</div>
  </div>
  <script type="text/javascript">
    window.snap.pay('${widget.paymentToken}', {
      onSuccess: function(result) {
        // Payment success
        window.flutter_inappwebview.callHandler('onPaymentSuccess', result);
      },
      onPending: function(result) {
        // Payment pending
        window.flutter_inappwebview.callHandler('onPaymentPending', result);
      },
      onError: function(result) {
        // Payment error
        window.flutter_inappwebview.callHandler('onPaymentError', result);
      },
      onClose: function() {
        // Payment closed
        window.flutter_inappwebview.callHandler('onPaymentClose');
      }
    });
  </script>
</body>
</html>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showCancelDialog();
          },
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(data: _htmlContent),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              useHybridComposition: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              
              // Add JavaScript handler
              controller.addJavaScriptHandler(
                handlerName: 'onPaymentSuccess',
                callback: (args) {
                  _handlePaymentResult('success', args.isNotEmpty ? args[0] : null);
                },
              );
              
              controller.addJavaScriptHandler(
                handlerName: 'onPaymentPending',
                callback: (args) {
                  _handlePaymentResult('pending', args.isNotEmpty ? args[0] : null);
                },
              );
              
              controller.addJavaScriptHandler(
                handlerName: 'onPaymentError',
                callback: (args) {
                  _handlePaymentResult('error', args.isNotEmpty ? args[0] : null);
                },
              );
              
              controller.addJavaScriptHandler(
                handlerName: 'onPaymentClose',
                callback: (args) {
                  _handlePaymentResult('cancelled', null);
                },
              );
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                _isLoading = false;
              });
            },
            onProgressChanged: (controller, progress) {
              setState(() {
                _progress = progress / 100;
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              print('Console: ${consoleMessage.message}');
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: defaultPadding),
                  Text(
                    'Memuat halaman pembayaran...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_progress > 0) ...[
                    const SizedBox(height: defaultPadding / 2),
                    LinearProgressIndicator(value: _progress),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handlePaymentResult(String status, dynamic result) {
    if (!mounted) return;

    Navigator.pop(context, {
      'status': status,
      'orderId': widget.orderId,
      'result': result,
    });
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pembayaran?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, {'status': 'cancelled'}); // Close payment screen
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

