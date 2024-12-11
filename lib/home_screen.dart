import 'package:best_location/map_screen.dart';
import 'package:best_location/model/location.dart';
import 'package:best_location/services/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Location> locations = [];
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final _pseudoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    getLocations();
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _numeroController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> getLocations() async {
    try {
      List<Location> fetchedLocations = [];
      await ApiService.get(endPoint: "").then((value) {
        for (var item in value) {
          fetchedLocations.add(Location.fromJson(item));
        }
      });
      setState(() {
        locations = fetchedLocations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations ${e.toString()}')),
      );
    }
  }

  void _showAddLocationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Center(
                            child: const Text(
                              'Add New Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pseudoController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        prefixIcon: Icon(Icons.call),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) is! double) {
                                return 'Invalid Latitude';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _longController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) is! double) {
                                return 'Invalid Longitude';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        primary: const Color(0xFF570DE6), // Button color
                        textStyle: const TextStyle(
                          color: Colors.white, // Ensures text is white
                          fontWeight: FontWeight.bold, // Optional: Bold text
                          fontSize: 16, // Optional: Font size
                        ),
                      ),
                      child: const Text(
                        'Add Location',
                        style: TextStyle(
                          color:
                              Colors.white, // Ensures the text color is white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final newLocation = Location(
        pseudo: _pseudoController.text,
        numero: _numeroController.text,
        lat: double.parse(_latController.text).toString(),
        long: double.parse(_longController.text).toString(),
      );

      await ApiService.post(endPoint: "", body: newLocation.toJson());

      // Clear form
      _pseudoController.clear();
      _numeroController.clear();
      _latController.clear();
      _longController.clear();
      await getLocations();
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF570DE6),
        title: Center(
          child: const Text(
            'Your Friends Locations',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white, // Set the refresh icon color to white
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              getLocations();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Bar with Buttons
          Container(
            width: double.infinity,
            color: const Color(0xFF570DE6),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              spacing: 8, // Space between buttons
              runSpacing: 8, // Space between rows
              alignment: WrapAlignment.center, // Center the buttons
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(locations: locations),
                      ),
                    );
                    setState(() {
                      isLoading = true;
                    });
                    await getLocations();
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('View Map'),
                  style: ElevatedButton.styleFrom(primary: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final newLocation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(
                          locations: locations,
                          isAddingLocation: true,
                        ),
                      ),
                    );
                    if (newLocation != null) {
                      setState(() {
                        locations.add(newLocation);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Location added successfully')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Add Location on Map'),
                  style: ElevatedButton.styleFrom(primary: Colors.white),
                ),
                /*ElevatedButton.icon(
                  onPressed: _showAddLocationSheet,
                  icon: const Icon(Icons.add_box),
                  label: const Text('Add Location'),
                  style: ElevatedButton.styleFrom(primary: Colors.white),
                ),*/
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (locations.isEmpty && !isLoading)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No locations found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddLocationSheet,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Location'),
                          style:
                              ElevatedButton.styleFrom(primary: Colors.white),
                        ),
                      ],
                    ),
                  )
                else if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.builder(
                    padding: const EdgeInsets.all(
                        16), // Apply padding to the entire list
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return Card(
                        color: const Color(0xFFBDAFFF),
                        margin: const EdgeInsets.only(
                          bottom: 16), // Spacing between cards
                        elevation: 2, 
                        // Shadow for the card
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                              16), // Padding inside each card
                          title: Text(
                            location.pseudo ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    location.numero ?? 'N/A',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${location.lat ?? 'N/A'}, ${location.long ?? 'N/A'}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Location'),
                                  content: const Text(
                                      'Are you sure you want to delete this location?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // Call delete API and refresh list
                                        await ApiService.delete(
                                            "/${location.id}");
                                        await getLocations();
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
