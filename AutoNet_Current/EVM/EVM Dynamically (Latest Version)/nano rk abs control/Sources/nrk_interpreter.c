#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "nrk_interpreter.h"
#include "include.h"
#include "nrk.h"
#include "nrk_task.h"

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
#define DATA_SEGMENT_SIZE	1024		/* = DICTIONARY_SIZE + DATA_STACK_SIZE + RETURN_STACK_SIZE + BUF_SIZE */
#define DICTIONARY_SIZE		512
#define DATA_STACK_SIZE		128
#define RETURN_STACK_SIZE	128
#define BUF_SIZE		      256
#define DS_BASE			      (data_segment + DICTIONARY_SIZE + DATA_STACK_SIZE)
#define RS_BASE			      (data_segment + DICTIONARY_SIZE + DATA_STACK_SIZE + RETURN_STACK_SIZE)
#define BUF_BASE		      (data_segment + DICTIONARY_SIZE + DATA_STACK_SIZE + RETURN_STACK_SIZE + 2)
#define DS_GROW			      -1
#define RS_GROW			      -1
#define BUF_GROW		      +1
#define DST_BASE(x)			  (x + (DICTIONARY_SIZE + DATA_STACK_SIZE))
#define RST_BASE(x)		    (x + (DICTIONARY_SIZE + DATA_STACK_SIZE + RETURN_STACK_SIZE))
#define BUFT_BASE(x)		  (x + (DICTIONARY_SIZE + DATA_STACK_SIZE + RETURN_STACK_SIZE) + 2)
#define CELLSIZE		      2
/** End of memory layout */

/** Dictionary-related symbols and macros */
#define IMMED_FLAG		    128
#define HIDDEN_FLAG		    64

#define RFLAGS(x)		      ((x) & 31)
#define HIDDEN(x)		      ((x) & HIDDEN_FLAG)
#define IMMEDIATE(x)		  ((x) & IMMED_FLAG)
/** End of dictionary-related symbols */

#define CHECK_ERR(errno, ID)	if (errno) sprintf(stderr, "%s\tFatal error: %d\n", ID, errno)
#define EMITERRS(msg)		      sprintf(stderr, "%s", msg)
#define EMITERRI(num)		      fprintf(stderr, ">%d<\n", num)

#define DSPUSH(x,y)		        *(y) = x; y = y + DS_GROW
#define RSPUSH(x,y)		        *(y) = x; y = y + RS_GROW
#define DSPOP(x,y)		        (y = (int*)(y - DS_GROW)); x = *(y)
#define RSPOP(x,y)		        (y = (int*)(y - RS_GROW)); x = *(y)
#define DSPOPp(x,y)		        (y = (int*)(y - DS_GROW)); x = (int*)*(y)
#define RSPOPp(x,y)		        (y = (int*)(y - RS_GROW)); x = (int*)*(y)
#define DSPOPfp(x,y)		      (y = (int*)(y - DS_GROW)); x = (void(*)())*(y)
#define RSPOPfp(x,y)		      (y = (int*)(y - RS_GROW)); x = (void(*)())*(y)
#define TOIP(x)			          ((int*)x)


int number_of_tasks=1;

//global dictionary is stored in the flash
//#pragma DATA_SECTION(global_dictionary, ".my_sect")
static char global_dictionary [1024]; 

Task_Data GlobalDict;
Task_Data *Global_Dict;
Task_Data *vt_cur_node;
static int set_up_data_segment ();
static void set_up_core ();
static void docol(int *addr,Task_Data * IData);
static void _docol (char* ptr,Task_Data * IData);
void set_pointers(Task_Data *IData,char *data_segment);
static void reset_buffer();
void data_set(Task_Data * IData,char * data_segment);
static void add_word_immediate(char *name, void (*code)());
void interpret(Task_Data * IData);
static int word(Task_Data * IData);
static int* find(Task_Data * IData);
static int* find_a(char *str,char* _latest);
static int isnumber(Task_Data * IData);
static int number(Task_Data * IData);
static void add_word (char *name, void (*code)());
static void add_variable (char *name,Task_Data * IData);
static void add_variable_d (char *name, int *addr,Task_Data * IData);
static void add_header (char *name,Task_Data * IData);
static void _add_header ();
static void _make_immediate();
static void _make_hidden();
static void compile (int *link,Task_Data * IData);
static char* get_exec_ptr(char *ptr);
 static void add_word_page (char *name, uint32_t func_pointer);

