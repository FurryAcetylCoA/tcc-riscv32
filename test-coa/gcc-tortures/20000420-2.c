struct x { int a, b, c; };

void b (struct x);

void foo(){
  struct x aa = {1,1,1};

  b (aa);
}
