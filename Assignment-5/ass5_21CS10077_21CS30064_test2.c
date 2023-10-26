// Checking Function Declarations and calls and conditional statements- ternary and if-else (with this the relational and logical expression handling will be checked)

int maximum (int x, int y) {
    int ans;
    if (x > y)                      // if-else
        ans = x;
    else
        ans = y;

    if(ans < 0)
        ans = -ans;
    return ans;
}


int minimum (int x, int y) {
    int ans;
    ans = x > y ? y:x;              // ternary
    return ans;
}

void print (char *ch) {
    // print the char array
    return;
}

void print_greater (int m, int n) {
    char greater_m[] = "m > n";
    char greater_n[] = "n > m";
    m > n ? print(greater_m) : print(greater_n);
    return;
}

int add(int a, int b) {
    int i = min(a, b);            // nested function calls
    int j = max(a, b);
    int j = 0;
    int d = j + i;
    return d;
}

// making some functions to check the correctness of Logical Expressions
void test(int a, int b){
    int i;
    if((a==0)||(b==0)){
        i=0;
    }
    else if((a<0)&&(b<0)){
        i= -(a+b);
    }
    else if((a>0)&&(b<0)){
        i= a-b;
    }
    else if((a<0)&&(b>0)){
        i= b-a;
    }
    else{
        i= a+b;
    }

return;             // Both Logical expression- Logical-AND and Logical-OR has been checked

}

int main() {
    int a, b, sum;
    a = 1, b = 52;
    sum = add(a, b);
    return 0;
}

// With this we have already checked the correctness of Expression Handling Phase and Declaration Phase