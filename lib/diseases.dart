import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DiseaseListPage extends StatelessWidget {
  const DiseaseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Diseases'),
        backgroundColor: Colors.teal, // Match your app's theme
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('disease_detections')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              final disease = data['disease'] ?? 'Unknown';
              final confidence = data['confidence'] ?? 0.0;
              final timestamp = data['timestamp']?.toDate() ?? DateTime.now();

              return ListTile(
                title: Text(disease),
                subtitle: Text(
                    'Confidence: ${confidence.toStringAsFixed(0)}%'),
              );
            },
          );
        },
      ),
    );
  }
}
