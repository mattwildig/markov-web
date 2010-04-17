#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <time.h>

static const char* DEFAULT_SENTINEL_WORD = "SENTINEL_WORD";
static const int DEFAULT_PREFIX_LENGTH = 2;
static const int DEFAULT_STATE_TABLE_SIZE = 4093; //4093 is from Practice of Programming

typedef struct SuffixNode SuffixNode;
typedef struct StateNode StateNode;

typedef struct {
	int prefix_len;
	const char* sentinel_word;
	
	int statetab_len;
	StateNode** statetab;

} MarkovData;

struct SuffixNode {
	const char* suffix;
	SuffixNode* next;
};

struct StateNode {
	const char** prefix;
	SuffixNode* list;
	StateNode* next;
};

static int hash_prefix(MarkovData* d, const char** prefix) {
	unsigned int h = 0;
	
	for (int i = 0; i < d->prefix_len; i++) {
		for (const char* c = prefix[i]; *c != '\0'; c++) {
			h = 31 * h + *c;
		}
	}
	
	return h % d->statetab_len;
}

static int prefix_match(const char** prefix1, const char** prefix2, int num_words) {
    for (int i = 0; i < num_words; i++) {
        if (strcmp(prefix1[i], prefix2[i]) != 0) {
            return 0;
        }
    }
    return 1;
}

static StateNode* lookup_state(MarkovData* data, const char** prefix) {
    
    int h = hash_prefix(data, prefix);
    
    for (StateNode* node = data->statetab[h]; node != NULL; node = node->next) {
        if (prefix_match(node->prefix, prefix, data->prefix_len)) {
            return node;
        }
    }
    return NULL;
}

static void add_suffix(MarkovData* data, const char** prefix, const char* word) {
    
    StateNode* state_node = lookup_state(data, prefix);
    
    if (state_node == NULL) {
        state_node = malloc(sizeof(StateNode));
        
        state_node->prefix = malloc(sizeof(char*) * data->prefix_len);
        for(int i = 0; i < data->prefix_len; i++)
        {
            state_node->prefix[i] = prefix[i];
        }
        state_node->list = NULL;
        int h = hash_prefix(data, prefix);
        state_node->next = data->statetab[h];
        data->statetab[h] = state_node;
    }
    
    SuffixNode* suffix_node = malloc(sizeof(SuffixNode));
    suffix_node->suffix = word;
    suffix_node->next = state_node->list;
    state_node->list = suffix_node;
}

static void rotate_prefix(MarkovData* data, const char** prefix, const char* word) {
    memmove(prefix, prefix+1, data->prefix_len * sizeof(prefix[0]));
    prefix[data->prefix_len - 1] = word;
}

static void prepopulate_prefix(MarkovData* data, const char** prefix) {
    for (int i = 0; i < data->prefix_len; i++) {
        prefix[i] = data->sentinel_word;
    }
}

void parse_input(MarkovData* data, FILE* input) {
	const int buf_size = 100;  //TODO: handle possibility of words > 100 chars in length
	char buf[buf_size];

	char fmt[10];
	sprintf(fmt, "%%%ds", buf_size -1);
	
    const char* prefix[data->prefix_len];
    prepopulate_prefix(data, prefix);
	
	while (fscanf(input, fmt, buf) != EOF) {
        char* const word = strdup(buf); //TODO: check for errors on strdup
        add_suffix(data, prefix, word);
        rotate_prefix(data, prefix, word);
	}
	
    add_suffix(data, prefix, data->sentinel_word);
}

MarkovData* init_markov() { //TODO: allow defaults to be overridden
	MarkovData* d = malloc(sizeof(MarkovData));	
	d->statetab = malloc(sizeof(StateNode*) * DEFAULT_STATE_TABLE_SIZE);
	d->statetab_len = DEFAULT_STATE_TABLE_SIZE;
	
    for (int i = 0; i < d->statetab_len; i++) {
        d->statetab[i] = NULL;
    }
	
	d->prefix_len = DEFAULT_PREFIX_LENGTH;
	d->sentinel_word = DEFAULT_SENTINEL_WORD;
	
	//TODO: error checking on mallocs
	
	return d;
}

void dump_table(MarkovData* data) {
    for (int tab_entry = 0; tab_entry < data->statetab_len; tab_entry++) {        
        for(StateNode* node = data->statetab[tab_entry]; node != NULL; node = node->next){
            for (int i = 0; i < data->prefix_len; i++) {
                printf("%s ", node->prefix[i]);
            }
            printf("\n\t");
            for(SuffixNode* suf = node->list; suf != NULL; suf = suf->next) {
                printf("%s ", suf->suffix);
            }
            printf("\n");
        }
    }
}

void generate(MarkovData* data, FILE* dest, int max_words) {
    const char* prefix[data->prefix_len];
    prepopulate_prefix(data, prefix);
    
    srand(time(NULL));
    
    while(max_words-- > 0) {
        StateNode* state = lookup_state(data, prefix); //possibly should check for null, but should always exist
        
        const char* word;
        int count = 0;
        for(SuffixNode* s = state->list; s != NULL; s = s->next) {
            if (rand() % ++count == 0) {
                word = s->suffix;
            }
        }
        
        if (strcmp(word, data->sentinel_word) == 0) {
            return;
        }
        
        fprintf(dest, "%s ", word);
        
        rotate_prefix(data, prefix, word);
    }
}

int main (int argc, char const *argv[])
{
	if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        exit(1);
    }
    
    FILE *file;
    if (! (file = fopen(argv[1], "r"))) {
        fprintf(stderr, "Error opening file \"%s\": %s\n", argv[1], strerror(errno));
        exit(2);
    }
	
    MarkovData* d = init_markov();
    
    parse_input(d, file);
    
    generate(d, stdout, 200);
    printf("\n");
    //dump_table(d);
	
	return 0;
}