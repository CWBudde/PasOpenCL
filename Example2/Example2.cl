float mapX(float x) 
{
  return x*3.25 - 2;
}

float mapY(float y) 
{
  return y*2.5 - 1.25;
}

int index(int x, int y, int width) 
{
  return x*4+4*width*y;
}

char mynormalize(char v)
{
   if (v>255) return 0;
   return v;
}

__kernel void render(__global char * output) 
{

  int x_dim = get_global_id(0);
  int y_dim = get_global_id(1);
  size_t width = get_global_size(0);
  size_t height = get_global_size(1);
  int idx = index(x_dim, y_dim, width);

  float x_0 = mapX((float) x_dim / width);
  float y_0 = mapY((float) y_dim / height);

  float x = 0.0;
  float y = 0.0;

  char iteration = 0;

  char max_iteration = 127;
  while( (x*x + y*y <= 4) && (iteration < max_iteration) ) 
  {
    float xtemp = x*x - y*y + x_0;
    y = 2*x*y + y_0;
    x = xtemp;
    iteration++;
  }

  if(iteration == max_iteration) 
  { 
    output[idx] = 0;
    output[idx + 1] = 0;
    output[idx + 2] = 0;
  } 
  else 
  {
    output[idx] = mynormalize(iteration*5*x*y/100);
    output[idx + 1] = mynormalize(iteration*x/10);
    output[idx + 2] = mynormalize(iteration*y/10);
  }
  output[idx + 3] = 255;
}