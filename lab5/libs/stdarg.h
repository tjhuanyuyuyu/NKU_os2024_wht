#ifndef __LIBS_STDARG_H__
#define __LIBS_STDARG_H__

/* compiler provides size of save area */
typedef __builtin_va_list va_list;//用于处理可变参数列表的类型

#define va_start(ap, last)              (__builtin_va_start(ap, last))//初始化可变参数列表 ap，并准备从 last 之后开始读取参数
#define va_arg(ap, type)                (__builtin_va_arg(ap, type))//从可变参数列表 ap 中获取下一个指定类型 type 的参数
#define va_end(ap)                      /*nothing*///结束可变参数处理

#endif /* !__LIBS_STDARG_H__ */

