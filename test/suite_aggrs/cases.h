/* {ici} */
struct A2{ i m0; c m1; i m2; };
void f_cpA2(struct A2 *x, const struct A2 *y) { x->m0 = y->m0; x->m1 = y->m1; x->m2 = y->m2; };
int f_cmpA2(const struct A2 *x, const struct A2 *y) { return x->m0 == y->m0 && x->m1 == y->m1 && x->m2 == y->m2; };
DCstruct* f_newdcstA2() { DCstruct* st = dcNewStruct(3, sizeof(struct A2), 0, 1); dcStructField(st, 'i', offsetof(struct A2, m0), 1); dcStructField(st, 'c', offsetof(struct A2, m1), 1); dcStructField(st, 'i', offsetof(struct A2, m2), 1);  dcCloseStruct(st); return st; };
/* {ii} */
struct A1{ i m0; i m1; };
void f_cpA1(struct A1 *x, const struct A1 *y) { x->m0 = y->m0; x->m1 = y->m1; };
int f_cmpA1(const struct A1 *x, const struct A1 *y) { return x->m0 == y->m0 && x->m1 == y->m1; };
DCstruct* f_newdcstA1() { DCstruct* st = dcNewStruct(2, sizeof(struct A1), 0, 1); dcStructField(st, 'i', offsetof(struct A1, m0), 1); dcStructField(st, 'i', offsetof(struct A1, m1), 1);  dcCloseStruct(st); return st; };
/* {ps} */
struct A5{ p m0; s m1; };
void f_cpA5(struct A5 *x, const struct A5 *y) { x->m0 = y->m0; x->m1 = y->m1; };
int f_cmpA5(const struct A5 *x, const struct A5 *y) { return x->m0 == y->m0 && x->m1 == y->m1; };
DCstruct* f_newdcstA5() { DCstruct* st = dcNewStruct(2, sizeof(struct A5), 0, 1); dcStructField(st, 'p', offsetof(struct A5, m0), 1); dcStructField(st, 's', offsetof(struct A5, m1), 1);  dcCloseStruct(st); return st; };
/* {iiii} */
struct A9{ i m0; i m1; i m2; i m3; };
void f_cpA9(struct A9 *x, const struct A9 *y) { x->m0 = y->m0; x->m1 = y->m1; x->m2 = y->m2; x->m3 = y->m3; };
int f_cmpA9(const struct A9 *x, const struct A9 *y) { return x->m0 == y->m0 && x->m1 == y->m1 && x->m2 == y->m2 && x->m3 == y->m3; };
DCstruct* f_newdcstA9() { DCstruct* st = dcNewStruct(4, sizeof(struct A9), 0, 1); dcStructField(st, 'i', offsetof(struct A9, m0), 1); dcStructField(st, 'i', offsetof(struct A9, m1), 1); dcStructField(st, 'i', offsetof(struct A9, m2), 1); dcStructField(st, 'i', offsetof(struct A9, m3), 1);  dcCloseStruct(st); return st; };
/* {iii} */
struct A8{ i m0; i m1; i m2; };
void f_cpA8(struct A8 *x, const struct A8 *y) { x->m0 = y->m0; x->m1 = y->m1; x->m2 = y->m2; };
int f_cmpA8(const struct A8 *x, const struct A8 *y) { return x->m0 == y->m0 && x->m1 == y->m1 && x->m2 == y->m2; };
DCstruct* f_newdcstA8() { DCstruct* st = dcNewStruct(3, sizeof(struct A8), 0, 1); dcStructField(st, 'i', offsetof(struct A8, m0), 1); dcStructField(st, 'i', offsetof(struct A8, m1), 1); dcStructField(st, 'i', offsetof(struct A8, m2), 1);  dcCloseStruct(st); return st; };
/* {li} */
struct A4{ l m0; i m1; };
void f_cpA4(struct A4 *x, const struct A4 *y) { x->m0 = y->m0; x->m1 = y->m1; };
int f_cmpA4(const struct A4 *x, const struct A4 *y) { return x->m0 == y->m0 && x->m1 == y->m1; };
DCstruct* f_newdcstA4() { DCstruct* st = dcNewStruct(2, sizeof(struct A4), 0, 1); dcStructField(st, 'l', offsetof(struct A4, m0), 1); dcStructField(st, 'i', offsetof(struct A4, m1), 1);  dcCloseStruct(st); return st; };
/* {} */
struct A6{ };
void f_cpA6(struct A6 *x, const struct A6 *y) { 1; };
int f_cmpA6(const struct A6 *x, const struct A6 *y) { return 1; };
DCstruct* f_newdcstA6() { DCstruct* st = dcNewStruct(0, sizeof(struct A6), 0, 1);  dcCloseStruct(st); return st; };
/* {i} */
struct A7{ i m0; };
void f_cpA7(struct A7 *x, const struct A7 *y) { x->m0 = y->m0; };
int f_cmpA7(const struct A7 *x, const struct A7 *y) { return x->m0 == y->m0; };
DCstruct* f_newdcstA7() { DCstruct* st = dcNewStruct(1, sizeof(struct A7), 0, 1); dcStructField(st, 'i', offsetof(struct A7, m0), 1);  dcCloseStruct(st); return st; };
/* {il} */
struct A3{ i m0; l m1; };
void f_cpA3(struct A3 *x, const struct A3 *y) { x->m0 = y->m0; x->m1 = y->m1; };
int f_cmpA3(const struct A3 *x, const struct A3 *y) { return x->m0 == y->m0 && x->m1 == y->m1; };
DCstruct* f_newdcstA3() { DCstruct* st = dcNewStruct(2, sizeof(struct A3), 0, 1); dcStructField(st, 'i', offsetof(struct A3, m0), 1); dcStructField(st, 'l', offsetof(struct A3, m1), 1);  dcCloseStruct(st); return st; };
/* 0:viiiii{ii} */ v f0(i a1,i a2,i a3,i a4,i a5,struct A1 a6){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;f_cpA1(V_a[6],&a6);ret_v(6)}
/* 1:viiiii{ici} */ v f1(i a1,i a2,i a3,i a4,i a5,struct A2 a6){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;f_cpA2(V_a[6],&a6);ret_v(6)}
/* 2:viiiii{il} */ v f2(i a1,i a2,i a3,i a4,i a5,struct A3 a6){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;f_cpA3(V_a[6],&a6);ret_v(6)}
/* 3:vfiiiii{il} */ v f3(f a1,i a2,i a3,i a4,i a5,i a6,struct A3 a7){V_f[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;V_i[6]=a6;f_cpA3(V_a[7],&a7);ret_v(7)}
/* 4:viiiiif{il} */ v f4(i a1,i a2,i a3,i a4,i a5,f a6,struct A3 a7){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;V_f[6]=a6;f_cpA3(V_a[7],&a7);ret_v(7)}
/* 5:viiiiif{li} */ v f5(i a1,i a2,i a3,i a4,i a5,f a6,struct A4 a7){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;V_f[6]=a6;f_cpA4(V_a[7],&a7);ret_v(7)}
/* 6:viiiii{il}f */ v f6(i a1,i a2,i a3,i a4,i a5,struct A3 a6,f a7){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;f_cpA3(V_a[6],&a6);V_f[7]=a7;ret_v(7)}
/* 7:viiiii{li}f */ v f7(i a1,i a2,i a3,i a4,i a5,struct A4 a6,f a7){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;f_cpA4(V_a[6],&a6);V_f[7]=a7;ret_v(7)}
/* 8:viiffiii{ps} */ v f8(i a1,i a2,f a3,f a4,i a5,i a6,i a7,struct A5 a8){V_i[1]=a1;V_i[2]=a2;V_f[3]=a3;V_f[4]=a4;V_i[5]=a5;V_i[6]=a6;V_i[7]=a7;f_cpA5(V_a[8],&a8);ret_v(8)}
/* 9:viiiiiff{li} */ v f9(i a1,i a2,i a3,i a4,i a5,f a6,f a7,struct A4 a8){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;V_f[6]=a6;V_f[7]=a7;f_cpA4(V_a[8],&a8);ret_v(8)}
/* 10:viiiiiff{il} */ v f10(i a1,i a2,i a3,i a4,i a5,f a6,f a7,struct A3 a8){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;V_f[6]=a6;V_f[7]=a7;f_cpA3(V_a[8],&a8);ret_v(8)}
/* 11:viiiii{il}ff */ v f11(i a1,i a2,i a3,i a4,i a5,struct A3 a6,f a7,f a8){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;f_cpA3(V_a[6],&a6);V_f[7]=a7;V_f[8]=a8;ret_v(8)}
/* 12:viiiii{li}ff */ v f12(i a1,i a2,i a3,i a4,i a5,struct A4 a6,f a7,f a8){V_i[1]=a1;V_i[2]=a2;V_i[3]=a3;V_i[4]=a4;V_i[5]=a5;f_cpA4(V_a[6],&a6);V_f[7]=a7;V_f[8]=a8;ret_v(8)}
/* 13:i */ i f13(){ret_i(0)}
/* 14:i{} */ i f14(struct A6 a1){f_cpA6(V_a[1],&a1);ret_i(1)}
/* 15:i{i} */ i f15(struct A7 a1){f_cpA7(V_a[1],&a1);ret_i(1)}
/* 16:i{ii} */ i f16(struct A1 a1){f_cpA1(V_a[1],&a1);ret_i(1)}
/* 17:i{iii} */ i f17(struct A8 a1){f_cpA8(V_a[1],&a1);ret_i(1)}
/* 18:i{iiii} */ i f18(struct A9 a1){f_cpA9(V_a[1],&a1);ret_i(1)}
/* 19:f */ f f19(){ret_f(0)}
/* 20:f{} */ f f20(struct A6 a1){f_cpA6(V_a[1],&a1);ret_f(1)}
/* 21:f{i} */ f f21(struct A7 a1){f_cpA7(V_a[1],&a1);ret_f(1)}
/* 22:f{ii} */ f f22(struct A1 a1){f_cpA1(V_a[1],&a1);ret_f(1)}
/* 23:d{ii} */ d f23(struct A1 a1){f_cpA1(V_a[1],&a1);ret_d(1)}
/* 24:f{iii} */ f f24(struct A8 a1){f_cpA8(V_a[1],&a1);ret_f(1)}
/* 25:f{iiii} */ f f25(struct A9 a1){f_cpA9(V_a[1],&a1);ret_f(1)}
/* 26:ss{ii} */ s f26(s a1,struct A1 a2){V_s[1]=a1;f_cpA1(V_a[2],&a2);ret_s(2)}
funptr G_funtab[] = {
	(funptr)&f0,
	(funptr)&f1,
	(funptr)&f2,
	(funptr)&f3,
	(funptr)&f4,
	(funptr)&f5,
	(funptr)&f6,
	(funptr)&f7,
	(funptr)&f8,
	(funptr)&f9,
	(funptr)&f10,
	(funptr)&f11,
	(funptr)&f12,
	(funptr)&f13,
	(funptr)&f14,
	(funptr)&f15,
	(funptr)&f16,
	(funptr)&f17,
	(funptr)&f18,
	(funptr)&f19,
	(funptr)&f20,
	(funptr)&f21,
	(funptr)&f22,
	(funptr)&f23,
	(funptr)&f24,
	(funptr)&f25,
	(funptr)&f26,
};
char const * G_sigtab[] = {
	"viiiii{ii}",
	"viiiii{ici}",
	"viiiii{il}",
	"vfiiiii{il}",
	"viiiiif{il}",
	"viiiiif{li}",
	"viiiii{il}f",
	"viiiii{li}f",
	"viiffiii{ps}",
	"viiiiiff{li}",
	"viiiiiff{il}",
	"viiiii{il}ff",
	"viiiii{li}ff",
	"i",
	"i{}",
	"i{i}",
	"i{ii}",
	"i{iii}",
	"i{iiii}",
	"f",
	"f{}",
	"f{i}",
	"f{ii}",
	"d{ii}",
	"f{iii}",
	"f{iiii}",
	"ss{ii}",
};
const char* G_agg_sigs[]  = {
	"{ici}",
	"{ii}",
	"{ps}",
	"{iiii}",
	"{iii}",
	"{li}",
	"{}",
	"{i}",
	"{il}"
};
int G_agg_sizes[] = {
	sizeof(struct A2),
	sizeof(struct A1),
	sizeof(struct A5),
	sizeof(struct A9),
	sizeof(struct A8),
	sizeof(struct A4),
	sizeof(struct A6),
	sizeof(struct A7),
	sizeof(struct A3)
};
funptr G_agg_newdcstfuncs[] = {
	(funptr)&f_newdcstA2,
	(funptr)&f_newdcstA1,
	(funptr)&f_newdcstA5,
	(funptr)&f_newdcstA9,
	(funptr)&f_newdcstA8,
	(funptr)&f_newdcstA4,
	(funptr)&f_newdcstA6,
	(funptr)&f_newdcstA7,
	(funptr)&f_newdcstA3
};
funptr G_agg_cmpfuncs[] = {
	(funptr)&f_cmpA2,
	(funptr)&f_cmpA1,
	(funptr)&f_cmpA5,
	(funptr)&f_cmpA9,
	(funptr)&f_cmpA8,
	(funptr)&f_cmpA4,
	(funptr)&f_cmpA6,
	(funptr)&f_cmpA7,
	(funptr)&f_cmpA3
};
int G_maxargs = 8;
