import 'package:flutter/material.dart';
import 'package:dictionary_app/Dictionary App/dictionary_model.dart';

import 'services.dart';

class DictionaryHomePage extends StatefulWidget {
  const DictionaryHomePage({super.key});

  @override
  State<DictionaryHomePage> createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  DictionaryModel? myDictionaryModel;
  bool isLoading = false;
  String noDataFound="Now you can Search";
  
  searchContain(String word) async{
    setState(() {
      isLoading=true;
    });
    try{
      myDictionaryModel=await APIservices.fetchData(word);
      setState(() {});
    }catch(e){
      myDictionaryModel=null;
      noDataFound="Meaning can't be found";
    }finally{
      setState(() {
        isLoading=false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            SearchBar(
              hintText: "Search the word here",
              onSubmitted: (value){
                searchContain(value);
              },
            ),
            const SizedBox(height: 10,),
            if(isLoading)
              const LinearProgressIndicator()
            else if(myDictionaryModel!=null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15,),
                    Text(myDictionaryModel!.word,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.blue),),
                    Text(myDictionaryModel!.phonetics.isNotEmpty? myDictionaryModel!.phonetics[0].text??"":"",),
                    const SizedBox(height: 10,),
                    Expanded(
                        child: ListView.builder(
                          itemCount: myDictionaryModel!.meanings.length,
                          itemBuilder: (context,index){
                            return showMeaning(
                              myDictionaryModel!.meanings[index]
                            );
                          },
                        ),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Text(
                  noDataFound,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
          ],
        ),
      ),
    );
  }

  showMeaning(Meaning meaning){
    String wordDefination="";
    for(var element in meaning.definitions){
      int index=meaning.definitions.indexOf(element);
      wordDefination+="\n${index+1}.${element.definition}\n";
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meaning.partOfSpeech,style: const TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.blue),),
              const SizedBox(height: 10,),
              const Text("Defination : ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
              Text(wordDefination,style: const TextStyle(fontSize: 16,height: 1),),
              wordRelation("Synonyms", meaning.synonyms),
              wordRelation("Antonyms", meaning.antonyms),
            ],
          ),
        ),
      ),
    );
  }

  wordRelation(String title,List<String>? setList){
    if(setList?.isNotEmpty?? false){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title : ", style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
          Text(setList!.toSet().toString().replaceAll("{","").replaceAll("}", ""), style: const TextStyle(fontSize: 18),),
          const SizedBox(height: 10,),
        ],
      );
    }else{
      return const SizedBox();
    }
  }
}
