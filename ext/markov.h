#include <stdio.h>

typedef struct MarkovData MarkovData;

MarkovData* markov_init();

void markov_set_sentinel_word(MarkovData* data, char* word);
void markov_set_prefix_len(MarkovData* data, int len);
void markov_set_table_size(MarkovData* data, int size);
void markov_set_output_words(MarkovData* data, int words);

void markov_add_input_from_stream(MarkovData* data, FILE* input);
void markov_add_input_from_string(MarkovData* data, char* string);

int markov_generate_to_stream(MarkovData* data, FILE* dest, int max_words);
char* markov_generate_to_string(MarkovData* data, int max_words);

void markov_free(MarkovData* data);
