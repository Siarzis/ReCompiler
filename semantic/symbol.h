typedef enum {
	SYMBOL_GLOBAL,
	SYMBOL_LOCAL,
	SYMBOL_PARAM
} symbol_token;


struct symbol {
	symbol_token kind;
	struct type *type;
	char *name;
	int which;
};

typedef struct {
	char *key;
	struct symbol *value;
} item;

typedef struct {
	int size;
	int count;
	item **items; //array of pointers to items, so "**" is used
} hash_table;

typedef struct stack {
	int level;
	struct stack *prevScope;
	hash_table *entries;
} Scope;

extern Scope *currentScope;

hash_table * hashtable_init();
struct symbol * symbol_create(symbol_token kind, struct type *type, char *name);
void scope_enter();
void scope_exit();
int scope_level();
void scope_bind(const char *name, struct symbol *sym);
struct symbol * scope_lookup( const char *name);
struct symbol * scope_lookup_current( const char *name);