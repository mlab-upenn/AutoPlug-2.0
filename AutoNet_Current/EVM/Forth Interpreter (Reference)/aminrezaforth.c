#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <assert.h>

/** Options symbols */
#define CASE_INSENSITIVE
//#define STACKS_BOUNDARY_CHECK
//#define SYNTAX_CHECK
/** End of options symbols */

/** Debuging symbols */
// #define ECHO
// #define DEBUG_DATA_STACKS
// #define DEBUG_RETURN_STACKS
// #define DEBUG_DICTIONARY
/** End of debuging symbols */

/** Memory layout options */
#define DATA_SEGMENT_SIZE	20480		/* = DICTIONARY_SIZE + DATA_STACK_SIZE + RETURN_STACK_SIZE + BUF_SIZE */
#define DICTIONARY_SIZE		8192
#define DATA_STACK_SIZE		4096
#define RETURN_STACK_SIZE	4096
#define BUF_SIZE		4096
#define DS_BASE			(data_segment + DICTIONARY_SIZE + DATA_STACK_SIZE)
#define RS_BASE			(data_segment + DICTIONARY_SIZE + DATA_STACK_SIZE + RETURN_STACK_SIZE)
#define BUF_BASE		(data_segment + DICTIONARY_SIZE + DATA_STACK_SIZE + RETURN_STACK_SIZE + 4)
#define DS_GROW			-1
#define RS_GROW			-1
#define BUF_GROW		+1

#define CELLSIZE		4
/** End of memory layout */

/** Dictionary-related symbols and macros */
#define IMMED_FLAG		128
#define HIDDEN_FLAG		64

#define RFLAGS(x)		((x) & 31)
#define HIDDEN(x)		((x) & HIDDEN_FLAG)
#define IMMEDIATE(x)		((x) & IMMED_FLAG)
/** End of dictionary-related symbols */

#define CHECK_ERR(errno, ID)	if (errno) fprintf(stderr, "%s\tFatal error: %d\n", ID, errno)
#define EMITERRS(msg)		fprintf(stderr, "%s", msg)
#define EMITERRI(num)		fprintf(stderr, ">%d<\n", num)

#define DSPUSH(x)		*(dsp) = x; dsp = dsp + DS_GROW
#define RSPUSH(x)		*(rsp) = x; rsp = rsp + RS_GROW
#define DSPOP(x)		dsp = dsp - DS_GROW; x = *(dsp)
#define RSPOP(x)		rsp = rsp - RS_GROW; x = *(rsp)
#define TOIP(x)			((int*)x)

#if __GNUC__ > 3
	#define expect(x,y) __builtin_expect((long)(x),y)
#else
	#define __builtin_expect(x,y) (x)
	#define expect(x,y) (x)
#endif
#define __likely(c) expect((c),1)
#define __unlikely(c) expect((c),0)


int *rsp;
int *dsp;
char *here;
char *latest;
char *buffer;
int buffer_ind = 0;
int state = 0;
char data_segment [DATA_SEGMENT_SIZE];
static void (*xt)();

static inline int set_up_data_segment ();
static void set_up_core ();
static void docol(int *addr);
static void _docol ();
static void quit ();
static inline void stacks_reset();
static inline void dz();
static inline void rz();
static inline void rsp_store();
static inline void interpret();
static void word();
static int* find();
static int* find_a(char *str);
static int isnumber();
static int number();
static void add_word (char *name, void (*code)());
static void add_variable (char *name);
static void add_variable_d (char *name, int *addr);
static void add_header (char *name);
static void _add_header ();
static void _make_immediate();
static void _make_hidden();
static void compile (int *link);
static char* get_exec_ptr(char *ptr);
static void greet();

static void shutdown(int code) __attribute__ ((noreturn));

static void _dot ();
static void _dots ();
static void _plus ();
static void _minus ();
static void _mult ();
static void _div ();
static void _less ();
static void _greater ();
static void _equal ();
static void _fetch ();
static void _store ();
static void _colon ();
static void _comma ();
static void _dup ();
static void _swap ();
static void _rot ();
static void _nrot ();
static void _semicolon ();
static void _if_c();
static void _else_c();
static void _then_c();
static void _jump();
static void _jump0();
static void _literal (int *addr);
static void __literal ();
static void _variable ();
static void _allot();
static void alloc_d(int len);
static void _cells();
static void _tick();
static void _drop ();
static void _m_f_ds_t_rs();
static void _m_f_rs_t_ds();
static void _c_f_rs_t_ds();
static void _postpone();
static void _compile_next();

