import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// Dialog Modal untuk Kelola Kategori Wisata (Tambah, Edit, Hapus via Backend)
class CategoryManagerDialog extends StatefulWidget {
  final VoidCallback? onChanged;

  const CategoryManagerDialog({super.key, this.onChanged});

  static Future<void> show(BuildContext context, {VoidCallback? onChanged}) {
    return showDialog(
      context: context,
      builder: (_) => CategoryManagerDialog(onChanged: onChanged),
    );
  }

  @override
  State<CategoryManagerDialog> createState() => _CategoryManagerDialogState();
}

class _CategoryManagerDialogState extends State<CategoryManagerDialog> {
  final ApiService _apiService = ApiService();
  final _nameCtrl = TextEditingController();
  final _iconCtrl = TextEditingController(text: 'explore');

  List<CategoryModel> _categories = [];
  CategoryModel? _editingCategory;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMsg;

  static const List<Map<String, dynamic>> _presetIcons = [
    {'value': 'forest', 'label': 'Alam / Hutan', 'icon': Icons.forest_rounded},
    {'value': 'restaurant', 'label': 'Kuliner', 'icon': Icons.restaurant_rounded},
    {'value': 'museum', 'label': 'Sejarah / Budaya', 'icon': Icons.museum_rounded},
    {'value': 'mosque', 'label': 'Religi', 'icon': Icons.mosque_rounded},
    {'value': 'family_restroom', 'label': 'Keluarga', 'icon': Icons.family_restroom_rounded},
    {'value': 'hotel', 'label': 'Hotel & Penginapan', 'icon': Icons.hotel_rounded},
    {'value': 'beach_access', 'label': 'Alam Bebas', 'icon': Icons.beach_access_rounded},
    {'value': 'diamond', 'label': 'Hidden Gem', 'icon': Icons.diamond_rounded},
    {'value': 'explore', 'label': 'Umum', 'icon': Icons.explore_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final cats = await _apiService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMsg = 'Nama kategori wajib diisi.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });

    try {
      final payload = {
        'name': name,
        'icon': _iconCtrl.text.trim().isEmpty ? 'explore' : _iconCtrl.text.trim(),
      };

      if (_editingCategory != null) {
        await _apiService.updateCategory(_editingCategory!.id, payload);
      } else {
        await _apiService.createCategory(payload);
      }

      _nameCtrl.clear();
      _iconCtrl.text = 'explore';
      _editingCategory = null;
      await _loadCategories();
      widget.onChanged?.call();

      if (!mounted) return;
      setState(() => _isSubmitting = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString();
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteCategory(CategoryModel cat) async {
    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });
    try {
      await _apiService.deleteCategory(cat.id);
      if (_editingCategory?.id == cat.id) {
        _editingCategory = null;
        _nameCtrl.clear();
      }
      await _loadCategories();
      widget.onChanged?.call();
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString();
        _isSubmitting = false;
      });
    }
  }

  IconData _resolveIcon(String iconName) {
    for (final preset in _presetIcons) {
      if (preset['value'] == iconName) {
        return preset['icon'] as IconData;
      }
    }
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 660, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        child: const Icon(Icons.category_rounded, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kelola Kategori Wisata', style: AppTheme.titleLG),
                          Text('Tambah, ubah, atau hapus klasifikasi kategori DOKEMAS', style: AppTheme.bodyXS),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppTheme.borderColor),
              const SizedBox(height: 16),

              if (_errorMsg != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRedLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.accentRed),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Form Tambah / Edit Kategori
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.bgContent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _nameCtrl,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          labelText: _editingCategory != null ? 'Ubah Nama Kategori' : 'Nama Kategori Baru',
                          hintText: 'Contoh: Wisata Kuliner',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _presetIcons.any((p) => p['value'] == _iconCtrl.text)
                            ? _iconCtrl.text
                            : 'explore',
                        decoration: InputDecoration(
                          labelText: 'Ikon',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                        items: _presetIcons.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['value'] as String,
                            child: Row(
                              children: [
                                Icon(p['icon'] as IconData, size: 16, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Text(p['label'] as String, style: const TextStyle(fontSize: 12.5)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (val) {
                                if (val != null) setState(() => _iconCtrl.text = val);
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_editingCategory != null) ...[
                      IconButton(
                        tooltip: 'Batal Edit',
                        onPressed: _isSubmitting
                            ? null
                            : () => setState(() {
                                  _editingCategory = null;
                                  _nameCtrl.clear();
                                  _iconCtrl.text = 'explore';
                                }),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        _editingCategory != null ? 'Simpan' : '+ Tambah',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Daftar Kategori
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                    : _categories.isEmpty
                        ? const Center(child: Text('Belum ada kategori.', style: AppTheme.bodySM))
                        : ListView.separated(
                            itemCount: _categories.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppTheme.borderColor),
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              return ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreenSoft,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(_resolveIcon(cat.icon), size: 18, color: AppTheme.primaryGreen),
                                ),
                                title: Text(
                                  cat.name,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  'Slug: ${cat.slug} • ${cat.destinationsCount} Destinasi',
                                  style: AppTheme.bodyXS,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Edit Kategori',
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      onPressed: _isSubmitting
                                          ? null
                                          : () => setState(() {
                                                _editingCategory = cat;
                                                _nameCtrl.text = cat.name;
                                                _iconCtrl.text = cat.icon;
                                              }),
                                    ),
                                    IconButton(
                                      tooltip: 'Hapus Kategori',
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.accentRed),
                                      onPressed: _isSubmitting ? null : () => _deleteCategory(cat),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
