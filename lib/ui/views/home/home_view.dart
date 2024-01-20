import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("VirtuChat"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      viewModel.updateCurrentDP(context);
                    },
                    child: CircleAvatar(
                      backgroundImage: viewModel.currentUserDPUrl.isNotEmpty
                          ? NetworkImage(viewModel.currentUserDPUrl)
                          : null,
                      backgroundColor: viewModel.currentUserDPUrl.isNotEmpty
                          ? Colors.transparent
                          : Colors.black,
                      // Add your avatar logic here
                      // Example: backgroundImage: NetworkImage('your_avatar_url'),
                      radius: 30,
                      child: viewModel.currentUserDPUrl.isEmpty
                          ? Text(
                              viewModel.currentUserName.isNotEmpty
                                  ? viewModel.currentUserName[0]
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      viewModel.updateCurrentUsername(context);
                    },
                    child: Text(
                      viewModel.currentUserName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    viewModel.currentUserEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Add your settings logic here
                // Example: viewModel.navigateToSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Add your logout logic here
                viewModel.logout();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: StreamBuilder<List<String>>(
            stream: viewModel.getPrompts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Display loading indicator if prompts are still loading
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                // Handle error state
                return const Center(child: Text('Error loading prompts'));
              }

              // Extract the prompt list from the snapshot data
              List<String> promptList = snapshot.data ?? [];

              if (promptList.isEmpty) {
                // Display a message when prompt list is empty
                return const Center(child: Text('No prompts available'));
              }

              // Display the prompt list using ListView.builder
              return ListView.builder(
                itemCount: promptList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      viewModel.updateCurrentPrompt(promptList[index]);
                      await viewModel.navigateToGeminiChat();
                    },
                    child: ListTile(
                      tileColor: const Color(0xff17C3CE),
                      title: Text(promptList[index]),
                      trailing: IconButton(
                          onPressed: () async {
                            await viewModel.deletePrompt(promptList[index]);
                          },
                          icon: const Icon(Icons.delete)),
                      // Add any other information you want to display
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff17C3CE),
        onPressed: () {
          // Add your logic to handle the press of the add button
          // For example, showing a dialog to create a new prompt
          viewModel.showAddPromptDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void onViewModelReady(HomeViewModel viewModel) {
    viewModel.init();
    super.onViewModelReady(viewModel);
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}
