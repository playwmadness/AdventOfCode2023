import java.io.*;
import java.util.*;

class Solution {
    public static int RED = 12;
    public static int GREEN = 13;
    public static int BLUE = 14;

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.print("Expected input file path");
            System.exit(1);
        }

        int res = 0;
        int res2 = 0;
        try (var in = new Scanner(new File(args[0]))) {
            while (in.hasNextLine()) {
                int red = 0;
                int green = 0;
                int blue = 0;

                var line = new Scanner(in.nextLine());
                line.useDelimiter("[ :;,]+");
                line.next();
                int gameId = line.nextInt();

                while (line.hasNextInt()) {
                    int amt = line.nextInt();
                    String col = line.next();

                    if ((col.equals("red") && amt > RED)
                            || (col.equals("green") && amt > GREEN)
                            || (col.equals("blue") && amt > BLUE)) {
                        gameId = 0;
                    }

                    if (col.equals("red") && amt > red) {
                        red = amt;
                    }
                    if (col.equals("green") && amt > green) {
                        green = amt;
                    }
                    if (col.equals("blue") && amt > blue) {
                        blue = amt;
                    }
                }

                res += gameId;
                res2 += red * green * blue;
            }
        } catch(FileNotFoundException e) {
            e.printStackTrace();
        }

        System.out.print("Result 1: ");
        System.out.println(res);

        System.out.print("Result 2: ");
        System.out.println(res2);
    }
}