static void _dot (char* ptr,Task_Data * IData);
static void _dots (char* ptr,Task_Data * IData);
static void _plus (char* ptr,Task_Data * IData);
static void _minus (char* ptr,Task_Data * IData);
static void _mult (char* ptr,Task_Data * IData);
static void _div (char* ptr,Task_Data * IData);
static void _less (char* ptr,Task_Data * IData);
static void _greater (char* ptr,Task_Data * IData);
static void _equal (char* ptr,Task_Data * IData);
static void _fetch (char* ptr,Task_Data * IData);
static void _store (char* ptr,Task_Data * IData);
static void _colon (char* ptr,Task_Data * IData);
static void _comma (char* ptr,Task_Data * IData);
static void _dup (char* ptr,Task_Data * IData);
static void _swap (char* ptr,Task_Data * IData);
static void _rot (char* ptr,Task_Data * IData);
static void _nrot (char* ptr,Task_Data * IData);
static void _semicolon (char* ptr,Task_Data * IData);
static void _if_c(char* ptr,Task_Data * IData);
static void _else_c(char* ptr,Task_Data * IData);
static void _then_c(char* ptr,Task_Data * IData);
static void _jump(int *addr,Task_Data * IData);
static void _jump0(int *addr,Task_Data * IData);
static void _literal (int *addr,Task_Data * IData);
static void __literal ();
static void _variable (char* ptr,Task_Data * IData);
static void _allot(char* ptr,Task_Data * IData);
static void alloc_d(int len,Task_Data * IData);
static void _cells(char* ptr,Task_Data * IData);
static void _tick(char* ptr,Task_Data * IData);
static void _drop (char* ptr,Task_Data * IData);
static void _m_f_ds_t_rs(char* ptr,Task_Data * IData);
static void _m_f_rs_t_ds(char* ptr,Task_Data * IData);
static void _c_f_rs_t_ds(char* ptr,Task_Data * IData);
static void _postpone(int *addr,Task_Data * IData);
static void _compile_next(int *addr,Task_Data * IData);
static void _led (char* ptr,Task_Data * IData);
static void _begin (char* ptr,Task_Data * IData);
static void _until (char* ptr,Task_Data * IData);


int init_forth_engine (int count)
{
	int errno;
	number_of_tasks=count;
	errno = set_up_data_segment ();
		
	CHECK_ERR (errno, "E100");

	set_up_core();

	return 0;
}
//this function sets up the global dictionary in the flash and sets the pointers to the same.
static int set_up_data_segment ()
{
	int j=0;
	char * Flash_ptr;
	//here = data_segment;
	//latest = 0;
	//*TOIP(data_segment) = 0;
	//data_set(0,global_dictionary);
	Global_Dict=&GlobalDict;
	Global_Dict->here=global_dictionary;
	Global_Dict->latest=0;
	*TOIP(global_dictionary) = 0;
	for (j = 0; j < 1024; j++)
	Global_Dict->here[j] = 0xff;
	Flash_ptr = (char *) (global_dictionary);
	//FCTL3 = FWKEY;                            // Clear Lock bit
	//FCTL1 = FWKEY+ERASE;                      // Set Erase bit
	*Flash_ptr = 0; 
	//FCTL1 = FWKEY+ERASE;
	Flash_ptr = (char *) (global_dictionary+512); 
	*Flash_ptr = 0;   
	Global_Dict->vtid=-1;
	Global_Dict->Next=0;
	vt_cur_node=Global_Dict;
	reset_buffer();
	return 0;
}
/*
* The interpreter variables and pointers are initialised for each virtual 
* task and a linked list of Task_Data is formed.
*/
void data_set(Task_Data * IData,char *data_segment)
{   
	int j=0;
	//dsp = TOIP(DS_BASE);
	//rsp = TOIP(RS_BASE);
	
	
	IData->dsp=TOIP(DST_BASE(data_segment));
	IData->rsp=TOIP(RST_BASE(data_segment));
	IData->here=data_segment;
	IData->latest=0;
	IData->forth_buffer=BUFT_BASE(data_segment);
	*TOIP(data_segment) = 0;
	for (j = 0; j < 512; j++)
		IData->here[j] = 0xff;
	
	IData->c= -1;
	IData->forth_engine_poll=0;
	IData->buffer_ind= 0; 
	IData->state= 0; 
	//void (*xt)();
	IData->dsp_base=TOIP(DST_BASE(data_segment));
	IData->rsp_base=TOIP(RST_BASE(data_segment));
	IData->here_base=data_segment;
	IData->forth_buffer_base=BUFT_BASE(data_segment);
	IData->vtid=-1;
	IData->Next=vt_cur_node;
	vt_cur_node=IData;
	//char data_segment[2048];
	add_variable_d("HERE", TOIP(&IData->here),IData);
	add_variable_d("LATEST", TOIP(&IData->latest),IData);
	add_variable_d("STATE", TOIP(&IData->state),IData);
	
}

