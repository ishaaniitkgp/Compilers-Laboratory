// Checking the correctness of Statement Phase(for, while statements etc.), if-else statements already checked

int main(){
    int i,j,a=0,b,c=30;
    int n=5;

    for(i=0;i<n;i++){           // nested for loop
        for(j=0;j<n;j++){
            a++;
        }
    }

    b=a;
    while(b>0){         // while loop
        c--;
        b--;
    }
}