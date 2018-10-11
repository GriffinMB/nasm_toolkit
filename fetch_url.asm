global _main 
extern _curl_easy_init, _curl_easy_setopt, _curl_easy_perform, _curl_easy_cleanup
extern _malloc, _memcpy, _printf

section .data

print_s:
        db          "%s", 10, 0
print_err:
        db          "An error occurred: %p.", 10, 0
url:
        db          "http://localhost:8000/index.html", 0

CURL_OK equ                 0
CURLOPT_URL equ             10002
CURLOPT_WRITEFUNCTION equ   20011
CURLOPT_WRITEDATA equ       10001

section .text

_main:
        push        rbp
        lea         r12, [rel url]

        ; void *malloc();
        mov         rdi, 0x10000
        call        _malloc
        mov         r13, rax

        ; CURL *curl_easy_init();
        call        _curl_easy_init
        mov         r14, rax

        ; CURLcode curl_easy_setopt(CURL *handle, CURLoption option, parameter);
        mov         rdi, r14
        mov         rsi, CURLOPT_URL
        mov         rdx, r12
        call        _curl_easy_setopt

        mov         rdi, r14
        mov         rsi, CURLOPT_WRITEFUNCTION
        lea         rdx, [rel writemem]
        call        _curl_easy_setopt

        mov         rdi, r14
        mov         rsi, CURLOPT_WRITEDATA
        mov         rdx, r13
        call        _curl_easy_setopt

        ; CURLcode curl_easy_perform(CURL * easy_handle );
        mov         rdi, r14
        call        _curl_easy_perform
        cmp         rax, CURL_OK
        je          done
        lea         rdi, [rel print_err]
        mov         rsi, rax
        call        _printf
done:
        pop         rbp
        ret    

writemem:
        push        rbp
        mov         rbp, rsp
        sub         rsp, 0x20
        mov         qword [rbp-16], rdi
        imul        rdx, rsi
        mov         rsi, rdi
        mov         rdi, rcx
        add         rdi, 1
        mov         qword [rbp-8], rdx
        call        _memcpy
        lea         rdi, [rel print_s]
        mov         rsi, [rbp-16]
        call        _printf
        add         rsp, 0x20
        mov         rax, [rbp-8]
        pop         rbp
        ret