void interpret(Task_Data *IData)
{
	char *ptr;
	int *link;
	
	if (!word(IData))
		return;
	
	link = find(IData);
	
	ptr = (char*) (link + 1);
	if (link)
	{
		int len = (int)*ptr;
		ptr = ptr + RFLAGS(len) + 1 + ((int)(RFLAGS(len) + 1) % 2);
		
		if (IData->state == 0 || len & IMMED_FLAG)
		{
			IData->xt = (void (*)())(*(TOIP(ptr)) & 0xffff);
			
			
			IData->xt(&ptr,IData);
			
			//xt();
		} else
		{
			
			compile(TOIP(ptr),IData);
		}
	} else
	{
		
		if (isnumber(IData))
		{
			if (IData->state == 0)
			{
				
				DSPUSH(number(IData),IData->dsp);
				
			} else
			{
				ptr = (char*)find_a("LITERAL",Global_Dict->latest);
				compile(TOIP(get_exec_ptr(ptr)),IData);
				compile(TOIP(number(IData)),IData);
			}
		} else
		{
			EMITERRS("Error: Unrecognized command\n");
			//stacks_reset(); have to fix this
		}
	}
	
}
/*
* The null character placed after the end of a word is 
* replaced with whitespace once the word is interpreted.This is to ensure
* that the original program with whitespace gets migrated 
*/
static int word(Task_Data * IData)
{
	int found = 0;
	if (IData->c == 0)
	{
		IData->forth_engine_poll = 0;
		//reset_buffer();
		IData->forth_buffer=IData->forth_buffer_base;//BUFT_BASE(IData->data_segment);
		IData->buffer_ind = 0;
		return 0;
	} else
	{   if(IData->c== ' ')  //fix srinivas
		IData->forth_buffer[IData->buffer_ind-1]=' ';  //fix srinivas
	IData->forth_buffer = IData->forth_buffer + IData->buffer_ind;
	IData->buffer_ind = 0;
	}
	while (1)
	{
		IData->c = IData->forth_buffer[IData->buffer_ind];
		if (IData->c == ' ')
		{
			if (found)
				break;
		} else if (IData->c == 0)
		{
			if (found)
			{
				break;
			} else
			{
				//reset_buffer();
				IData->forth_buffer=IData->forth_buffer_base;//BUFT_BASE(IData->data_segment);
				IData->buffer_ind = 0;
				return 0;
			}
		} else
		{
			#ifdef CASE_INSENSITIVE
			if (IData->forth_buffer[IData->buffer_ind] >= 97 && IData->forth_buffer[IData->buffer_ind] <= 122)
				IData->forth_buffer[IData->buffer_ind] -= 32;
			#endif
			IData->buffer_ind++;
			found = 1;
		}
	}
	IData->forth_buffer[IData->buffer_ind++] = 0;
	return 1;
}

static int* find(Task_Data * IData)
{
	int* link=find_a(IData->forth_buffer,Global_Dict->latest);
	if(!(link)) return find_a(IData->forth_buffer,IData->latest);
	else return link;
	
}

static int* find_a(char *str,char* _latest)
{
	char *link = _latest;
	int len = strlen(str);
	while (link)
	{
		if (!HIDDEN(link[sizeof(int*)]) && ((int)(RFLAGS(link[sizeof(int)])) == len) && (!strncmp(link+1+sizeof(int*), str, (int)(RFLAGS(link[sizeof(int*)])))))
		{
			return TOIP(link);
		}
		link = (char*)*(TOIP(link));
	}
	return 0;
}


