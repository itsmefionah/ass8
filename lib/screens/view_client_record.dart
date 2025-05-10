import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewClientRecord extends StatefulWidget {
  final DocumentSnapshot est;
  final String name;

  const ViewClientRecord({super.key, required this.est, required this.name});

  @override
  State<ViewClientRecord> createState() => _ViewClientRecordState();
}

class _ViewClientRecordState extends State<ViewClientRecord> {
  @override
  Widget build(BuildContext context) {
    String durationText = "";
    if (widget.est['timeout'] != null) {
      final DateTime timeIn = widget.est['timein'].toDate();
      final DateTime timeOut = widget.est['timeout'].toDate();
      final Duration duration = timeOut.difference(timeIn);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Visit Details",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              widget.est['timeout'] == null
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.est['timeout'] == null
                              ? "Currently Inside"
                              : "Visit Completed",
                          style: TextStyle(
                            color:
                                widget.est['timeout'] == null
                                    ? Colors.green.shade800
                                    : Colors.blue.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionHeader("Visit Information"),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeCard(
                              "TIME IN",
                              DateFormat(
                                'MMMM d, y',
                              ).format(widget.est['timein'].toDate()),
                              DateFormat(
                                'h:mm a',
                              ).format(widget.est['timein'].toDate()),
                              Icons.login,
                              Colors.indigo.shade100,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeCard(
                              "TIME OUT",
                              widget.est['timeout'] == null
                                  ? "Not yet"
                                  : DateFormat(
                                    'MMMM d, y',
                                  ).format(widget.est['timeout'].toDate()),
                              widget.est['timeout'] == null
                                  ? "Pending"
                                  : DateFormat(
                                    'h:mm a',
                                  ).format(widget.est['timeout'].toDate()),
                              Icons.logout,
                              widget.est['timeout'] == null
                                  ? Colors.grey.shade200
                                  : Colors.amber.shade100,
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
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        const Divider(color: Colors.black, thickness: 1.5),
      ],
    );
  }

  Widget _buildTimeCard(
    String title,
    String date,
    String time,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            date,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
