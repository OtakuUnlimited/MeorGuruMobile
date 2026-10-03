import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ServiceHeaderWidget extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String shareUrl;

  const ServiceHeaderWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.shareUrl,
  });

  Future<void> _shareService() async {
    final link = shareUrl.trim();

    if (link.isEmpty) return;

    await Share.share(
      '$title\n$link',
      subject: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    image,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Center(
                        child: Icon(
                          Icons.business,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),

              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed:
                      shareUrl.trim().isEmpty
                          ? null
                          : _shareService,
                  icon: const Icon(
                    Icons.share,
                    size: 16,
                    color: Color(0xFFB33A0F),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.brown,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}