static int isnumber(Task_Data * IData)
{
	int i;
	if ((IData->forth_buffer[0] <= 47 || IData->forth_buffer[0] >= 58) && IData->forth_buffer[0] != 45)
		return 0;
	for (i = 1; i < IData->buffer_ind-1; i++)
	{
		if (IData->forth_buffer[i] <= 47 || IData->forth_buffer[i] >= 58)
			return 0;
	}
	return 1;
}

static int number(Task_Data * IData)
{
	return atoi(IData->forth_buffer);
}

static void add_word_page (char *name, uint32_t func_pointer)
{
	add_header (name,Global_Dict);
	compile((int*)(int)code,Global_Dict);
}

static void add_word (char *name, void (*code)())
{
	add_header (name,Global_Dict);
	compile((int*)(int)code,Global_Dict);
}
//this function adds the word and also makes it immediate simultaneously
static void add_word_immediate(char *name, void (*code)()){
	int len = strlen(name);
	char *ptr;
	Task_Data * IData=Global_Dict;
	assert(len < 64);
	
	ptr = IData->here + sizeof(int*);
	*(TOIP(IData->here)) = (int)IData->latest;
	*(ptr++) = (len | 128);
	strncpy(ptr, name, RFLAGS(len));
	IData->latest = IData->here;
	IData->here += sizeof (int*) + sizeof (char) + RFLAGS(len);
	if (((int)IData->here) % 2)
		IData->here++;
	compile((int*)(int)code,Global_Dict);
}

void add_variable (char *name,Task_Data * IData)
{
	add_header(name,IData);
	compile((int*)(int)docol,IData);
	compile(TOIP((get_exec_ptr((char*)find_a("LITERAL",Global_Dict->latest)))),IData);
	compile(TOIP((IData->here + 2 * sizeof(int))),IData);
	compile(0,IData);
	compile(0,IData);
}

static void add_variable_d (char *name, int *addr,Task_Data * IData)
{
	add_header(name,IData);
	compile((int*)(int)docol,IData);
	compile(TOIP((get_exec_ptr((char*)find_a("LITERAL",Global_Dict->latest)))),IData);
	compile(TOIP(addr),IData);
	compile(0,IData);
}

static void _variable(char* ptr,Task_Data * IData)
{
	word(IData);
	add_variable(IData->forth_buffer,IData);
}

static void _add_header (char* ptr,Task_Data * IData)
{
	word(IData);
	add_header(IData->forth_buffer,IData);
}

static void add_header (char *name,Task_Data * IData)
{
	int len = strlen(name);
	char *ptr;
	assert(len < 64);
	
	ptr = IData->here + sizeof(int*);
	*(TOIP(IData->here)) = (int)IData->latest;
	*(ptr++) = len;
	strncpy(ptr, name, RFLAGS(len));
	IData->latest = IData->here;
	IData->here += sizeof (int*) + sizeof (char) + RFLAGS(len);
	if (((int)IData->here) % 2)
		IData->here++;
}

static void reset_buffer()
{/*
	forth_buffer = BUF_BASE;
	buffer_ind = 0;
	*/
}

static void _make_immediate(char* ptr,Task_Data * IData)
{
	IData->latest[sizeof(int*)] |= 128;
}

static void _make_hidden()
{
	Global_Dict->latest[sizeof(int*)] |= 64;
}

static void compile (int *link,Task_Data * IData)
{
	*(TOIP(IData->here)) = (int)link;
	IData->here += sizeof(int*);
}

/** Basic FORTH words, variables and constants */
static void set_up_core ()
{int i=0;
	add_word_page (".", (uint32_t)_dot);
	add_word (".S", _dots);
	add_word_page ("+", (uint32_t)_plus);
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
	add_word_immediate ("POSTPONE", _postpone);
	//_make_immediate(0,Global_Dict);
	add_word ("COMPILE_NEXT", _compile_next);
	
	add_word (">R", _m_f_ds_t_rs);
	add_word ("R>", _m_f_rs_t_ds);
	add_word ("R@", _c_f_rs_t_ds);
	
	add_word (",", _comma);
	add_word ("'", _tick);
	add_word_immediate (":", _colon);
	//_make_immediate(0,Global_Dict);
	add_word_immediate (";", _semicolon);
	//_make_immediate(0,Global_Dict);
	add_word_immediate ("IF", _if_c);
	//_make_immediate(0,Global_Dict);
	add_word_immediate ("ELSE", _else_c);
	//_make_immediate(0,Global_Dict);
	add_word_immediate ("THEN", _then_c);
	//_make_immediate(0,Global_Dict);
	add_word ("BRANCH", _jump);
	add_word ("0BRANCH", _jump0);
	add_word("LED",_led);
	add_word("BEGIN",_begin);
	add_word("UNTIL",_until);
	/*
	for(i=1;i<number_of_tasks;i++){
	add_variable_d("HERE", TOIP(&IData->here),i);
	add_variable_d("LATEST", TOIP(&IData->latest),i);
	add_variable_d("STATE", TOIP(&IData->state),i);
	}
	*/
}

