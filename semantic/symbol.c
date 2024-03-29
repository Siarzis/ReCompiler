#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"

Scope *currentScope = NULL;

static item * item_init (const char *key, const struct symbol *value) {
	item *i = malloc(sizeof(*i));
	i->key = strdup(key);
	i->value = value;
	return i;
}

static void del_item(item* i) {
	free(i->key);
	free(i->value);
	free(i);
}

hash_table * hashtable_init() {	
	hash_table *ht = malloc(sizeof(*ht));
	ht->size = 53;
	ht->count = 0;
	ht->items = calloc((size_t)ht->size, sizeof(item*));
	return ht;
}

static void del_hashtable(hash_table* ht) {
	for (int i = 0; i < ht->size; i++) {
		item *item = ht->items[i];
		if (item != NULL) {
			del_item(item);
		}
	}
	free(ht->items);
	free(ht);
}

static int hash_function(const char *str, const int prime, const int size) {
	long int hash = 0;
	const int length = strlen(str);

	for (int i = 0; i < length; i++) {
		hash += prime * str[i];
	}
	hash = hash % size;

	return hash;
}

static int get_hash(const char *str, const int size, const int attempt) {

	const int hash_a = hash_function(str, 151, size);
	const int hash_b = hash_function(str, 163, size);

	return (hash_a + (attempt * (hash_b + 1))) % size;
}

struct symbol * symbol_create(symbol_token kind, struct type *type, char *name) {
	struct symbol *s = malloc(sizeof(*s));
	
	s->kind = kind;
	s->type = type;
	s->name = name;
	
	return s;
}

void scope_enter() {
	Scope *newScope = malloc(sizeof(*newScope));

	newScope->prevScope = currentScope;	
	newScope->entries   = hashtable_init();

	if (currentScope == NULL) {
		newScope->level = 1;
	}
	else {
		newScope->level = currentScope->level + 1;
	}

	currentScope = newScope;
}

void scope_exit() {

	if (currentScope->entries) {
		//SymbolEntry *next = currentScope->entries->nextInScope;

		//hashTable[currentScope->entries->hashValue] = currentScope->entries->nextHash; 
		//destroyEntry(e);
		//currentScope->entries = next;
		del_hashtable(currentScope->entries);
	}

	currentScope = currentScope->prevScope;
	free(currentScope);
};

int scope_level() {
	if (currentScope)
		return currentScope->level;
	return 0;
};

void scope_bind (const char *var, struct symbol *sym) {
	hash_table *ht = currentScope->entries;
	int attempt = 1;

	item *i = item_init(var, sym);
	int index = get_hash(i->key, ht->size, 0);
	item *cur_item = ht->items[index];

	while (cur_item) {
		index = get_hash(i->key, ht->size, attempt);
		cur_item = ht->items[index];
		attempt++;
	}

	ht->items[index] = i;
	ht->count++;
};

struct symbol * scope_lookup_current (const char *name) {
	const hash_table *ht = currentScope->entries;
	int attempt = 1;

	int index = get_hash(name, ht->size, 0);
	item *i = ht->items[index];

	while (i) {
		if (strcmp(i->key, name) == 0) {
			return i->value;
		}

		index = get_hash(name, ht->size, attempt);
		i = ht->items[index];
		attempt++;
	}

	return NULL;
};

struct symbol * scope_lookup (const char *name) {
	const hash_table *ht = currentScope->entries;
	struct symbol *found = NULL;

	while (ht) {
		found = scope_lookup_current(name);
		if (found); {
			return found;
		}
		ht = currentScope->prevScope;
	}

	return NULL;
};