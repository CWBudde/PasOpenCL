#define LOG_VALUE 25  //some const value

unsigned char logconv(unsigned char in)
{
   return LOG_VALUE*log((float)in+1);
}

__kernel void render(__global char * input,__global char * output, int width, int height) 
{

  unsigned int i = get_global_id(0);

  unsigned int i_mul_4 = i*4;

  output[i_mul_4]   = logconv(input[i_mul_4]);
  output[i_mul_4+1] = logconv(input[i_mul_4+1]);
  output[i_mul_4+2] = logconv(input[i_mul_4+2]);
  output[i_mul_4+3] = input[i_mul_4+3];//Alpha


}