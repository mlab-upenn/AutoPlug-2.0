#ifndef NRK_INTERPRETER_H_
#define NRK_INTERPRETER_H_

#endif /*NRK_INTERPRETER_H_*/
typedef struct tasknode{
int *rsp;
int *dsp;
char *here;
char *latest;
char *forth_buffer;
int vtid;
int forth_engine_poll;
int buffer_ind;// = 0; 
int state; //= 0;
int *dsp_base;
int *rsp_base;
char *here_base;
char *forth_buffer_base;
//int *latest_base;
char c;// = -1;
void (*xt)();
struct tasknode *Next;
} Task_Data;
extern Task_Data TCBI[];
extern Task_Data *vt_cur_node;
//extern int atest;



