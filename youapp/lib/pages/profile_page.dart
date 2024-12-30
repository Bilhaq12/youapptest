import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "John Doe";
  String shortUsername = "@johndoe";
  String about = "";
  List<String> interests = [];
  File? _image;
  String? gender;
  DateTime? birthday;
  String? horoscope;
  String? zodiac;
  double? height;
  double? weight;
  bool isEditing = false;
  TextEditingController _interestController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _aboutController.text = about;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3A40),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(username, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Implement menu options (edit profile, settings, logout)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _getImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.camera_alt,
                            size: 40, color: Colors.white70)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  shortUsername,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),
              isEditing ? _buildEditForm() : _buildProfileInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        _buildSection(
          title: "About",
          content: about.isEmpty
              ? "Add in your about to help others know you better"
              : about,
          onEdit: _editAbout,
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: "Interest",
          content: interests.isEmpty
              ? "Add in your interest to find a better match"
              : interests.join(", "),
          onEdit: _editInterests,
        ),
        if (birthday != null) ...[
          const SizedBox(height: 16),
          _buildSection(
            title: "Personal Information",
            content: _getPersonalInfo(),
            onEdit: () {
              setState(() {
                isEditing = true;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _aboutController,
            decoration: const InputDecoration(labelText: 'About'),
            onSaved: (value) => about = value ?? '',
          ),
          DropdownButtonFormField<String>(
            value: gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: ['Male', 'Female', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                gender = value;
              });
            },
          ),
          TextFormField(
            initialValue: birthday != null
                ? DateFormat('yyyy-MM-dd').format(birthday!)
                : '',
            decoration:
                const InputDecoration(labelText: 'Birthday (YYYY-MM-DD)'),
            onSaved: (value) {
              if (value != null && value.isNotEmpty) {
                birthday = DateFormat('yyyy-MM-dd').parse(value);
                _calculateHoroscopeAndZodiac();
              }
            },
          ),
          TextFormField(
            initialValue: height?.toString(),
            decoration: const InputDecoration(labelText: 'Height (cm)'),
            keyboardType: TextInputType.number,
            onSaved: (value) => height = double.tryParse(value ?? ''),
          ),
          TextFormField(
            initialValue: weight?.toString(),
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
            keyboardType: TextInputType.number,
            onSaved: (value) => weight = double.tryParse(value ?? ''),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Save & Update'),
            onPressed: _saveProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required String content,
      required VoidCallback onEdit}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _editAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit About"),
        content: TextField(
          controller: _aboutController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Tell us about yourself"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              setState(() {
                about = _aboutController.text;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _editInterests() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit Interests"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _interestController,
                  decoration: InputDecoration(
                    hintText: "Enter an interest",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_interestController.text.isNotEmpty) {
                          setState(() {
                            interests.add(_interestController.text);
                            _interestController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        interests.add(value);
                        _interestController.clear();
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: interests
                      .map((interest) => Chip(
                            label: Text(interest),
                            onDeleted: () {
                              setState(() {
                                interests.remove(interest);
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("Save"),
                onPressed: () {
                  Navigator.of(context).pop();
                  this.setState(() {}); // Update the main state
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isEditing = false;
      });
    }
  }

  String _getPersonalInfo() {
    List<String> info = [];
    if (gender != null) info.add('Gender: $gender');
    if (birthday != null)
      info.add('Birthday: ${DateFormat('yyyy-MM-dd').format(birthday!)}');
    if (horoscope != null) info.add('Horoscope: $horoscope');
    if (zodiac != null) info.add('Zodiac: $zodiac');
    if (height != null) info.add('Height: ${height!.toStringAsFixed(1)} cm');
    if (weight != null) info.add('Weight: ${weight!.toStringAsFixed(1)} kg');
    return info.join('\n');
  }

  void _calculateHoroscopeAndZodiac() {
    if (birthday != null) {
      int month = birthday!.month;
      int day = birthday!.day;

      // Calculate Zodiac
      List<String> zodiacs = [
        'Rat',
        'Ox',
        'Tiger',
        'Rabbit',
        'Dragon',
        'Snake',
        'Horse',
        'Goat',
        'Monkey',
        'Rooster',
        'Dog',
        'Pig'
      ];
      zodiac = zodiacs[(birthday!.year - 1900) % 12];

      // Calculate Horoscope
      if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
        horoscope = 'Aries';
      } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
        horoscope = 'Taurus';
      } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
        horoscope = 'Gemini';
      } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
        horoscope = 'Cancer';
      } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
        horoscope = 'Leo';
      } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
        horoscope = 'Virgo';
      } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
        horoscope = 'Libra';
      } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
        horoscope = 'Scorpio';
      } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
        horoscope = 'Sagittarius';
      } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
        horoscope = 'Capricorn';
      } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
        horoscope = 'Aquarius';
      } else {
        horoscope = 'Pisces';
      }
    }
  }
}
