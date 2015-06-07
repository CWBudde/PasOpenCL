__kernel void render(__global char * input,__global char * output, int width, int height) 
{

  unsigned int i = get_global_id(0);

  unsigned int i_mul_4 = i*4;

  unsigned int x,y;

  y = i / width;
  
  x = i % width;

  if ((x<width-1)&&(x>0)&&(y>0)&&(y<height-1))
  {
    
    unsigned int temp;
    temp = 
           -input[i_mul_4-4]+               //x-1;  y  ;
           8*input[i_mul_4  ]+               //x  ;  y  ;
           -input[i_mul_4+4]+               //x+1;  y  ;

           -input[i_mul_4-4-4*width]+       //x-1;  y-1;
           -input[i_mul_4-4+4*width]+       //x-1;  y+1;

           -input[i_mul_4+4-4*width]+       //x+1;  y-1;
           -input[i_mul_4+4+4*width]+       //x+1;  y+1;

           -input[i_mul_4-4*width]+         //x  ;  y-1;
           -input[i_mul_4+4*width];         //x  ;  y+1;
    
    temp = temp;
    if (temp>255)
    {
      output[i_mul_4] = 255;
    }
    else
    {
      output[i_mul_4] = temp;
    }

    temp = 
           -input[i_mul_4-3]+               //x-1;  y  ;
           8*input[i_mul_4+1]+               //x  ;  y  ;
           -input[i_mul_4+5]+               //x+1;  y  ;

           -input[i_mul_4-3-4*width]+       //x-1;  y-1;
           -input[i_mul_4-3+4*width]+       //x-1;  y+1;

           -input[i_mul_4+5-4*width]+       //x+1;  y-1;
           -input[i_mul_4+5+4*width]+       //x+1;  y+1;

           -input[i_mul_4-4*width+1]+         //x  ;  y-1;
           -input[i_mul_4+4*width+1];         //x  ;  y+1;
    
    temp = temp;
    if (temp>255)
    {
      output[i_mul_4+1] = 255;
    }
    else
    {
      output[i_mul_4+1] = temp;
    }

    temp = 
           -input[i_mul_4-2]+               //x-1;  y  ;
           8*input[i_mul_4+2]+               //x  ;  y  ;
           -input[i_mul_4+6]+               //x+1;  y  ;

           -input[i_mul_4-2-4*width]+       //x-1;  y-1;
           -input[i_mul_4-2+4*width]+       //x-1;  y+1;

           -input[i_mul_4+6-4*width]+       //x+1;  y-1;
           -input[i_mul_4+6+4*width]+       //x+1;  y+1;

           -input[i_mul_4-4*width+2]+         //x  ;  y-1;
           -input[i_mul_4+4*width+2];         //x  ;  y+1;
    
    temp = temp;
    if (temp>255)
    {
      output[i_mul_4+2] = 255;
    }
    else
    {
      output[i_mul_4+2] = temp;
    }

    
  }
  else
  {
    output[i_mul_4]  =input[i_mul_4];//Blue
    output[i_mul_4+1]=input[i_mul_4+1];//Green
    output[i_mul_4+2]=input[i_mul_4+2];//Red
    
  }

output[i_mul_4+3]=input[i_mul_4+3];//Alpha


}