import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_dictionary/core/constants/widgets.dart';
import 'package:one_dictionary/core/themes/app_theme.dart';
import 'package:one_dictionary/data/models/model.dart';
import 'package:one_dictionary/logic/search_word/search_word_cubit.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/strings.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  TextEditingController searchController = TextEditingController();
  AudioPlayer audioPlayer = AudioPlayer();

  HomeScreen({Key? key}) : super(key: key);

  onSearch(context) {
    if (searchController.text.isNotEmpty) {
      BlocProvider.of<SearchWordCubit>(context)
          .storeData(searchController.text);
    }
  }

  player(List<Phonetics> list) async {
    String? url;
    for (var i = 0; i < list.length; i++) {
      if (list[i].audio != null) {
        url = list[i].audio.toString();

        continue;
      }
    }
    int res = await audioPlayer.play(url ?? "");
    if (res == 1) {}
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '1Dictionary',
            style: TextStyle(color: Strings.appDarkBlue),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<SearchWordCubit, SearchWordState>(
          builder: (context, searchState) {
            return Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 55,
                          width: size.width * 0.75,
                          child: textFieldWidget(context),
                        ),
                        InkWell(
                          onTap: () {
                            onSearch(context);
                            FocusScope.of(context).unfocus();
                          },
                          child: Container(
                              color: Strings.appDarkBlue,
                              height: 50,
                              width: 55,
                              child: const Icon(
                                Icons.check,
                                color: Color(0xFFFFFFFF),
                              )),
                        )
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                searchState.data == null
                    ? const SizedBox()
                    : SizedBox(
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              searchState.data!.word.toString(),
                              style: MyTextStyle.wordTitle,
                            ),
                            Text(
                              searchState.data!.phonetics![0].text.toString(),
                              style: MyTextStyle.notationTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                            IconButton(
                              onPressed: () {
                                player(searchState.data!.phonetics!);
                              },
                              icon: const Icon(
                                Icons.volume_up_rounded,
                                color: Strings.appMidGrey,
                              ),
                            )
                          ],
                        ),
                      ),
                Container(
                    padding: const EdgeInsets.all(20),
                    height: size.height / 1.4,
                    child: searchState.data != null
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            shrinkWrap: true,
                            itemCount: searchState.data!.meanings!.length,
                            itemBuilder: (context, i) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AppWidgets.sizeHeight10,
                                  Text(
                                    '${searchState.data!.meanings![i].partOfSpeech}',
                                    style: MyTextStyle.bodyText1Bold,
                                  ),
                                  AppWidgets.sizeHeight10,
                                  Text(
                                    '${searchState.data!.meanings![i].definitions![0].definition}',
                                    style: MyTextStyle.bodyText1,
                                  ),
                                  searchState.data!.meanings![i].definitions![0]
                                              .example !=
                                          null
                                      ? AppWidgets.sizeHeight10
                                      : const SizedBox(),
                                  searchState.data!.meanings![i].definitions![0]
                                              .example !=
                                          null
                                      ? Text(
                                          'Example - ${searchState.data!.meanings![i].definitions![0].example}',
                                          style: MyTextStyle.bodyText1,
                                        )
                                      : const SizedBox(),
                                ],
                              );
                            },
                          )
                        : const SizedBox())
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
            tooltip: 'Search',
            elevation: 0.0,
            child: const Icon(Icons.check),
            backgroundColor: Strings.appDarkBlue,
            onPressed: () {
              onSearch(context);
              FocusScope.of(context).unfocus();
            }),
      ),
    );
  }

  TextField textFieldWidget(context) {
    return TextField(
      onEditingComplete: () {
        onSearch(context);
        FocusScope.of(context).unfocus();
      },
      textInputAction: TextInputAction.done,
      controller: searchController,
      maxLines: 1,
      decoration: const InputDecoration(
          isDense: true,
          filled: true,
          prefixIcon: Icon(Icons.search),
          hintText: 'Search',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.zero, borderSide: BorderSide.none)),
    );
  }
}
