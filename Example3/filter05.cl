
unsigned char invert(unsigned char in)
{
   return 255-in;
}

__kernel void render(__global char * input,__global char * output, int width, int height) 
{

  unsigned int i = get_global_id(0);

  unsigned int i_mul_4 = i*4;

  output[i_mul_4]   = invert(input[i_mul_4]);
  output[i_mul_4+1] = invert(input[i_mul_4+1]);
  output[i_mul_4+2] = invert(input[i_mul_4+2]);
  output[i_mul_4+3] = input[i_mul_4+3];//Alpha


}