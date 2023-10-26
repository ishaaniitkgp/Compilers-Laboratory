// Checking correctness of Recursive function call

int factorial(int n)
{
    int i,j,k;
    if(n<1){
        k=1;
    }
    else{
    i=n-1;
    j=factorial(i);
    k=n*j;
    }
    return k;
}
int main()
{
    int m=5;

    int result=factorial(m);
    return 1;

}