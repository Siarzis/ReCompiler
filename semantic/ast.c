#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "ast.h"
#include "symbol.h"

struct decl * decl_create(char *name, struct type *type, struct decl *local_decl, struct stmt *code, struct decl *next) {
	struct decl *d = malloc(sizeof(struct decl));

	d->name = name;
	d->type = type;
	d->local_decl = local_decl;
	d->code = code;
	d->next = next;

	return d;
}

struct stmt * stmt_create(stmt_token kind, struct expr *expr,
	struct expr *next_expr, struct stmt *body, struct stmt *else_body, struct stmt *next) {
	struct stmt *s = malloc(sizeof(*s));

	s->kind = kind;
	s->expr = expr;
	s->next_expr = next_expr;
	s->body = body;
	s->else_body = else_body;
	s->next = next;

	return s;
}

struct expr * expr_create(expr_token kind, struct expr *left, struct expr *right) {
	struct expr *e = malloc(sizeof(*e));

	e->kind = kind;
	e->left = left;
	e->right = right;

	return e;
}

struct expr * expr_create_name(const char *name) {
	struct expr *e = expr_create(EXPR_NAME, NULL, NULL);
	e->name = name;
	return e;
}

struct expr * expr_create_int_literal(int i) {
	struct expr *e = expr_create(EXPR_INT_LITERAL, NULL, NULL);
	e->integer_value = i;
	return e;
}

struct type * create_type (type_token kind, struct type *subtype, struct param_list *parameters) {
	struct type *t = malloc(sizeof(*t));

	t->kind = kind;
	t->subtype = subtype;
	t->parameters = parameters;

	return t;
}

struct param_list * create_parameters (char *name, struct type *type, struct param_list *next) {
	struct param_list *p = malloc(sizeof(*p));

	p->name = name;
	p->type = type;
	p->next = next;

	return p;
}

/************************************************************
-------------------  Semantic Utilities  --------------------
************************************************************/

void decl_resolve(struct decl *d) {
	if (!d) return;
	struct symbol *s;

	if (d->type->kind == TYPE_FUNCTION) {
		scope_enter();
		//param_list_resolve(d->type->parameters);
		decl_resolve(d->local_decl);
		stmt_resolve(d->code);
		scope_exit();
		return;
	}

	if (scope_lookup_current(d->name)) {
		printf("Error! Duplicate declaration of variable '%s'.\n", d->name);
	} else {
		// as long as we are dealing with a declaration (we are in decl_resolve() function)
		// available attributes are only "local" & "global", not "parameter")
		symbol_token kind = scope_level() > 1 ? SYMBOL_LOCAL : SYMBOL_GLOBAL;
		scope_bind(d->name, symbol_create(kind, d->type, d->name));
	}

	decl_resolve(d->next);
}

void stmt_resolve(struct stmt *s) {
	if (!s) return;
	
	switch(s->kind) {
		case STMT_ASSIGN:
			expr_resolve(s->next_expr);
			expr_resolve(s->expr);
			break;
		case STMT_IF_ELSE:
			expr_resolve(s->expr);
			stmt_resolve(s->body);
			stmt_resolve(s->else_body);
			break;
		}

	stmt_resolve(s->next);
}

void expr_resolve (struct expr *e) {
	if (!e) return;

	if (e->kind == EXPR_NAME && !scope_lookup_current(e->name)) {
		printf("Error! Variable '%s' is not declared; first use in this scope.\n", e->name);
		return;
	} else {
		expr_resolve(e->left);
		expr_resolve(e->right);
	}
}

static int type_equals(struct type *a, struct type *b) {
	if(a->kind == b->kind) {
		if(a->kind == TYPE_INT || a->kind == TYPE_BYTE) {
			return true;
		} else if (a->kind == TYPE_ARRAY) {
			return type_equals(a->subtype, b->subtype);
		} else if (a->kind == TYPE_FUNCTION) {
			if (type_equals(a->subtype, b->subtype) == false) {
				return false;
			}

			struct param_list *param_a = a->parameters;
			struct param_list *param_b = b->parameters;

			while (param_a != NULL && param_b != NULL) {
				if (type_equals(param_a->type, param_b->type) == false) {
					return false;
				}
				param_a = param_a->next;
				param_b = param_b->next;
			}
			if (param_a != NULL || param_b != NULL) {
				return false;
			}
			return true;
		}
	} else {
		return false;
	}
}

static struct type * type_copy(struct type *t) {
	struct type *t_dup = malloc(sizeof(*t_dup));

	t_dup->kind = t->kind;
	t_dup->subtype = NULL;
	t_dup->parameters = NULL;

