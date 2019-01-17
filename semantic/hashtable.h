typedef struct {
	char *key;
	int value;
} item;

typedef struct {
	int size;
	int count;
	item **items; //array of pointers to items, so "**" is used
} hash_table;

static item * item_init (const char *key, const int value);
hash_table * hashtable_init();
static void del_item(item* i);
void del_hashtable(hash_table* ht);
static int hash_function(const char *s, const int a, const int m);
static int get_hash(const char *s, const int num_buckets, const int attempt);
void insert(hash_table *ht, const char *key, const int value);
char * search(hash_table *ht, const char *key);
void deleted(hash_table *h, const char *key);