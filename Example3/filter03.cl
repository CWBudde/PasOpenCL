__kernel void render(__global char * input,__global char * output, int width, int height) 
{

  unsigned int i = get_global_id(0);

  unsigned int i_mul_4 = i*4;


  unsigned char temp;

  //swap rgb
  temp             = input[i_mul_4];
  output[i_mul_4]  = input[i_mul_4+2];//Blue
  output[i_mul_4]  = input[i_mul_4+1];
  output[i_mul_4+2]= temp;            //Red


output[i_mul_4+3]=input[i_mul_4+3];//Alpha


}