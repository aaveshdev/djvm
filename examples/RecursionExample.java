import java.util.Scanner;

public class RecursionExample {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Enter a number for factorial: ");
        int num = scanner.nextInt();
        
        System.out.println("Factorial of " + num + " is " + factorial(num));
        scanner.close();
    }

    // Recursive method
    public static long factorial(int n) {
        if (n <= 1) return 1; // Base case
        return n * factorial(n - 1); // Recursive step
    }
}