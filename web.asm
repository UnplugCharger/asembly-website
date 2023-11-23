format ELF64 executable 64


sys_write = 1
sys_exit = 60
sys_socket = 41
sys_bind = 49
sys_listen = 50
sys_close = 3
sys_accept = 43

AF_INET = 2
SOCK_STREAM = 1
INADDR_ANY = 0

stdin = 0
stdout = 1
stderr = 2

exit_success = 0
exit_failure = 1

max_pending_connections = 10
max_connections = 100


macro write fd, buf, count
{
    mov rax, sys_write
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro exit code
{
    mov rax, sys_exit
    mov rdi, code
    syscall
}

;; int socket(int domain, int type, int protocol);
;; int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

macro socket domain, type, protocol
{
    mov rax, sys_socket
    mov rdi, domain
    mov rsi, type
    mov rdx, protocol
    syscall
}

macro bind sockfd, addr, addrlen
{
    mov rax, sys_bind
    mov rdi, sockfd
    mov rsi, addr
    mov rdx, addrlen
    syscall
}

macro listen sockfd, backlog
{
    mov rax, 50
    mov rdi, sockfd
    mov rsi, backlog
    syscall
}

macro accept sockfd, addr, addrlen
{
    mov rax, sys_accept
    mov rdi, sockfd
    mov rsi, addr
    mov rdx, addrlen
    syscall
}

macro close fd
{
    mov rax, sys_close
    mov rdi, fd
    syscall
}

segment readable executable
entry main

main:
   write stdout, start, start_len
   socket AF_INET, SOCK_STREAM, 0
   cmp rax, 0
   jl error
   mov qword [sockfd] , rax 
    

    ;; struct sockaddr_in servaddr;
    write stdout, bind_trace_message, bind_trace_message_len
    mov word [servaddr.sin_family], AF_INET
    mov word [servaddr.sin_port], 0x901f
    mov dword [servaddr.sin_addr], INADDR_ANY
    bind [sockfd], servaddr.sin_family, servaddr.size
    cmp rax, 0
    jl error


    write stdout, okay_start_listening, okay_start_listening_len
    listen [sockfd], max_pending_connections
    cmp rax, 0
    jl error

    ;; int clientfd;
next_request:
    write stdout, okay_start_accepting, okay_start_accepting_len
    accept [sockfd], clientaddr.sin_family, clientaddr_len
    cmp rax, 0
    jl error
    mov qword [connfd], rax


    write [connfd], response, response_len
    jmp next_request


   
   write stdout, okay_webserver_started, okay_webserver_started_len
    close [sockfd]
   exit 0

error:
    write stderr, error_msg, error_msg_len
    close [connfd]
    close [sockfd]
    exit 1


segment readable writable


struc servaddr_in
{
    .sin_family dw 0
    .sin_port dw 0
    .sin_addr dd 0
    .sin_zero dq 0
    .size = $ - .sin_family
    
}


sockfd dq -1
connfd dq -1
servaddr servaddr_in 
clientaddr servaddr_in
clientaddr_len dd clientaddr.size

response db "HTTP/1.1 200 OK",13,10
         db "Content-Type: text/html; charset=UTF-8",13,10
         db "Connection: close",13,10
         db 13,10
       db "<!DOCTYPE html>"
db "<html lang='en'>"
db "<head>"
db "<meta charset='utf-8'>"
db "<title>"
db "beautiful and simple website using html only -- fullywrold web tutorials"
db "</title>"
db "</head>"
db "<body background='1.jpg' link='#000' alink='#017bf5' vlink='#000'>"
db "<br />"
db "<h3 align='center'>"
db "<font face='Lato' size='6'>LOGO</font>"
db "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
db "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
db "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
db "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
db "<font face='cinzel' size='4'>"
db "<a href='#'>HOME</a>&nbsp;&nbsp;&nbsp;&nbsp;"
db "<a href='#'>VIDEOS</a>&nbsp;&nbsp;&nbsp;&nbsp;"
db "<a href='#'>PORTFOLIO</a>&nbsp;&nbsp;&nbsp;&nbsp;"
db "<a href='#'>BLOG</a>&nbsp;&nbsp;&nbsp;&nbsp;"
db "<a href='#'>CONTACT US</a>"
db "</font>"
db "</h3>"
db "<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />"
db "<h1 align='center'>"
db "<font face='Lato' color='#017bf5' size='7'>"
db "BEAUTIFUL AND SIMPLE WEB PAGE"
db "</font>"
db "</h1>"
db "<h3 align='center'>"
db "<font face='Lato' color='#000' size='5'>"
db "USING HTML ONLY (NO CSS USED)"
db "</font>"
db "</h3>"
db "<br />"
db "<h3 align='center'>"
db "<a href='#'>"
db "<font face='Lato' color='#000'>GET STARTED</font>"
db "</a>&nbsp;&nbsp;&nbsp;&nbsp;"
db "<a href='#'>"
db "<font face='Lato' color='#fff'>SUBSCRIBE US</font>"
db "</a>"
db "</h3>"
db "</body>"
db "</html>"
db 0

response_len = $ - response


start db "INFO: Starting Websever", 10
start_len = $ - start
error_msg db "ERROR: Error", 10
error_msg_len = $ - error_msg
okay_webserver_started db "INFO: Okay Webserver Started", 10
okay_webserver_started_len = $ - okay_webserver_started
bind_trace_message db "INFO: Binding to port 8080", 10
bind_trace_message_len = $ - bind_trace_message
okay_start_listening db "INFO: Okay, start listening", 10
okay_start_listening_len = $ - okay_start_listening
okay_start_accepting db "INFO: Okay, start accepting", 10
okay_start_accepting_len = $ - okay_start_accepting
hello_from_webserver db "Hello from webserver", 10
hello_from_webserver_len = $ - hello_from_webserver





