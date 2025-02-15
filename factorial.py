 def factorial(n, method="iterative"):
    if method == "iterative":
        result = 1
        for i in range(1, n + 1):
            result *= i
        return result
    else:
        # Placeholder for recursive method
        pass

if __name__ == "__main__":
    number = 5
    method = input("Choose method (iterative/recursive): ").strip().lower()
    print(f"Factorial of {number} is {factorial(number, method)}")
