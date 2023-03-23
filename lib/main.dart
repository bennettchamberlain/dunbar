import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dunbar/contact_model.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MainPage()));
}

class ConsistentContact extends StatefulWidget {
  @override
  _ConsistentContactState createState() => _ConsistentContactState();
}

class _ConsistentContactState extends State<ConsistentContact> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddContact()),
            );
          },
        )
      ], title: Text('Constant Contact')),
      body: _body());

  Widget _body() {
    if (_permissionDenied) return Center(child: Text('Permission denied'));
    if (_contacts == null) return Center(child: CircularProgressIndicator());
    return ListView.builder(
        itemCount: _contacts!.length,
        itemBuilder: (context, i) => ListTile(
            trailing: Icon(Icons.add_circle_outline_outlined),
            title: Text(_contacts![i].displayName),
            onTap: () async {
              final fullContact =
                  await FlutterContacts.getContact(_contacts![i].id);

              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ContactPage(fullContact!)));
            }));
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;
  ContactPage(this.contact);

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(contact.displayName)),
      body: Center(
        child: Column(children: [
          Text('First name: ${contact.name.first}'),
          Text('Last name: ${contact.name.last}'),
          Text(
              'Phone number: ${contact.phones.isNotEmpty ? contact.phones.first.number : '(none)'}'),
          Text(
              'Email address: ${contact.emails.isNotEmpty ? contact.emails.first.address : '(none)'}'),
        ]),
      ));
}

class AddContact extends ConsumerWidget {
  AddContact({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactList = ref.watch(contactListProvider);
    final contactListNotifier = ref.watch(contactListProvider.notifier);
    var nameController = TextEditingController();
    var addressController = TextEditingController();
    var socialController = TextEditingController();
    var emailController = TextEditingController();
    var notesController = TextEditingController();
    var numberController = TextEditingController();

    return Scaffold(
        appBar: AppBar(
          title: Text('Add Contact'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //create a form taking user input for name, number, and email, address, birthday and notes
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  TextFormField(
                    controller: numberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                    ),
                  ),
                  TextFormField(
                    controller: socialController,
                    decoration: InputDecoration(
                      labelText: 'Social Media',
                    ),
                  ),
                  TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
                  //create a button that adds the contact to the list
                  ElevatedButton(
                    onPressed: () {
                      contactListNotifier.addContact(
                        Contact(
                          name: Name(
                            first: nameController.text,
                          ),
                          phones: [
                            Phone(
                              numberController.text,
                            )
                          ],
                          emails: [
                            Email(
                              emailController.text,
                            )
                          ],
                          addresses: [
                            Address(
                              addressController.text,
                            )
                          ],
                          socialMedias: [
                            SocialMedia(
                              socialController.text,
                            )
                          ],
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class MainPage extends StatelessWidget {
  MainPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: AppBarTheme(color: Color.fromARGB(255, 255, 79, 138))),
      home: PageOne(),
    );
  }
}

class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddContact()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.contacts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConsistentContact()),
              );
            },
          ),
        ],
        title: Text("Today's Calls"),
      ),
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final contactList = ref.watch(contactListProvider);
            return ListView(
              children: contactList
                  .map((contact) => ListTile(
                        title: Text(contact.name.first),
                        subtitle: Text(contact.phones.first.number),
                        trailing: Icon(Icons.call),
                        onTap: () => Center(
                          child: Column(children: [
                            Text('First name: ${contact.name.first}'),
                            Text('Last name: ${contact.name.last}'),
                            Text(
                                'Phone number: ${contact.phones.isNotEmpty ? contact.phones.first.number : '(none)'}'),
                            Text(
                                'Email address: ${contact.emails.isNotEmpty ? contact.emails.first.address : '(none)'}'),
                          ]),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
