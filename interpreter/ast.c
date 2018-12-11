struct decl * decl_create( char *name, struct *type, struct expr *value, struct stmt *code struct decl *next)
{
	struct decl *d = malloc(sizeof(*d));
	d->name = name;
	d->type = type;
	d->value = value;
	d->code = code;
	d->next = next;

	return d;
}

struct stmt * stmt_create( stmt_t kind, struct decl
*
decl, struct expr
*
init_expr,
struct expr
*
expr, struct expr
*
next_expr,
struct stmt
*
body, struct stmt
*
else_body,
struct stmt
*
next)
{
	struct decl *d = malloc(sizeof(*d));
	d->name = name;
	d->type = type;
	d->value = value;
	d->code = code;
	d->next = next;

	return d;
}