#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "hashtable.h"

static item HT_DELETED_ITEM = {NULL, NULL};

// The function is marked as static because it will only ever be called by code internal to the hash table
static item * item_init (const char *key, const int value) {
	item *i = malloc(sizeof(*i));
	i->key = strdup(key);
	i->value = value;
	return i;
}

hash_table * hashtable_init() {
	hash_table *ht = malloc(sizeof(*ht));
	ht->size = 53;
	ht->count = 0;
	ht->items = calloc((size_t)ht->size, sizeof(item*));
	return ht;
}

static void del_item(item* i) {
	free(i->key);
	free(i);
}

void del_hashtable(hash_table* ht) {
	for (int i = 0; i < ht->size; i++) {
		item *item = ht->items[i];
		if (item != NULL) {
		del_item(item);
		}
	}
	free(ht->items);
	free(ht);
}

static int hash_function(const char *s, const int a, const int m) {
	long hash = 0;
	const int len_s = strlen(s);

	for (int i = 0; i < len_s; i++) {
		hash += (long) pow(a, len_s - (i+1)) * s[i];
		hash = hash % m;
	}

	return (int) hash;
}

static int get_hash(const char *s, const int num_buckets, const int attempt) {

	const int hash_a = hash_function(s, 151, num_buckets);
	const int hash_b = hash_function(s, 163, num_buckets);

	return (hash_a + (attempt * (hash_b + 1))) % num_buckets;
}

void insert(hash_table *ht, const char *key, const int value) {
	item *itm = item_init(key, value);
	int index = get_hash(itm->key, ht->size, 0);
	item *cur_itm = ht->items[index];
	int i = 1;
	while (cur_itm != NULL && cur_itm != &HT_DELETED_ITEM) {
		if (cur_itm != &HT_DELETED_ITEM) {
			if (strcmp(cur_itm->key, key) == 0) {
				del_item(cur_itm);
				ht->items[index] = itm;
				return;
			}
		}
		index = get_hash(itm->key, ht->size, i);
		cur_itm = ht->items[index];
		i++;
	}
	ht->items[index] = itm;
	ht->count++;
}

char * search(hash_table *ht, const char *key) {
	int index = get_hash(key, ht->size, 0);
	item *item = ht->items[index];
	int i = 1;
	while (item != NULL) {
		if (item != &HT_DELETED_ITEM) { 
			if (strcmp(item->key, key) == 0) {
				return item->value;
			}
		}
		index = get_hash(key, ht->size, i);
		item = ht->items[index];
		i++;
	} 
	return NULL;
}

void deleted(hash_table *ht, const char *key) {
	int index = get_hash(key, ht->size, 0);
	item* item = ht->items[index];
	int i = 1;
	while (item != NULL) {
		if (item != &HT_DELETED_ITEM) {
			if (strcmp(item->key, key) == 0) {
				del_item(item);
				ht->items[index] = &HT_DELETED_ITEM;
			}
		}
		index = get_hash(key, ht->size, i);
		item = ht->items[index];
		i++;
	} 
	ht->count--;
}