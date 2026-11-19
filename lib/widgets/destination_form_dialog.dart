import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/destination_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Dialog Modal untuk Tambah atau Edit Destinasi / Penginapan ke Backend Laravel
class DestinationFormDialog extends StatefulWidget {
  final DestinationModel? existing;
  final List<CategoryModel> categories;
  final List<FacilityModel> facilities;

  const DestinationFormDialog({
    super.key,
    this.existing,
    required this.categories,
    this.facilities = const [],
  });

  static Future<bool?> show(
    BuildContext context, {
    DestinationModel? existing,
    List<CategoryModel>? categories,
    List<FacilityModel>? facilities,
  }) async {
    final api = ApiService();
    final cats = categories ?? await api.getCategories();
    final facs = facilities ?? await api.getFacilities().catchError((_) => <FacilityModel>[]);

    if (!context.mounted) return false;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DestinationFormDialog(
        existing: existing,
        categories: cats,
        facilities: facs,
      ),
    );
  }

  @override
  State<DestinationFormDialog> createState() => _DestinationFormDialogState();
}

class _DestinationFormDialogState extends State<DestinationFormDialog> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  late int _selectedCategoryId;
  late bool _isPopular;
  final Set<int> _selectedFacilityIds = {};
  bool _isSubmitting = false;
  String? _modalError;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _addressCtrl = TextEditingController(text: item?.address ?? '');
    _priceCtrl = TextEditingController(text: item != null ? item.price.toString() : '0');
    _hoursCtrl = TextEditingController(text: item?.openingHours ?? '08:00 - 17:00');
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _latCtrl = TextEditingController(
      text: item != null && item.latitude != 0 ? item.latitude.toString() : '-7.4243',
    );
    _lngCtrl = TextEditingController(
      text: item != null && item.longitude != 0 ? item.longitude.toString() : '109.2302',
    );

    if (item != null && widget.categories.any((c) => c.id == item.categoryId)) {
      _selectedCategoryId = item.categoryId;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    } else {
      _selectedCategoryId = 0;
    }

    _isPopular = item?.isPopular ?? false;
    if (item != null) {
      for (final f in item.facilities) {
        _selectedFacilityIds.add(f.id);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _hoursCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedCategoryId == 0) {
      setState(() => _modalError = 'Pilih kategori destinasi terlebih dahulu.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _modalError = null;
    });

    final payload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'category_id': _selectedCategoryId,
      'price': int.tryParse(_priceCtrl.text.trim()) ?? 0,
      'opening_hours': _hoursCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'latitude': double.tryParse(_latCtrl.text.trim()) ?? -7.4243,
      'longitude': double.tryParse(_lngCtrl.text.trim()) ?? 109.2302,
      'is_popular': _isPopular,
      if (_selectedFacilityIds.isNotEmpty)
        'facility_ids': _selectedFacilityIds.toList(),
    };

    try {
      if (_isEdit) {
        await _apiService.updateDestination(widget.existing!.id, payload);
      } else {
        await _apiService.createDestination(payload);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _modalError = e.toString();
        _isSubmitting = false;
      });
    }
  }

  InputDecoration _inputDeco(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 740),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreenSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _isEdit ? Icons.edit_location_alt_rounded : Icons.add_location_alt_rounded,
                            color: AppTheme.primaryGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? 'Edit Data Destinasi' : 'Tambah Tempat Baru',
                              style: AppTheme.titleLG,
                            ),
                            Text(
                              _isEdit
                                  ? 'Perbarui informasi destinasi ID #${widget.existing!.id}'
                                  : 'Tambahkan destinasi wisata atau penginapan ke server DOKEMAS',
                              style: AppTheme.bodyXS,
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderColor),
                const SizedBox(height: 16),

                if (_modalError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRedLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _modalError!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentRed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nama Tempat / Destinasi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameCtrl,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tempat wajib diisi' : null,
                          decoration: _inputDeco('Contoh: Lokawisata Baturraden'),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: widget.categories.any((c) => c.id == _selectedCategoryId)
                                        ? _selectedCategoryId
                                        : null,
                                    decoration: _inputDeco('Pilih kategori'),
                                    items: widget.categories.map((c) {
                                      return DropdownMenuItem<int>(
                                        value: c.id,
                                        child: Text(c.name),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCategoryId = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Harga Tiket / Tarif (Rp)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _priceCtrl,
                                    keyboardType: TextInputType.number,
                                    validator: (v) => int.tryParse(v?.trim() ?? '') == null ? 'Masukkan angka valid' : null,
                                    decoration: _inputDeco('0 untuk gratis', prefixText: 'Rp '),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Jam Operasional', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _hoursCtrl,
                                    decoration: _inputDeco('08:00 - 17:00'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Status Unggulan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.borderColor),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Destinasi Populer', style: TextStyle(fontSize: 13)),
                                        Switch(
                                          value: _isPopular,
                                          activeThumbColor: AppTheme.primaryGreen,
                                          onChanged: (val) => setState(() => _isPopular = val),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Latitude', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _latCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                    decoration: _inputDeco('-7.4243'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Longitude', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _lngCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                    decoration: _inputDeco('109.2302'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        const Text('Alamat Lengkap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _addressCtrl,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
                          decoration: _inputDeco('Jl. Raya Baturraden, Banyumas...'),
                        ),
                        const SizedBox(height: 14),

                        const Text('Deskripsi Wisata', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 3,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Deskripsi wajib diisi' : null,
                          decoration: _inputDeco('Tuliskan deskripsi daya tarik wisata...'),
                        ),

                        if (widget.facilities.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('Fasilitas Tersedia', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.facilities.map((fac) {
                              final selected = _selectedFacilityIds.contains(fac.id);
                              return FilterChip(
                                label: Text(fac.name, style: const TextStyle(fontSize: 12)),
                                selected: selected,
                                selectedColor: AppTheme.primaryGreenSoft,
                                checkmarkColor: AppTheme.primaryGreen,
                                onSelected: (val) {
                                  setState(() {
                                    if (val) {
                                      _selectedFacilityIds.add(fac.id);
                                    } else {
                                      _selectedFacilityIds.remove(fac.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: AppTheme.borderColor),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      label: Text(
                        _isEdit ? 'Simpan Perubahan' : 'Tambah Destinasi',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
