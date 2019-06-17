#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

int charSum(char*);

int main(int argc, char *argv[]){

	// Check for correct arguments
	if (argc != 2 && argc != 3){
		printf("Usage: anagram_solver [anagram] [dictionary]\n");
		return 1;
	}

	char *anagram = argv[1];
	char *dictionary = argv[2];
	printf("Anagram Solver\n");
	printf("---------------------------------------------\n");
	printf("Starting anagram solver for word \"%s\" with dictionary file \"%s\"\n", anagram, dictionary);

	// Check if dictionary file exists and is readable
	FILE *dictionary_ptr = fopen(dictionary, "r");
	if (dictionary_ptr == NULL)
	{
		printf("Could not open %s.\n", dictionary);
		return 1;
	}

	// Calculate sum of characters in anagram
	int anagramCharSum = charSum(anagram);

	// We'll use this var as a temporary store for each word to check
	char word[80];
	int index = 0;
	int wordCharSum = 0;
	int wordsChecked = 0;
	bool letterFound = false;

	// Now iterate through each word in the dictionary file
	for (int c = fgetc(dictionary_ptr); c != EOF; c = fgetc(dictionary_ptr))
	{
		if (isalpha(c)){
			word[index] = c;
			index++;
		} else {
			word[index] = '\0';
			wordsChecked++;
			wordCharSum = charSum(word);

			if (wordCharSum == anagramCharSum){
				int matchingChars = 0;
				letterFound = true;
				for (int c = 0; c < strlen(anagram); c++){
					for (int d = 0; d < strlen(word); d++){
						if (anagram[c] == word[d]){
							matchingChars++;
							break;
						}
					}
				}
				if (letterFound &&
					matchingChars == strlen(anagram) &&
					strlen(anagram) == strlen(word)){
						printf("Found solution: %s\n", word);
						break;
				}
			}
			index = 0;
		}
	}

	return 0;
}

int charSum(char *word){
	int char_sum = 0;
	for (int i = 0; i < strlen(word); i++){
		char_sum += word[i] - 96;
	}
	return char_sum;
}