	if (t->kind == TYPE_ARRAY) {
		t_dup->subtype = type_copy(t->subtype);
	} else if (t->kind == TYPE_FUNCTION) {
		t_dup->subtype = type_copy(t->subtype);

		struct param_list *p = t->parameters; //pointer to original linked list
		struct param_list *p_dup, *p_head, *p_temp; // p_temp is a pointer to last item in the linked list

		while (p != NULL) {
			p_dup = malloc(sizeof(*p_dup));

			p_dup->name = p->name;
			p_dup->type = type_copy(p->type);
			p_dup->next = NULL;
			
			if (p->next == NULL) {
				p_head = p_dup;
				p_temp = p_dup;
			} else {
				p_temp->next = p_dup;
				p_temp = p_dup;
			}
			p = p->next;
		}
		t_dup->parameters = p_head;
	}

	return t_dup;
}

static void type_delete(struct type *t) {
	if (t == NULL) {
		free(t);
	} else if (t->kind == TYPE_INT || t->kind == TYPE_BYTE) {
		free(t->subtype);
		free(t->parameters);
	} else if (t->kind == TYPE_ARRAY) {
		type_delete(t->subtype);
		free(t->parameters);
	} else if (t->kind == TYPE_FUNCTION) {
		type_delete(t->subtype);
		
		struct param_list *temp = t->parameters;
		
		while (temp != NULL) {
			free(temp->name);
			type_delete(temp->type);
			temp = temp->next;
			free(t->parameters);
		}
		free(temp);
	}
}

void type_print(struct type *t) {
	if (!t) return NULL;

	switch(t->kind) {
		case TYPE_VOID:
		printf("a void");
		break;
		case TYPE_INT:
		printf("an integer");
		break;
		case TYPE_BYTE:
		break;
		printf("a byte");
		break;
		case TYPE_ARRAY:
		type_print(t->subtype);
		printf("array");
		break;
		case TYPE_FUNCTION:
		type_print(t->subtype);
		printf("function");
		break;
	}
}

struct type * expr_typecheck(struct expr *e) {
	if (!e) return NULL;
	
	struct type *lt = expr_typecheck(e->left);
	struct type *rt = expr_typecheck(e->right);
	struct type *result;
	
	switch(e->kind) {
		case EXPR_INT_LITERAL:
		result = create_type(TYPE_INT, NULL, NULL);
		break;
		case EXPR_NAME:
		break;
		case EXPR_STRING_LITERAL:
		break;
		case EXPR_ADD:
		if (lt->kind != TYPE_INT || rt->kind != TYPE_INT) {
			printf("Type Error: cannot add ");
			type_print(lt);
			printf(" (");
			//expr_print(e->left);
			printf(") to ");
			type_print(rt);
			printf(" (");
			//expr_print(e->right);
			printf(")\n");
		}
		result = create_type(TYPE_INT, NULL, NULL);
		break;
		case EXPR_SUB:
		if (lt->kind != TYPE_INT || rt->kind != TYPE_INT) {
			printf("Type Error: cannot subtract ");
			type_print(lt);
			printf(" (");
			//expr_print(e->left);
			printf(") from ");
			type_print(rt);
			printf(" (");
			//expr_print(e->right);
			printf(")\n");
		}
		result = create_type(TYPE_INT, NULL, NULL);
		break;
		case EXPR_MUL:
		if (lt->kind != TYPE_INT || rt->kind != TYPE_INT) {
			printf("Type Error: cannot multiply ");
			type_print(lt);
			printf(" (");
			//expr_print(e->left);
			printf(") with ");
			type_print(rt);
			printf(" (");
			//expr_print(e->right);
			printf(")\n");
		}
		result = create_type(TYPE_INT, NULL, NULL);
		break;
		case EXPR_DIV:
		if (lt->kind != TYPE_INT || rt->kind != TYPE_INT) {
			printf("Type Error: cannot divide ");
			type_print(lt);
			printf(" (");
			//expr_print(e->left);
			printf(") by ");
			type_print(rt);
			printf(" (");
			//expr_print(e->right);
			printf(")\n");
		}
		result = create_type(TYPE_INT, NULL, NULL);
		break;
		case EXPR_MOD:
		break;
		case EXPR_SUBSCRIPT:
		break;
		case EXPR_CALL:
		break;
		case EXPR_ARG:
		break;
		case EXPR_AND:
		if(!type_equals(lt,rt)) {

		}
		if(lt->kind==TYPE_VOID ||
			lt->kind==TYPE_ARRAY ||
			lt->kind==TYPE_FUNCTION) {
			printf("Type Error: cannot compare ");
			type_print(lt);
			printf(" (");
			//expr_print(e->left);
			printf(") by ");
			type_print(rt);
			printf(" (");
			//expr_print(e->right);
			printf(")\n");
		}
		break;
		case EXPR_OR:
		break;
		case EXPR_NOT:
		break;
		case EXPR_EQ:
		break;
		case EXPR_LT:
		break;
		case EXPR_GT:
		break;
		case EXPR_LE:
		break;
		case EXPR_GE:
		break;
		case EXPR_NE:
		break;
	}
	
	type_delete(lt);
	type_delete(rt);
	
	return result;
}