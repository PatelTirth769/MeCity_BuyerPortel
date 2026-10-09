import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mecity_marketplace/providers/event_provider.dart';
import 'package:mecity_marketplace/models/event.dart';
import 'package:mecity_marketplace/widgets/countdown_timer_widget.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mega Flash Deals & Events'),
      ),
      body: eventProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => eventProvider.fetchEvents(),
              color: Theme.of(context).primaryColor,
              child: eventProvider.events.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        alignment: Alignment.center,
                        child: Text(
                          eventProvider.errorMessage ?? 'No events currently active.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: eventProvider.events.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final event = eventProvider.events[index];
                        return _buildEventCard(context, event);
                      },
                    ),
            ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.network(
              event.bannerUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => Container(
                height: 180,
                color: Theme.of(context).primaryColor,
                child: const Center(child: Icon(Icons.celebration_rounded, color: Colors.white, size: 48)),
              ),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('🚀', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              'Ends in: ',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Flexible(
                              child: DefaultTextStyle(
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                child: CountdownTimerWidget(targetDate: event.endDate),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
