import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkcle/main.dart';
import 'package:parkcle/payment.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {

  String currentTime = DateFormat('EEEE, MMMM d, y HH:mm:ss').format(DateTime.now());

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _updateTime();
  }

  void _updateTime(){
    if(!mounted) return;
    Future.delayed(const Duration(seconds: 1), (){
      if(mounted){
        setState(() {
          currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        });
        _updateTime();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
    );
    if(pickedDate != null){
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
    );

    if(pickedTime != null){
      setState(() {
        final now = DateTime.now();
        final selectedTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute
          );
        _timeController.text = DateFormat('hh:mm a').format(selectedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.asset('assets/logo.png', height: 50),
                    const GradientText(
                      'arCle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 247, 255, 5),
                            Color.fromARGB(222, 8, 255, 24),
                          ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: Offset(0, 3),
                        blurRadius: 5,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Booking Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        currentTime,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Select Date',
                                suffixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),
                          ),

                          const SizedBox(width: 20),

                          Expanded(
                            child: TextField(
                              controller: _timeController,
                              decoration: const InputDecoration(
                                labelText: 'Select Time',
                                suffixIcon: Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              decoration: const BoxDecoration(),
                            ),
                          ),

                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              decoration: const BoxDecoration(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PaymentPage(),
                              ),
                            );
                          },
                          child: const Text("Proceed to Checkout",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
