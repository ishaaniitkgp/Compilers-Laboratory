// testing cases

/*
21CS10077: Vinayak Gupta
21CS30064: Ishaan Sinha
COMPILERS ASSIGNMENT 4
*/


restrict volatile short p3=5;
int queue[100];


int front=0,back=0;


void push(int var)
{
    queue[back] = var;
    back++;
}

void pop()
{
    queue[front] = 0;
    front++;
}


int visited[7] = {0};

void bubble_sort(int *array, int n) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
        if (array[j] > array[j + 1]) {
            int temp = array[j];
            array[j] = array[j + 1];
            array[j + 1] = temp;
        }
        }
    }
}

void dfs(int u) {
  visited[u] = 1;
  printf("%d ", u);

  for (int v = 0; v < 100; v++) {
    if (adj[u][v] && !visited[v]) {
      dfs(v);
    }
  }
}
int adj[100][100];
int visited[100];

int main()
{
    
    int N  = 6;
    float f1 = 0.020;
    float scif1 = 1e+13;
    char * s1 = 'A';
    char * s2 = "bfs algorithm";

    int graph[6][6] = {{0,1,1,0,0,0},
                     {1,0,1,0,0,0},
                     {1,1,0,1,1,0},
                     {0,0,1,0,0,0},
                     {0,0,1,0,0,1},
                     {0,0,0,0,1,0}};



    push(1);
    visited[0] = 1;
    while(front != back)
    {
        int current = queue[front];
        
        
        printf("%d ", current);
        
        
        pop();
 
        for(int i=0;i<6;i++)
        {
        
            if((graph[current-1][i] == 1) && (visited[i] == 0))
            {
                visited[i] = 1; 
                push(i+1);
            }
        }
    }

    

    int array[] = {10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
    int n = sizeof(array) / sizeof(array[0]);

    bubble_sort(array, n);

    for (int i = 0; i < n; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");


  int i, j;

  // Initialize the adjacency matrix.
  for (i = 0; i < N; i++) {
    for (j = 0; j < N; j++) {
      adj[i][j] = 0;
    }
  }

  // Add edges to the graph.
  adj[0][1] = 1;
  adj[0][2] = 1;
  adj[1][3] = 1;
  adj[2][4] = 1;
  adj[3][5] = 1;
  adj[4][6] = 1;
  adj[5][7] = 1;
  adj[6][8] = 1;
  adj[7][9] = 1;

  // Mark all vertices as unvisited.
  for (i = 0; i < N; i++) {
    visited[i] = 0;
  }

  // Start DFS from vertex 0.
  dfs(0);


    return 0;
}

