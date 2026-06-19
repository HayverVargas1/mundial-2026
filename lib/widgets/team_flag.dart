import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeamFlag extends StatelessWidget {
  final String? logoUrl;
  final String teamName;
  final double size;

  const TeamFlag({
    Key? key,
    required this.logoUrl,
    required this.teamName,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white10,
      ),
      clipBehavior: Clip.antiAlias,
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => Center(
                child: Text(
                  teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.4,
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4,
                ),
              ),
            ),
    );
  }
}
