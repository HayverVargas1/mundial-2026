import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../models/channel_model.dart';
import '../../services/iptv_service.dart';
import 'video_player_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({Key? key}) : super(key: key);

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final IptvService _iptvService = IptvService();
  late Future<List<ChannelModel>> _channelsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _channelsFuture = _iptvService.fetchSportsChannels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('En Vivo', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _channelsFuture = _iptvService.fetchSportsChannels();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.amber.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Canales de terceros. Enlaces públicos sujetos a disponibilidad y geobloqueos.',
                    style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar canal...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          Expanded(
            child: FutureBuilder<List<ChannelModel>>(
              future: _channelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No se pudieron cargar los canales públicos en este momento.', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }

                final allChannels = snapshot.data!;
                final channels = _searchQuery.isEmpty 
                    ? allChannels 
                    : allChannels.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();

                if (channels.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron canales.', style: TextStyle(color: AppColors.textSecondary)),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
                      child: Row(
                        children: [
                          Text('${allChannels.length} canales cargados', 
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)
                          ),
                          if (_searchQuery.isNotEmpty)
                            Text(' (${channels.length} resultados)', 
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: channels.length,
                          itemBuilder: (context, index) {
                            final channel = channels[index];
                            return Card(
                              color: AppColors.surface,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: channel.logoUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: channel.logoUrl,
                                        width: 40,
                                        height: 40,
                                        errorWidget: (context, url, error) => const Icon(Icons.tv, color: AppColors.textSecondary),
                                      )
                                    : const Icon(Icons.tv, color: AppColors.primary, size: 32),
                                title: Text(channel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(channel.group, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                trailing: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 32),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(channel: channel),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
