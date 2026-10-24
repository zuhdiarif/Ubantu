import 'package:flutter/material.dart';

enum AddressCardMode {
  single,
  dual,
}

class ModularAddressCard extends StatelessWidget {
  final AddressCardMode mode;
  final TextEditingController originController;
  final TextEditingController? destinationController;
  final String title;
  final String originLabel;
  final String? originSubtitle;
  final String destinationLabel;
  final String? destinationSubtitle;
  final String originHint;
  final String destinationHint;
  final IconData originIcon;
  final IconData destinationIcon;
  final Color originIconColor;
  final Color destinationIconColor;
  final Color originIconBgColor;
  final Color destinationIconBgColor;
  final String? Function(String?)? originValidator;
  final String? Function(String?)? destinationValidator;
  final bool showSwapButton;
  final VoidCallback? onSwap;

  const ModularAddressCard({
    super.key,
    this.mode = AddressCardMode.dual,
    required this.originController,
    this.destinationController,
    this.title = 'Lokasi',
    this.originLabel = 'Dari',
    this.originSubtitle,
    this.destinationLabel = 'Ke',
    this.destinationSubtitle,
    this.originHint = 'Masukkan alamat',
    this.destinationHint = 'Masukkan alamat',
    this.originIcon = Icons.location_on_rounded,
    this.destinationIcon = Icons.flag_rounded,
    this.originIconColor = const Color(0xFF263225),
    this.destinationIconColor = const Color(0xFFF86F1A),
    this.originIconBgColor = const Color(0xFFE2F1D8),
    this.destinationIconBgColor = const Color(0xFFFFF2E5),
    this.originValidator,
    this.destinationValidator,
    this.showSwapButton = true,
    this.onSwap,
  });

  void _handleSwap() {
    if (onSwap != null) {
      onSwap!();
    } else if (destinationController != null) {
      final temp = originController.text;
      originController.text = destinationController!.text;
      destinationController!.text = temp;
    }
  }

  Widget _buildInputRow({
    required String label,
    required String? subtitle,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 0.50,
            color: Color(0xFF263225),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: iconBgColor,
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6C7368),
                          fontSize: 11,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
                TextFormField(
                  controller: controller,
                  validator: validator,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFAEABAA),
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 4, bottom: 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualMode(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Column(
          children: [
            _buildInputRow(
              label: originLabel,
              subtitle: originSubtitle,
              controller: originController,
              hint: originHint,
              icon: originIcon,
              iconColor: originIconColor,
              iconBgColor: originIconBgColor,
              validator: originValidator,
            ),
            const SizedBox(height: 12),
            _buildInputRow(
              label: destinationLabel,
              subtitle: destinationSubtitle,
              controller: destinationController ?? originController,
              hint: destinationHint,
              icon: destinationIcon,
              iconColor: destinationIconColor,
              iconBgColor: destinationIconBgColor,
              validator: destinationValidator,
            ),
          ],
        ),
        if (showSwapButton)
          Positioned(
            right: 18,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSwap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF263225),
                      width: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: Color(0xFF263225),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (mode == AddressCardMode.single)
          _buildInputRow(
            label: originLabel,
            subtitle: originSubtitle,
            controller: originController,
            hint: originHint,
            icon: originIcon,
            iconColor: originIconColor,
            iconBgColor: originIconBgColor,
            validator: originValidator,
          )
        else
          _buildDualMode(context),
      ],
    );
  }
}
