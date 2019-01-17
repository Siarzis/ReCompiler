struct symbol {
	symbol_t kind;
	struct type *type;
	char *name;
	int which;
};

typedef enum {
	SYMBOL_LOCAL,
	SYMBOL_PARAM,
	SYMBOL_GLOBAL
} symbol_token;

typedef struct {
	int level;
	Scope *prevScope;
	hash_table *entries;
} Scope;

typedef struct {
	char *key;
	struct symbol *value;
} item;

typedef struct {
	int size;
	int count;
	item **items; //array of pointers to items, so "**" is used
}hash_table;

void scope_enter();
void scope_exit();
int scope_level();
void scope_bind(const char *name, struct symbol *sym);
struct symbol * scope_lookup( const char *name);
struct symbol * scope_lookup_current( const char *name);