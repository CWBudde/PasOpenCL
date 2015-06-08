__kernel void render(__global char * input,__global char * output, int width, int height) 
{

  unsigned int i = get_global_id(0);

  unsigned int i_mul_4 = i*4;

  unsigned char temp;
  temp = 0.1*input[i_mul_4]+0.6*input[i_mul_4+1]+0.3*input[i_mul_4+2];
  output[i_mul_4]  =temp;//Blue
  output[i_mul_4+1]=temp;//Green
  output[i_mul_4+2]=temp;//Red


output[i_mul_4+3]=input[i_mul_4+3];//Alpha


}