static void docol(int *addr,Task_Data * IData)
{
	int *ptr;
	void (*func)();
	addr = TOIP(*addr);
	ptr = (int*)(int)IData->xt;
	RSPUSH((int)ptr,IData->rsp);
	ptr = addr + 1;
	IData->xt = (void (*)())ptr;
	
	func = (void (*)())*(int*)*TOIP(ptr);
	while (1)
	{
		func(TOIP(ptr),IData);
		ptr = (int*)(int)IData->xt;
		ptr++;
		IData->xt = (void (*)())ptr;
		if (*ptr == 0)
			break;
		func = (void (*)())(*TOIP(*ptr)& 0xffff);
	}
	RSPOPfp(IData->xt,IData->rsp);
}

static void _docol (char* ptr,Task_Data * IData)
{
	compile((int*)(int)docol,IData);
}

static void _dot (char* ptr,Task_Data * IData)
{
	int val;
	int id=1;
	char str[20];
	if (IData->dsp != IData->dsp_base)//TOIP(DST_BASE(IData->data_segment)))
	{
		DSPOP(val,IData->dsp);
		//sprintf(str,"Task %d: %d",id,val);
		//halLcdPrintLineCol(str,id*2,0,0x04);
	} else
	{
		EMITERRS("Stack underflow.\n");
	}
}

static void _dots (char* ptr,Task_Data * IData)
{
	int *i;
	int j=0;
	int id=1;
	int k=id*2;
	char str[4];
	char str1[20];
	for (i = IData->dsp_base; (i - IData->dsp) * DS_GROW < 0; i = i + DS_GROW)
	{
		if(j==0) {sprintf(str1,"Task %d: %d",id, *i);
			//halLcdPrintLineCol(str1,k,j++,0x04);
			continue;
		}
		else {
			sprintf(str,"%d", *i);
		}
		if(j<5){}
		//halLcdPrintLineCol(str,k,j++,0x04);
		else{
			j=0;
			//halLcdPrintLineCol(str,++k,j++,0x04);
		}
	}
	//printf("\n");
}

static void _plus (char* ptr,Task_Data * IData)
{
	*(IData->dsp - 2*DS_GROW) += *(IData->dsp - DS_GROW);
	IData->dsp++;
}

static void _minus (char* ptr,Task_Data * IData)
{
	*(IData->dsp - 2*DS_GROW) -= *(IData->dsp - DS_GROW);
	IData->dsp++;
}

static void _mult (char* ptr,Task_Data * IData)
{
	*(IData->dsp - 2*DS_GROW) *= *(IData->dsp - DS_GROW);
	IData->dsp++;
}

static void _div (char* ptr,Task_Data * IData)
{
	*(IData->dsp - 2*DS_GROW) /= *(IData->dsp - DS_GROW);
	IData->dsp++;
}

static void _fetch (char* ptr,Task_Data * IData)
{
	int *ptr1;
	DSPOPp(ptr1,IData->dsp);
	DSPUSH(*ptr1,IData->dsp);
}

static void _store (char* ptr,Task_Data * IData)
{
	int *dest, val;
	DSPOPp(dest,IData->dsp);
	DSPOP(val,IData->dsp);
	*dest = val;
}

static void _colon (char* ptr,Task_Data * IData)
{
	IData->state = 1;
	word(IData);
	add_header (IData->forth_buffer,IData);
	compile((int*)(int)docol,IData);
}

static void _semicolon (char* ptr,Task_Data * IData)
{
	compile(0,IData);
	IData->state = 0;
}

static void _if_c (char* ptr,Task_Data * IData)
{
	compile(TOIP((get_exec_ptr((char*)find_a("0BRANCH",IData->latest)))),IData);
	RSPUSH((int)IData->here,IData->rsp);
	compile(0,IData);
}