int main (int argc, char *argv[])
{
	int errno;
	errno = set_up_data_segment ();
	CHECK_ERR (errno, "E100");
	set_up_core();
	greet();
	quit ();
	return 0;
}

static inline int set_up_data_segment ()
{
	here = data_segment;
	latest = 0;
	*TOIP(data_segment) = 0;
	stacks_reset();
	buffer = BUF_BASE;
	return 0;
}

static void greet ()
{
	fprintf(stderr, "AiRforth 0.0.1\nAiRforth comes with ABSOLUTELY NO WARRANTY!\nPress Ctrl + D to exit.\n\n");
}

static void quit ()
{
	while (1)
	{
		if (/*state == */0)
		{
			rz ();
			rsp_store();
		}
		interpret();
	}
}

static inline void stacks_reset()
{
	dsp = TOIP(DS_BASE);
	rsp = TOIP(RS_BASE);
}

static inline void rz()
{
	DSPUSH ((int)RS_BASE);
}

static inline void dz()
{
	DSPUSH ((int)DS_BASE);
}

static inline void rsp_store()
{
	DSPOP(rsp);
}

static inline void interpret()
{
	word();

	int *link = find();
	char *ptr = (char*) (link + 1);
	if (link)
	{
		int len = (int)*ptr;
		ptr = ptr + RFLAGS(len) + 1;
		if (state == 0 || len & IMMED_FLAG)
		{
			xt = (void (*)())*(TOIP(ptr));
			xt(&ptr);
		} else
		{
			compile(TOIP(ptr));
		}
	} else
	{
		if (isnumber())
		{
			if (state == 0)
			{
				DSPUSH(number());
			} else
			{
				ptr = (char*)find_a("LITERAL");
				compile(TOIP(get_exec_ptr(ptr)));
				compile(TOIP(number()));
			}
		} else
		{
			EMITERRS("Error: Unrecognized command\n");
			stacks_reset();
		}
	}
}

static void word()
{
	int found = 0;
	char c;
	buffer_ind = 0;
	while (1)
	{
		c = buffer[buffer_ind] = getchar();
		if (c == EOF)
		{
			shutdown(0);
		}
		if (c == ' ' || c == '\t' || c == '\n')
		{
			if (found)
				break;
		} else
		{
#ifdef CASE_INSENSITIVE
			if (buffer[buffer_ind] >= 97 && buffer[buffer_ind] <= 122)
				buffer[buffer_ind] -= 32;
#endif
			buffer_ind++;
			found = 1;
		}
	}
	buffer[buffer_ind++] = 0;
}

static int* find()
{
	return find_a(buffer);
}

static int* find_a(char *str)
{
	char *link = latest;
	int len = strlen(str);
	while (link)
	{
		if (!HIDDEN(link[4]) && ((int)(RFLAGS(link[4])) == len) && (!strncmp(link+5, str, (int)(RFLAGS(link[4])))))
		{
			return TOIP(link);
		}
		link = (char*)*(TOIP(link));
	}
	return 0;
}

static int isnumber()
{
	int i;
	if ((buffer[0] <= 47 || buffer[0] >= 58) && buffer[0] != 45)
		return 0;
	for (i = 1; i < buffer_ind-1; i++)
	{
		if (buffer[i] <= 47 || buffer[i] >= 58)
			return 0;
	}
	return 1;
}

static int number()
{
	return atoi(buffer);
}

static void add_word (char *name, void (*code)())
{
	add_header (name);
	compile((int*)code);
}

void add_variable (char *name)
{
	add_header(name);
	compile(TOIP(docol));
	compile(TOIP((get_exec_ptr((char*)find_a("LITERAL")))));
	compile(TOIP((here + 2 * sizeof(int))));
	compile(0);
	compile(0);
}

static void add_variable_d (char *name, int *addr)
{
	add_header(name);
	compile(TOIP(docol));
	compile(TOIP((get_exec_ptr((char*)find_a("LITERAL")))));
	compile(TOIP(addr));
	compile(0);
}

static void _variable()
{
	word();
	add_variable(buffer);
}

static void _add_header ()
{
	word();
	add_header(buffer);
}

static void add_header (char *name)
{
	int len = strlen(name);
	assert(len < 64);

	char *ptr = here + 4;
	*(TOIP(here)) = (int)latest;
	*(ptr++) = len;
	strncpy(ptr, name, RFLAGS(len));
	latest = here;
	here += sizeof (int*) + sizeof (char) + RFLAGS(len);
}

