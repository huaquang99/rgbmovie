import 'package:flutter/material.dart';
import 'package:movie_app_ui/api/user_api.dart';
import 'package:movie_app_ui/core/constants/app_colors.dart';
import 'package:movie_app_ui/features/auth/helper/app_constants.dart';
import 'package:movie_app_ui/features/auth/helper/extensions.dart';
import 'package:movie_app_ui/features/auth/widgets/form_input.dart';
import 'package:movie_app_ui/features/movies/movies_page.dart';
import 'package:movie_app_ui/models/user_model.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key, required this.username});
  final String username;
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  UserModel? userModel;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  Future<void>? getUserFuture;

  @override
  void initState() {
    super.initState();
    getUserFuture = getUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> getUser() async {
    UserModel result = await UserApi().getUser(widget.username);
    setState(() {
      userModel = result;
      nameController.text = userModel?.username ?? '';
      emailController.text = userModel?.email ?? '';
      firstNameController.text = userModel?.firstName ?? '';
      lastNameController.text = userModel?.lastName ?? '';
      phoneNumberController.text = userModel?.phoneNumber ?? '';
    });
  }

  final _formKey = GlobalKey<FormState>();

  // FocusNode confirmFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final size = context.mediaQuerySize;
    return Scaffold(
        body: FutureBuilder(
            future: getUserFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show loading spinner while waiting
              } else {
                return Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Container(
                        height: size.height * 0.24,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.lightBlue,
                              AppColors.blue,
                              AppColors.darkBlue,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 15,
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Hello',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  'Edit your account',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppTextFormField(
                              labelText: 'Name',
                              autofocus: true,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) =>
                                  _formKey.currentState?.validate(),
                              validator: (value) {
                                return value!.isEmpty
                                    ? 'Please, Enter Name '
                                    : value.length < 4
                                        ? 'Invalid Name'
                                        : null;
                              },
                              controller: nameController,
                            ),
                            AppTextFormField(
                              labelText: 'First Name',
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) =>
                                  _formKey.currentState?.validate(),
                              validator: (value) {
                                return value!.isEmpty
                                    ? 'Please, Enter Name '
                                    : value.length < 4
                                        ? 'Invalid Name'
                                        : null;
                              },
                              controller: firstNameController,
                            ),
                            AppTextFormField(
                              labelText: 'Last Name',
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) =>
                                  _formKey.currentState?.validate(),
                              validator: (value) {
                                return value!.isEmpty
                                    ? 'Please, Enter Name '
                                    : value.length < 4
                                        ? 'Invalid Name'
                                        : null;
                              },
                              controller: lastNameController,
                            ),
                            AppTextFormField(
                              labelText: 'Phone',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) =>
                                  _formKey.currentState?.validate(),
                              validator: (value) {
                                return value!.isEmpty
                                    ? 'Please, Enter Name '
                                    : value.length < 4
                                        ? 'Invalid Name'
                                        : null;
                              },
                              controller: phoneNumberController,
                            ),
                            AppTextFormField(
                              labelText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                setState(() {
                                  _formKey.currentState?.validate();
                                });
                              },
                              validator: (value) {
                                return value!.isEmpty
                                    ? 'Please, Enter Email Address'
                                    : AppConstants.emailRegex.hasMatch(value)
                                        ? null
                                        : 'Invalid Email Address';
                              },
                              controller: emailController,
                            ),
                            FilledButton(
                              onPressed: _formKey.currentState?.validate() ??
                                      false
                                  ? () async {
                                      UserModel data = UserModel(
                                        pk: userModel!.pk,
                                        username: nameController.text,
                                        password: userModel!.password,
                                        lastName: lastNameController.text,
                                        firstName: firstNameController.text,
                                        email: emailController.text,
                                        phoneNumber: phoneNumberController.text,
                                        enabled: true,
                                      );
                                      UserModel result =
                                          await UserApi().editUser(data);

                                      if (result != null) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Login'),
                                              content: Text('Success'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const MoviesPage())),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Error"),
                                              content: Text(result.toString()),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'OK'),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  : null,
                              style: const ButtonStyle().copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                  _formKey.currentState?.validate() ?? true
                                      ? null
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            }));
  }
}