static void _else_c (char* ptr,Task_Data * IData)
{
	int *origin;
	int offset;
	RSPOPp(origin,IData->rsp);
	
	compile(TOIP((get_exec_ptr((char*)find_a("BRANCH",IData->latest)))),IData);
	RSPUSH((int)IData->here,IData->rsp);
	compile(0,IData);
	
	offset = (int)(TOIP(IData->here) - origin);
	*origin = offset;
}

static void _then_c (char* ptr,Task_Data * IData)
{
	int *origin;
	int offset;
	RSPOPp(origin,IData->rsp);
	offset = (int)(TOIP(IData->here) - origin) - 1;
	*origin = offset;
}

//static void 
//{}

static void _jump (int *addr,Task_Data * IData)
{
	int* ptr = (int*)(int)IData->xt;
	ptr++;
	ptr += *ptr;
	IData->xt = (void (*)())ptr;
}

static void _jump0 (int *addr,Task_Data * IData)
{
	int jump_offset;
	int *ptr; 
	int val;
	addr++;
	DSPOP(val,IData->dsp);
	if (!val)
	{
		jump_offset = *addr;
	} else
	{
		jump_offset = 1;
	}
	ptr = (int*)(int)IData->xt;
	ptr += jump_offset;
	IData->xt = (void (*)())ptr;
}

static void _literal (int *addr,Task_Data * IData)
{
	int* ptr;
	DSPUSH(*(addr + 1),IData->dsp);
	ptr = (int*)(int)IData->xt;
	ptr++;
	IData->xt = (void (*)())ptr;
}

static void __literal (char* ptr,Task_Data * IData)
{
	int val;
	compile(TOIP((get_exec_ptr((char*)find_a("LITERAL",Global_Dict->latest)))),IData);
	DSPOP(val,IData->dsp);
	compile(TOIP(val),IData);
	
}

static char* get_exec_ptr(char *ptr)
{
	int len = RFLAGS((int)ptr[sizeof(int*)]);
	return ((ptr + len + 1 +  sizeof(int*))  +  ((int)(ptr + len + 1 +  sizeof(int*)) % 2));
}

static void alloc_d(int len,Task_Data * IData)
{
	IData->here += len;
}

static void _allot(char* ptr,Task_Data * IData)
{
	int val;
	DSPOP(val,IData->dsp);
	alloc_d(val,IData);
}

static void _cells(char* ptr,Task_Data * IData)
{
	int val;
	DSPOP(val,IData->dsp);
	DSPUSH(val * CELLSIZE,IData->dsp);
}

static void _tick(char* ptr,Task_Data * IData)
{
	word(IData);
	DSPUSH((int)get_exec_ptr((char*)find(IData)),IData->dsp);
}

static void _comma (char* ptr,Task_Data * IData)
{
	int val;
	DSPOP(val,IData->dsp);
	compile(TOIP(val),IData);
}

static void _dup (char* ptr,Task_Data * IData)
{
	DSPUSH(*(IData->dsp - DS_GROW),IData->dsp);
}

static void _swap (char* ptr,Task_Data * IData)
{
	int tmp = *(IData->dsp - DS_GROW);
	*(IData->dsp - DS_GROW) = *(IData->dsp - 2*DS_GROW);
	*(IData->dsp - 2*DS_GROW) = tmp;
}

static void _drop (char* ptr,Task_Data * IData)
{
	IData->dsp -= DS_GROW;
}

static void _less (char* ptr,Task_Data * IData)
{
	int n1, n2;
	DSPOP(n2,IData->dsp);
	DSPOP(n1,IData->dsp);
	if (n1 < n2)
	{
		DSPUSH(1,IData->dsp);
	} else
	{
		DSPUSH(0,IData->dsp);
	}
}

static void _greater (char* ptr,Task_Data * IData)
{
	int n1, n2;
	DSPOP(n2,IData->dsp);
	DSPOP(n1,IData->dsp);
	if (n1 > n2)
	{
		DSPUSH(1,IData->dsp);
	} else
	{
		DSPUSH(0,IData->dsp);
	}
}

static void _equal (char* ptr,Task_Data * IData)
{
	int n1, n2;
	DSPOP(n2,IData->dsp);
	DSPOP(n1,IData->dsp);
	if (n1 == n2)
	{
		DSPUSH(1,IData->dsp);
	} else
	{
		DSPUSH(0,IData->dsp);
	}
}

