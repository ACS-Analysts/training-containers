package com.analysts.containerdemo;

import java.io.*;
import java.lang.StringBuilder;
import java.net.ServerSocket;
import java.net.Socket;

public class HelloVault {
    public static void main(String[] args) throws IOException{
        int n = 0;
        String name = "world";
        String secret_path = "/etc/secrets/hello_secret";
        String charsetName = "UTF-8";
        ServerSocket listener = new ServerSocket(8080);

        if (args.length > 0 && !args[0].isBlank()) name = args[0];
        if (args.length > 1 && !args[1].isBlank()) secret_path = args[1];

        while(true){
            Socket sock = listener.accept();

            PrintWriter pw = new PrintWriter(sock.getOutputStream(), true);

            pw.printf("Hello %s!", name);

            StringBuilder sb = new StringBuilder();
            try {
                FileInputStream fis = new FileInputStream(secret_path);
                InputStreamReader in = new InputStreamReader(fis, charsetName);
                int i;
                while ((i=in.read()) != -1) {
                    sb.append(i);
                }
            } catch (FileNotFoundException e) {
                // Do nothing
            }

            if (sb.length() > 0) {
                pw.printf(" I know your secret: '%s'.", sb.toString());
            } else {
                pw.print(" You have no secrets.");
            }

            pw.printf(" (%d)\n", n);

            sock.close();
            n++;
        }
    }
}
