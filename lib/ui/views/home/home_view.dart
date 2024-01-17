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
                  return ListTile(
                    title: GestureDetector(
                        onTap: () async {
                          viewModel.updateCurrentPrompt(promptList[index]);
                          await viewModel.navigateToGeminiChat();
                        },
                        child: Text(promptList[index])),
                    trailing: IconButton(
                        onPressed: () async {
                          await viewModel.deletePrompt(promptList[index]);
                        },
                        icon: const Icon(Icons.delete)),
                    // Add any other information you want to display
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();
}
