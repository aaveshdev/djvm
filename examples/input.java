import java.util.Scanner; // Import the Scanner class

class input {
    public static void main(String[] args) {
        // Create a Scanner object to read input
        Scanner myObj = new Scanner(System.in);

        System.out.println("Enter your name:");
        // Read a line of text (String)
        String userName = myObj.nextLine();

        System.out.println("Enter your age:");
        // Read an integer
        int age = myObj.nextInt();

        // Display the output
        System.out.println("Hello, " + userName + "!");
        System.out.println("You are " + age + " years old.");
        
        // Close the scanner to prevent memory leaks
        myObj.close();
    }
}