static void _m_f_ds_t_rs(char* ptr,Task_Data * IData)
{
	int val;
	DSPOP(val,IData->dsp);
	RSPUSH(val,IData->rsp);
}

static void _m_f_rs_t_ds(char* ptr,Task_Data * IData)
{
	int val;
	RSPOP(val,IData->rsp);
	DSPUSH(val,IData->dsp);
}

static void _c_f_rs_t_ds(char* ptr,Task_Data * IData)
{
	DSPUSH(*(IData->rsp - RS_GROW),IData->dsp);
}

static void _postpone (int *addr,Task_Data * IData)
{
	int *ptr;
	char *link;
	word(IData);
	link = (char*)find(IData);
	if (!IMMEDIATE(link[sizeof(int*)]))
	{
		compile(TOIP(get_exec_ptr((char*)find_a("COMPILE_NEXT",Global_Dict->latest))),IData);
	}
	compile(TOIP(get_exec_ptr((char*)link)),IData);
	ptr = (int*)(int)IData->xt;
	ptr++;
	IData->xt = (void (*)())ptr;
}

static void _compile_next (int *addr,Task_Data * IData)
{
	int *ptr;
	compile(TOIP(*(addr + 1)),IData);
	ptr = (int*)(int)IData->xt;
	ptr++;
	IData->xt = (void (*)())ptr;
}

static void _rot (char* ptr,Task_Data * IData)
{
	int val;
	val = *(IData->dsp - 3*DS_GROW);
	*(IData->dsp - 3*DS_GROW) = *(IData->dsp - 2*DS_GROW);
	*(IData->dsp - 2*DS_GROW) = *(IData->dsp - DS_GROW);
	*(IData->dsp - DS_GROW) = val;
}

static void _nrot (char* ptr,Task_Data * IData)
{
	int val;
	val = *(IData->dsp - DS_GROW);
	*(IData->dsp - DS_GROW) = *(IData->dsp - 2*DS_GROW);
	*(IData->dsp - 2*DS_GROW) = *(IData->dsp - 3*DS_GROW);
	*(IData->dsp - 3*DS_GROW) = val;
}
static void _led (char* ptr,Task_Data * IData)
{
	int val;
	//P3OUT |= 0x20;
	DSPOP(val,IData->dsp);
	//val=val & 0x03;
//	P1OUT &=(~0x03);
//	P1OUT |= (0x03 & val);
	//P3OUT &= (~0x20);
}
static void _begin (char* ptr,Task_Data * IData)
{
	RSPUSH((int)(IData->forth_buffer-IData->forth_buffer_base),IData->rsp);
}
static void _until (char* ptr,Task_Data * IData)
{   char *origin;
	int offset;
	
	int val;
	RSPOP(offset,IData->rsp);
	origin=IData->forth_buffer_base+offset;
	DSPOP(val,IData->dsp);
	if(val==0) {
		if(IData->c==' ')
			IData->forth_buffer[IData->buffer_ind-1]=' ';
		
		IData->forth_buffer=(char*)origin;
		IData->buffer_ind = 0;
		IData->c=-1;
	}
	
	
}
/*the interpreter variables and pointers are set using the offset.
*the variables are added.this structure is added to the linked list of Task_Data. 
*/
void set_pointers(Task_Data *IData,char *data_segment){
	int j=0;
	IData->rsp=TOIP(RST_BASE(data_segment))+(IData->rsp-IData->rsp_base);
	IData->dsp=TOIP(DST_BASE(data_segment))+(IData->dsp-IData->dsp_base);
	IData->here=data_segment;
	IData->latest=0;
	IData->forth_buffer=(BUFT_BASE(data_segment))+(IData->forth_buffer-IData->forth_buffer_base);
	IData->rsp_base=TOIP(RST_BASE(data_segment));
	IData->dsp_base=TOIP(DST_BASE(data_segment));
	IData->here_base=data_segment;
	IData->forth_buffer_base=(BUFT_BASE(data_segment));
	*TOIP(data_segment) = 0;
	for (j = 0; j < 512; j++)
		IData->here[j] = 0xff;
	IData->Next=vt_cur_node;
	vt_cur_node=IData;
	add_variable_d("HERE", TOIP(&IData->here),IData);
	add_variable_d("LATEST", TOIP(&IData->latest),IData);
	add_variable_d("STATE", TOIP(&IData->state),IData);
}
