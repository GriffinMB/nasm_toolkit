; nasm -f macho64 get.asm && clang get.o -lcurl && ./a.out

extern _curl_easy_init
extern _curl_easy_setopt
extern _curl_easy_perform
extern _curl_easy_cleanup
extern _fwrite
extern _fopen
extern _printf

section .text
global _main

_main:
        push        rbp
        mov         rbp, rsp
        sub         rsp, 0x50
        mov         r13, [rsi+8]
        mov         qword [rbp-8], rdi
        mov         qword [rbp-16], r13
        cmp         qword [rbp-8], 0x2
        jne         error

        ; CURL *curl_easy_init();
        call        _curl_easy_init
        mov         r12, rax

        ; CURLcode curl_easy_setopt(CURL *handle, CURLoption option, parameter);
        movd        rdi, r12
        movd        rsi, CURLOPT_URL
        movd        rdx, [rbp-16]
        calld       _curl_easy_setopt

        movd        rdi, r12
        movd        rsi, CURLOPT_WRITEFUNCTION
        lead        rdx, [rel pwrite]
        calld       _curl_easy_setopt

        lead        rdi, [rel filename]
        lead        rsi, [rel write_perm]
        calld       _fopen
        testd       rax, rax
        jzd         error
        movd        r13, rax

        movd        rdi, r12
        movd        rsi, CURLOPT_WRITEDATA
        movd        rdx, r13
        calld       _curl_easy_setopt

        ; CURLcode curl_easy_perform(CURL * easy_handle );
        mov         rdi, r12
        call        _curl_easy_perform
        cmp         rax, CURL_OK
        jne         error
        jmp         end
error:
        lea         rdi, [rel print_err]
        call        _printf
end:
        ; void curl_easy_cleanup(CURL *handle);
        mov         rdi, r12
        call        _curl_easy_cleanup
        pop         rbx
        add         rsp, 0x50
        ret

pwrite:
        push        rbp
        call        _fwrite
        pop         rbp
        ret


section .data

print_err:
        db          "An error occurred.", 10, 0
filename:
        db          "filename.txt", 0
write_perm:
        db          "wb", 0


; curl constants
CURL_OK equ                 0
CURLOPT_URL equ             10002
CURLOPT_WRITEFUNCTION equ   20011
CURLOPT_WRITEDATA equ       10001
