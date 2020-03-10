package com.analysts.containerdemo;

class Hello {
    private static int sleep_length = 5000;

    public static void main(String[] args) {
        int n = 0;
        String name = "world";

        if (args.length > 0 && !args[0].isBlank()) name = args[0];

        while (true) {
            n++;
            System.out.printf("Hello %s! (%d)\n", name, n);
            try {
                Thread.sleep(sleep_length);
            }
            catch (Exception e) {
                // Do nothing
            }
        }
    }
}