static void _make_immediate()
{
	latest[4] |= 128;
}

static void _make_hidden()
{
	latest[4] |= 64;
}

static void compile (int *link)
{
	*(TOIP(here)) = (int)link;
	here += sizeof(int*);
}

static void shutdown(int code)
{
	/* Currently we can simply pull the plug. */
	exit(code);
}

/** Basic FORTH words, variables and constants */
static void set_up_core ()
{
	add_word (".", _dot);
	add_word (".S", _dots);
	add_word ("+", _plus);
	add_word ("-", _minus);
	add_word ("*", _mult);
	add_word ("/", _div);
	add_word ("@", _fetch);
	add_word ("!", _store);
	add_word (">", _greater);
	add_word ("<", _less);
	add_word ("=", _equal);
	add_word ("DUP", _dup);
	add_word ("SWAP", _swap);
	add_word ("ROT", _rot);
	add_word ("-ROT", _nrot);
	add_word ("DROP", _drop);
	add_word ("LITERAL", _literal);
	add_word ("LIT", __literal);
	add_word ("CREATE", _add_header);
	add_word ("ALLOT", _allot);
	add_word ("CELLS", _cells);
	add_word ("VARIABLE", _variable);
	add_word ("DOCOL", _docol);
	add_word ("IMMEDIATE", _make_immediate);
	add_word ("POSTPONE", _postpone);
	_make_immediate();
	add_word ("COMPILE_NEXT", _compile_next);

	add_word (">R", _m_f_ds_t_rs);
	add_word ("R>", _m_f_rs_t_ds);
	add_word ("R@", _c_f_rs_t_ds);

	add_word (",", _comma);
	add_word ("'", _tick);
	add_word (":", _colon);
	_make_immediate();
	add_word (";", _semicolon);
	_make_immediate();
	add_word ("IF", _if_c);
	_make_immediate();
	add_word ("ELSE", _else_c);
	_make_immediate();
	add_word ("THEN", _then_c);
	_make_immediate();
	add_word ("BRANCH", _jump);
	add_word ("0BRANCH", _jump0);

	add_variable_d("HERE", TOIP(&here));
	add_variable_d("LATEST", TOIP(&latest));
	add_variable_d("STATE", TOIP(&state));
}

static void docol(int *addr)
{
	addr = TOIP(*addr);
	int *ptr = TOIP(xt);
	RSPUSH((int)ptr);
	ptr = addr + 1;
	xt = (void (*)())ptr;

	void (*func)() = (void (*)())*(int*)*TOIP(ptr);
	while (1)
	{
		func(TOIP(ptr));
		ptr = TOIP(xt);
		ptr++;
		xt = (void (*)())ptr;
		if (*ptr == 0)
			break;
		func = (void (*)())*TOIP(*ptr);
	}
	RSPOP(xt);
}

static void _docol ()
{
	compile(TOIP(docol));
}

static void _dot ()
{
	int val;
	if (__likely(dsp != TOIP(DS_BASE)))
	{
		DSPOP(val);
		printf("%d\n", val);
	} else
	{
		EMITERRS("Stack underflow.\n");
	}
}

static void _dots ()
{
	int *i;
	for (i = TOIP(DS_BASE); (i - dsp) * DS_GROW < 0; i = i + DS_GROW)
	{
		printf(" %d", *i);
	}
	printf("\n");
}

static void _plus ()
{
	*(dsp - 2*DS_GROW) += *(dsp - DS_GROW);
	dsp++;
}

static void _minus ()
{
	*(dsp - 2*DS_GROW) -= *(dsp - DS_GROW);
	dsp++;
}

static void _mult ()
{
	*(dsp - 2*DS_GROW) *= *(dsp - DS_GROW);
	dsp++;
}

static void _div ()
{
	*(dsp - 2*DS_GROW) /= *(dsp - DS_GROW);
	dsp++;
}

static void _fetch ()
{
	int *ptr;
	DSPOP(ptr);
	DSPUSH(*ptr);
}

static void _store ()
{
	int *dest, val;
	DSPOP(dest);
	DSPOP(val);
	*dest = val;
}

static void _colon ()
{
	state = 1;
	word();
	add_header (buffer);
	compile(TOIP(docol));
}

static void _semicolon ()
{
	compile(0);
	state = 0;
}

static void _if_c ()
{
	compile(TOIP((get_exec_ptr((char*)find_a("0BRANCH")))));
	RSPUSH((int)here);
	compile(0);
}

