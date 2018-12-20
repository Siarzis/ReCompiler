#ifndef __AST_H__
#define __AST_H__

/* define declarations data structure */

struct decl {
	char *name;
	struct type *type;
	struct decl *local_decl;
	struct stmt *code;
	struct decl *next;
};

/*define statements data structure */

typedef enum {
	STMT_ASSIGN,
	STMT_IF_ELSE,
	STMT_WHILE,
	STMT_PRINT,
	STMT_RETURN,
	STMT_BLOCK
} stmt_token;

struct stmt {
	stmt_token kind;
	struct expr *expr;
	struct expr *next_expr;
	struct stmt *body;
	struct stmt *else_body;
	struct stmt *next;
};

/*define expressions data structure */

typedef enum {
	EXPR_ADD,
	EXPR_SUB,
	EXPR_MUL,
	EXPR_DIV,
	EXPR_MOD,
	EXPR_SUBSCRIPT,
	EXPR_CALL,
	EXPR_ARG,
	EXPR_AND,
	EXPR_OR,
	EXPR_NOT,
	EXPR_EQ,
	EXPR_LT,
	EXPR_GT,
	EXPR_LE,
	EXPR_GE,
	EXPR_NE,
	EXPR_NAME,
	EXPR_INT_LITERAL,
	EXPR_STRING_LITERAL
} expr_token;

struct expr {
	expr_token kind;
	struct expr *left;
	struct expr *right;

	const char *name;
	int integer_value;
	const char *string_literal;
};

/*define types */

typedef enum {
	TYPE_VOID,
	TYPE_INT,
	TYPE_BYTE,
	TYPE_ARRAY,
	TYPE_FUNCTION
} type_token;

struct type {
	type_token kind;
	struct type *subtype;
	struct param_list *parameters;
};

struct param_list {
	char *name;
	struct type *type;
	struct param_list *next;
};

struct decl * decl_create(char *name, struct type *type, struct decl *local_decl, struct stmt *code, struct decl *next);
struct stmt * stmt_create(stmt_token kind, struct expr *expr, struct expr *next_expr, struct stmt *body, struct stmt *else_body, struct stmt *next);
struct expr * expr_create(expr_token kind, struct expr *left, struct expr *right);
struct expr * expr_create_name(const char *name);
struct expr * expr_create_int_literal(int i);
struct expr * expr_create_string_literal(const char *str);
struct type * create_type (type_token kind, struct type *subtype, struct param_list *parameters);
struct param_list * create_parameters (char *name, struct type *type, struct param_list *next);
int decl_evaluate (struct decl *d);
int stmt_evaluate (struct stmt *s);
int expr_evaluate (struct expr *e);


#endif