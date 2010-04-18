#include <stdio.h>

typedef struct MarkovData MarkovData;

MarkovData* markov_init();

void markov_set_sentinel_word(MarkovData* data, char* word);
void markov_set_prefix_len(MarkovData* data, int len);
void markov_set_table_size(MarkovData* data, int size);

void markov_add_input(MarkovData* data, FILE* input);

int markov_generate(MarkovData* data, FILE* dest, int max_words);

void markov_free(MarkovData* data);
