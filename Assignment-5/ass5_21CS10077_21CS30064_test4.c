// Checking correctness of type-casting, pointer assignments and External Function Definitions

int calculate(int x, int n, float sum);  // Only Function Declaration

int main()
{
    int x=5;
    int n=10;

    int *p,*g; // pointer declaration

    // Checking pointer assignment
    p= &x;

    float sum=1;
    float term=1;

    float result=calculate(x,n,sum); //example of typecasting as return type is int but here we have defined it to be float
    return 1 // intentionally left the semicolon after return 1 to check whether the parser identifies the syntax error or not

}

//Checking the correctness of External Function Definition

int calculate(int x, int n, float sum)
{
    int i;
    float term=1;
    for(i=1;i<=n;i++)
    {
        term=term*x/i;
        sum=sum+term;
    }
    return sum;
}