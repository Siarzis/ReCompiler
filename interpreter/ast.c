#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

struct decl * decl_create(char *name, struct type *type, struct decl *local_decl, struct stmt *code, struct decl *next)
{
	struct decl *d = malloc(sizeof(struct decl));

	d->name = name;
	d->type = type;
	d->local_decl = local_decl;
	d->code = code;
	d->next = next;

	return d;
}

struct stmt * stmt_create(stmt_token kind, struct expr *expr,
	struct expr *next_expr, struct stmt *body, struct stmt *else_body, struct stmt *next)
{
	struct stmt *s = malloc(sizeof(*s));

	s->kind = kind;
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
	e->kind = kind;
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

struct type * create_type (type_token kind, struct type *subtype, struct param_list *parameters)
{
	struct type *t = malloc(sizeof(*t));
	t->kind = kind;
	t->subtype = subtype;
	t->parameters = parameters;
}

struct param_list * create_parameters (char *name, struct type *type, struct param_list *next)
{
	struct param_list *p = malloc(sizeof(*p));
	p->name = name;
	p->type = type;
	p->next = next;
}

int decl_print (struct decl *d)
{
	if (d == NULL) return 0;

	switch(d->type->kind) {
	case TYPE_FUNCTION:
	d = d->local_decl;
	while (d != NULL) {
		printf("%s: %d\n", d->name, d->type->kind);
		d = d->next;
	}
	//case TYPE_VOID:
	//case TYPE_INT:
	//case TYPE_BYTE:
	//case TYPE_ARRAY:

	}
	return 1;
}

int stmt_evaluate (struct stmt *s)
{
	if (s == NULL) return 0;

	int next = stmt_evaluate(s->next);

	switch(s->kind) {
		//case STMT_DECL
		case STMT_ASSIGN:
			expr_evaluate(s->expr);
		//case STMT_IF_ELSE
		//case STMT_WHILE
		//case STMT_PRINT
		//case STMT_RETURN
		case STMT_BLOCK:
			expr_evaluate(s->expr);
	}
}

int expr_evaluate (struct expr *e)
{
	if (e == NULL) return 0;

	int l = expr_evaluate(e->left);
	int r = expr_evaluate(e->right);

	switch(e->kind) {
		case EXPR_INT_LITERAL:
			printf("%d\n", e->integer_value);
			return e->integer_value;
		case EXPR_NAME:
			printf("%s\n", e->name);
			return e->name;
		case EXPR_ADD:
			printf("(+)\n");
			return l+r;
		case EXPR_SUB:
			return l-r;
		case EXPR_MUL:
			return l*r;
		case EXPR_DIV:
			if(r==0) {
				printf("runtime error: divide by zero\n");
				exit(1);
			}
			return l/r;
		//case EXPR_STRING_LITERAL
		case EXPR_MOD:
			return l%r;
		//case EXPR_ARRAY:
		case EXPR_CALL:
			printf("%s\n", e->left->name);
			//printf("%d\n", e->left->left);
			//printf("%d\n", e->left->right);
			return 0;
		case EXPR_ARG:
			printf("%s\n", e->left->name);
			//printf("%d\n", e->right);
			return 0;
		case EXPR_AND:
			return l && r;
		case EXPR_OR:
			return l || r;
		case EXPR_NOT:
			return !l;
		case EXPR_EQ:
			return l == r;
		case EXPR_LT:
			return l < r;
		case EXPR_GT:
			return l > r;
		case EXPR_LE:
			return l <= r;
		case EXPR_GE:
			return l >= r;
	}
}