static void _else_c ()
{
	int *origin;
	RSPOP(origin);

	compile(TOIP((get_exec_ptr((char*)find_a("BRANCH")))));
	RSPUSH((int)here);
	compile(0);

	int offset = (int)(TOIP(here) - origin);
	*origin = offset;
}

static void _then_c ()
{
	int *origin;
	RSPOP(origin);
	int offset = (int)(TOIP(here) - origin) - 1;
	*origin = offset;
}

//static void 
//{}

static void _jump (int *addr)
{
	int* ptr = TOIP(xt);
	ptr++;
	ptr += *ptr;
	xt = (void (*)())ptr;
}

static void _jump0 (int *addr)
{
	int jump_offset;
	addr++;
	int val;
	DSPOP(val);
	if (!val)
	{
		jump_offset = *addr;
	} else
	{
		jump_offset = 1;
	}
	int *ptr = TOIP(xt);
	ptr += jump_offset;
	xt = (void (*)())ptr;
}

static void _literal (int *addr)
{
	DSPUSH(*(addr + 1));
	int* ptr = TOIP(xt);
	ptr++;
	xt = (void (*)())ptr;
}

static void __literal ()
{
	compile(TOIP((get_exec_ptr((char*)find_a("LITERAL")))));
	int val;
	DSPOP(val);
	compile(TOIP(val));
}

static char* get_exec_ptr(char *ptr)
{
	int len = RFLAGS((int)ptr[4]);
	return (ptr + len + 5);
}

static void alloc_d(int len)
{
	here += len;
}

static void _allot()
{
	int val;
	DSPOP(val);
	alloc_d(val);
}

static void _cells()
{
	int val;
	DSPOP(val);
	DSPUSH(val * CELLSIZE);
}

static void _tick()
{
	word();
	DSPUSH((int)get_exec_ptr((char*)find()));
}

static void _comma ()
{
	int val;
	DSPOP(val);
	compile(TOIP(val));
}

static void _dup ()
{
	DSPUSH(*(dsp - DS_GROW));
}

static void _swap ()
{
	int tmp = *(dsp - DS_GROW);
	*(dsp - DS_GROW) = *(dsp - 2*DS_GROW);
	*(dsp - 2*DS_GROW) = tmp;
}

static void _drop ()
{
	dsp -= DS_GROW;
}

static void _less ()
{
	int n1, n2;
	DSPOP(n2);
	DSPOP(n1);
	if (n1 < n2)
	{
		DSPUSH(1);
	} else
	{
		DSPUSH(0);
	}
}

static void _greater ()
{
	int n1, n2;
	DSPOP(n2);
	DSPOP(n1);
	if (n1 > n2)
	{
		DSPUSH(1);
	} else
	{
		DSPUSH(0);
	}
}

static void _equal ()
{
	int n1, n2;
	DSPOP(n2);
	DSPOP(n1);
	if (n1 == n2)
	{
		DSPUSH(1);
	} else
	{
		DSPUSH(0);
	}
}

static void _m_f_ds_t_rs()
{
	int val;
	DSPOP(val);
	RSPUSH(val);
}

static void _m_f_rs_t_ds()
{
	int val;
	RSPOP(val);
	DSPUSH(val);
}

static void _c_f_rs_t_ds()
{
	DSPUSH(*(rsp - RS_GROW));
}

static void _postpone (int *addr)
{
	word();
	char *link = (char*)find();
	if (!IMMEDIATE(link[4]))
	{
		compile(TOIP(get_exec_ptr((char*)find_a("COMPILE_NEXT"))));
	}
	compile(TOIP(get_exec_ptr((char*)link)));
	int *ptr = TOIP(xt);
	ptr++;
	xt = (void (*)())ptr;
}

static void _compile_next (int *addr)
{
	compile(TOIP(*(addr + 1)));
	int *ptr = TOIP(xt);
	ptr++;
	xt = (void (*)())ptr;
}

static void _rot ()
{
	int val;
	val = *(dsp - 3*DS_GROW);
	*(dsp - 3*DS_GROW) = *(dsp - 2*DS_GROW);
	*(dsp - 2*DS_GROW) = *(dsp - DS_GROW);
	*(dsp - DS_GROW) = val;
}

static void _nrot ()
{
	int val;
	val = *(dsp - DS_GROW);
	*(dsp - DS_GROW) = *(dsp - 2*DS_GROW);
	*(dsp - 2*DS_GROW) = *(dsp - 3*DS_GROW);
	*(dsp - 3*DS_GROW) = val;
}
