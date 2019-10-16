package com.analysts.containerdemo;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class HelloSocket {
    public static void main(String[] args) throws IOException{
        int n = 0;
        String name = "world";
        ServerSocket listener = new ServerSocket(8080);

        if (args.length > 0 && !args[0].isBlank()) name = args[0];

        while(true){
            Socket sock = listener.accept();
            new PrintWriter(sock.getOutputStream(), true).
                printf("Hello %s! (%d)\n", name, n);
            sock.close();
        }
    }
}
