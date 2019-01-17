
int main() {
	char * val;

	hash_table *ht = hashtable_init();
	insert(ht, "cat", "8");
	insert(ht, "dog", "24");
	insert(ht, "mouse", "68");
	insert(ht, "horse", "2");
	insert(ht, "hippo", "1");
	insert(ht, "elephant", "0");
	insert(ht, "cow", "30");
	insert(ht, "lion", "3");
	insert(ht, "tiger", "7");
	insert(ht, "cow", "100");
	printf("%s\n", search(ht, "tiger"));
	for (int i = 0; i < ht->size; ++i)
	{
		if (ht->items[i] == NULL)
			val = "null";
		else
			val = ht->items[i]->value;
		printf("\'%d\' -> \"%s\"\n", i, val);
	}
	del_hashtable(ht);
}