import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../rooms/models/room_model.dart';
import '../data/booking_repository.dart';
import '../models/booking_model.dart';
import 'booking_controller.dart';
import 'booking_qr_modal.dart';

class CreateBookingDialog extends ConsumerStatefulWidget {
  final RoomModel room;

  const CreateBookingDialog({super.key, required this.room});

  static void show(BuildContext context, RoomModel room) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateBookingDialog(room: room),
    );
  }

  @override
  ConsumerState<CreateBookingDialog> createState() => _CreateBookingDialogState();
}

class _CreateBookingDialogState extends ConsumerState<CreateBookingDialog> {
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  int _guestsCount = 1;
  final _specialRequestsController = TextEditingController();
  final _paymentRefController = TextEditingController();
  String _selectedPaymentMethod = 'MobilePay';
  bool _includePayment = false;

  BookingQuoteModel? _quote;
  bool _isQuoting = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  @override
  void dispose() {
    _specialRequestsController.dispose();
    _paymentRefController.dispose();
    super.dispose();
  }

  void _fetchQuote() async {
    setState(() => _isQuoting = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final quote = await repo.getQuote(
        roomId: widget.room.id,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        guestsCount: _guestsCount,
      );
      if (mounted) {
        setState(() {
          _quote = quote;
          _isQuoting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isQuoting = false);
      }
    }
  }

  void _submit() async {
    if (_quote == null || !_quote!.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La habitación no está disponible para las fechas seleccionadas.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final booking = await repo.createBooking({
        'roomId': widget.room.id,
        'checkInDate': _checkInDate.toIso8601String(),
        'checkOutDate': _checkOutDate.toIso8601String(),
        'guestsCount': _guestsCount,
        'specialRequests': _specialRequestsController.text.trim(),
        'initialPaymentMethod': _includePayment ? _selectedPaymentMethod : null,
        'paymentReference': _includePayment ? _paymentRefController.text.trim() : null,
      });

      ref.invalidate(myBookingsProvider);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close dialog

      // Show QR Modal!
      BookingQrModal.show(context, booking);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservar Habitación',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontSize: 20,
                              ),
                        ),
                        Text(
                          '${widget.room.roomNumber} - ${widget.room.title}',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Date Selectors
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _checkInDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            _checkInDate = picked;
                            if (_checkOutDate.isBefore(_checkInDate) || _checkOutDate == _checkInDate) {
                              _checkOutDate = _checkInDate.add(const Duration(days: 1));
                            }
                          });
                          _fetchQuote();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fecha de Entrada', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryBlue),
                                const SizedBox(width: 6),
                                Text(dateFormat.format(_checkInDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _checkOutDate,
                          firstDate: _checkInDate.add(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _checkOutDate = picked);
                          _fetchQuote();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fecha de Salida', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.event_available, size: 16, color: AppTheme.secondaryTeal),
                                const SizedBox(width: 6),
                                Text(dateFormat.format(_checkOutDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Guests Count
              Row(
                children: [
                  const Text('Número de Huéspedes: ', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _guestsCount > 1
                        ? () {
                            setState(() => _guestsCount--);
                            _fetchQuote();
                          }
                        : null,
                  ),
                  Text('$_guestsCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _guestsCount < widget.room.capacity
                        ? () {
                            setState(() => _guestsCount++);
                            _fetchQuote();
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Realtime Quote Summary Box
              if (_isQuoting)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else if (_quote != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _quote!.isAvailable ? AppTheme.primaryBlue.withAlpha(15) : AppTheme.errorRed.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _quote!.isAvailable ? AppTheme.primaryBlue.withAlpha(60) : AppTheme.errorRed.withAlpha(60),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estadía: ${_quote!.totalNights} noche(s)'),
                          Text(
                            _quote!.isAvailable ? '✅ Disponible' : '❌ No Disponible',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _quote!.isAvailable ? AppTheme.successGreen : AppTheme.errorRed,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total a Pagar:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            CurrencyFormatter.formatDual(_quote!.totalAmountUsd, _quote!.currentExchangeRateBcv),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Special Requests
              TextField(
                controller: _specialRequestsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Peticiones especiales o notas (opcional)',
                  hintText: 'Ej: Llegada tardía, cama adicional...',
                ),
              ),
              const SizedBox(height: 16),

              // Optional Payment attachment
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Registrar comprobante de pago ahora', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _includePayment,
                activeThumbColor: AppTheme.primaryBlue,
                onChanged: (val) => setState(() => _includePayment = val),
              ),

              if (_includePayment) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPaymentMethod,
                  decoration: const InputDecoration(labelText: 'Método de Pago'),
                  items: const [
                    DropdownMenuItem(value: 'MobilePay', child: Text('Pago Móvil (Bs.)')),
                    DropdownMenuItem(value: 'Zelle', child: Text('Zelle (USD)')),
                    DropdownMenuItem(value: 'Cash', child: Text('Efectivo (USD / Bs.)')),
                    DropdownMenuItem(value: 'Card', child: Text('Punto de Venta / Tarjeta')),
                    DropdownMenuItem(value: 'BankTransfer', child: Text('Transferencia Bancaria')),
                  ],
                  onChanged: (val) => setState(() => _selectedPaymentMethod = val ?? 'MobilePay'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _paymentRefController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Referencia / Comprobante',
                    hintText: 'Ej: 12345678',
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: (_isSubmitting || _quote == null || !_quote!.isAvailable) ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Confirmar y Generar Reservación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
