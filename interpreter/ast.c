#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

struct decl * decl_create(char *name, struct type *type, struct expr *value, struct stmt *code, struct decl *next)
{
	struct decl *d = malloc(sizeof(struct decl));

	d->name = name;
	d->type = type;
	d->value = value;
	d->code = code;
	d->next = next;

	return d;
}

struct stmt * stmt_create(stmt_token kind, struct decl *decl, struct expr *init_expr,
	struct expr *expr, struct expr *next_expr, struct stmt *body, struct stmt *else_body, struct stmt *next)
{
	struct stmt *s = malloc(sizeof(*s));

	s->kind = kind;
	s->decl = decl;
	s->init_expr = init_expr;
	s->expr = expr;
	s->next_expr = next_expr;
	s->body = body;
	s->else_body = else_body;
	s->next = next;

	return s;
}

struct expr * expr_create(expr_token kind, struct expr *left, struct expr *right)
{
	struct expr *e = malloc(sizeof(*e));
	e->left = left;
	e->right = right;
	return e;
}

struct expr * expr_create_name(const char *name)
{
	struct expr *e = expr_create(EXPR_NAME, NULL, NULL);
	e->name = name;
	return e;
}

struct expr * expr_create_int_literal(int i)
{
	struct expr *e = expr_create(EXPR_INT_LITERAL, NULL, NULL);
	e->integer_value = i;
	return e;
}

struct expr * expr_create_string_literal(const char *str)
{
	struct expr *e = expr_create(EXPR_STRING_LITERAL, NULL, NULL);
	e->string_literal = str;
	return e;
}