
__kernel void render(__global char * input,__global char * output, int width, int height) 
{

  unsigned int i = get_global_id(0);

  unsigned int x,y;

  unsigned int i_mul_4 = i*4;

  y = i / width;
  x = i % width;

  unsigned int x2,y2;

  x2 = y;
  y2 = x;
  
  
  if ((x2<width)&&(y2<height)/*&&(x2>=0)&&(y2>=0)*/)
  {
    unsigned int i_mul_4_new = ((y2*width+x2)*4);

  
    output[i_mul_4_new]  =input[i_mul_4];//Blue
    output[i_mul_4_new+1]=input[i_mul_4+1];//Green
    output[i_mul_4_new+2]=input[i_mul_4+2];//Red
    
    output[i_mul_4_new+3]=input[i_mul_4+3];//Alpha
  }
  

}