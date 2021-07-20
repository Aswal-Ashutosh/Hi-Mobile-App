import 'package:flutter/material.dart';
import 'package:hi/constants/constants.dart';
import 'package:hi/custom_widget/buttons/primary_button.dart';
import 'package:hi/services/firebase_service.dart';

class AddFriends extends StatelessWidget {
  const AddFriends();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(context: context, builder: (cotext) => AddByEmail());
        },
        child: Icon(Icons.add),
        backgroundColor: kPrimaryColor,
      ),
      body: Container(
        child: Column(
          children: [
            SearchTextField(),
            //List,
          ],
        ),
      ),
    );
  }
}

//Bottom Sheet 
class AddByEmail extends StatefulWidget {
  @override
  _AddByEmailState createState() => _AddByEmailState();
}

class _AddByEmailState extends State<AddByEmail> {
  final _borderRadius = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(kDefualtBorderRadius * 2)),
    borderSide: BorderSide(color: kPrimaryColor),
  );

  final _formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();

  final _validator = (String? value) => value!.trim().isEmpty ? 'Enter an email.' : null;

  String? firebaseError;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF737373),
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding / 2.0, vertical: kDefaultPadding),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _textEditingController,
                  validator: _validator,
                  textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: firebaseError,
                  filled: true,
                  fillColor: const Color(0x112EA043),
                  labelText: 'Your friend\'s email',
                  enabledBorder: _borderRadius,
                  focusedBorder: _borderRadius,
                  errorBorder: _borderRadius,
                  focusedErrorBorder: _borderRadius,
                  prefixIcon: Icon(Icons.mail),
                ),
                ),
              ),
            ),
            SizedBox(height: kDefaultPadding / 4.0),
            PrimaryButton(displayText: 'Send Request', onPressed: () async{
              if(_formKey.currentState!.validate()){
                firebaseError = null;
                await FirebaseService.sendFriendRequest(recipientEmail: _textEditingController.text.trim()).catchError((error){
                  setState(() {
                    firebaseError = error;
                  });
                });
              }
            })
          ],
        ),
        height: MediaQuery.of(context).size.height / 2.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(kDefualtBorderRadius),
            topRight: Radius.circular(kDefualtBorderRadius),
          ),
        ),
      ),
    );
  }
}

//Search Text Field
class SearchTextField extends StatelessWidget {
  const SearchTextField(
      {final OutlineInputBorder borderRadius = const OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(kDefualtBorderRadius / 2.0)),
        borderSide: BorderSide(color: kPrimaryColor),
      )})
      : _borderRadius = borderRadius;

  final OutlineInputBorder _borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(kDefaultPadding / 4.0),
      child: TextField(
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'search friends by name',
          prefixIcon: Icon(Icons.search),
          enabledBorder: _borderRadius,
          focusedBorder: _borderRadius,
        ),
      ),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(kDefualtBorderRadius / 2.0)),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(blurRadius: 0.2)
          ]),
    );
  }
}
