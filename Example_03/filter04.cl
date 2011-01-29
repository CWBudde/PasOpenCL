#define THRESHOLD_VALUE 100

unsigned char threshold(unsigned char in)
{
  if (in>THRESHOLD_VALUE) return 255;
  return 0;
}

__kernel void render(__global char * input,__global char * output, int width, int height) 
{

  unsigned int i = get_global_id(0);

  unsigned int i_mul_4 = i*4;

  output[i_mul_4]   = threshold(input[i_mul_4]);
  output[i_mul_4+1] = threshold(input[i_mul_4+1]);
  output[i_mul_4+2] = threshold(input[i_mul_4+2]);
  output[i_mul_4+3]=input[i_mul_4+3];//Alpha


}