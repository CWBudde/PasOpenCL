
__kernel void render(__global char * input,__global char * output, int width, int height) 
{

  unsigned int i = get_global_id(0);

  unsigned int x,y;

  unsigned int i_mul_4 = i*4;

  x = i / width;
  y = i % width;


  
  unsigned char i_00[9];
  unsigned int summ,aver,disp,len,curr_disp, curr_aver;

  unsigned int i_mul_4_new = ((y*width+x)*4);

  if ((x<=(width-4))&&(y<=(height-4))&&(x>=3)&&(y>=3))
  {
    
    i_00[0] = input[(((y-2)*width+(x-2))*4)];
    i_00[1] = input[(((y-2)*width+(x-1))*4)];
    i_00[2] = input[(((y-2)*width+(x  ))*4)];
    i_00[3] = input[(((y-1)*width+(x-2))*4)];
    i_00[4] = input[(((y-1)*width+(x-1))*4)];
    i_00[5] = input[(((y-1)*width+(x  ))*4)];
    i_00[6] = input[(((y  )*width+(x-2))*4)];
    i_00[7] = input[(((y  )*width+(x-1))*4)];
    i_00[8] = input[(((y  )*width+(x  ))*4)];

	summ = 0;
	for(int i=0; i<=8; ++i) {
		summ+=i_00[i];
	}
	aver = summ/9;

	disp = 0;
	for(int i=0; i<=8; ++i) {
		len = i_00[i]-aver;
		disp += len*len;
	}
	disp = disp/9;

    i_00[0] = input[(((y-2)*width+(x  ))*4)];
    i_00[1] = input[(((y-2)*width+(x+1))*4)];
    i_00[2] = input[(((y-2)*width+(x+2))*4)];
    i_00[3] = input[(((y-1)*width+(x  ))*4)];
    i_00[4] = input[(((y-1)*width+(x+1))*4)];
    i_00[5] = input[(((y-1)*width+(x+2))*4)];
    i_00[6] = input[(((y  )*width+(x  ))*4)];
    i_00[7] = input[(((y  )*width+(x+1))*4)];
    i_00[8] = input[(((y  )*width+(x+2))*4)];

	summ = 0;
	for(int i=0; i<=8; ++i) {
		summ+=i_00[i];
	}
	curr_aver = summ/9;

	curr_disp = 0;
	for(int i=0; i<=8; ++i) {
		len = i_00[i]-curr_aver;
		curr_disp += len*len;
	}
	curr_disp = curr_disp/9;

	if (curr_disp<disp) {
		disp = curr_disp;
		aver = curr_aver;
	}

    i_00[0] = input[(((y  )*width+(x-2))*4)];
    i_00[1] = input[(((y  )*width+(x-1))*4)];
    i_00[2] = input[(((y  )*width+(x  ))*4)];
    i_00[3] = input[(((y+1)*width+(x-2))*4)];
    i_00[4] = input[(((y+1)*width+(x-1))*4)];
    i_00[5] = input[(((y+1)*width+(x  ))*4)];
    i_00[6] = input[(((y+2)*width+(x-2))*4)];
    i_00[7] = input[(((y+2)*width+(x-1))*4)];
    i_00[8] = input[(((y+2)*width+(x  ))*4)];

	summ = 0;
	for(int i=0; i<=8; ++i) {
		summ+=i_00[i];
	}
	curr_aver = summ/9;

	curr_disp = 0;
	for(int i=0; i<=8; ++i) {
		len = i_00[i]-curr_aver;
		curr_disp += len*len;
	}
	curr_disp = curr_disp/9;

	if (curr_disp<disp) {
		disp = curr_disp;
		aver = curr_aver;
	}

    i_00[0] = input[(((y  )*width+(x  ))*4)];
    i_00[1] = input[(((y  )*width+(x+1))*4)];
    i_00[2] = input[(((y  )*width+(x+2))*4)];
    i_00[3] = input[(((y+1)*width+(x  ))*4)];
    i_00[4] = input[(((y+1)*width+(x+1))*4)];
    i_00[5] = input[(((y+1)*width+(x+2))*4)];
    i_00[6] = input[(((y+2)*width+(x  ))*4)];
    i_00[7] = input[(((y+2)*width+(x+1))*4)];
    i_00[8] = input[(((y+2)*width+(x+2))*4)];

	summ = 0;
	for(int i=0; i<=8; ++i) {
		summ+=i_00[i];
	}
	curr_aver = summ/9;

	curr_disp = 0;
	for(int i=0; i<=8; ++i) {
		len = i_00[i]-curr_aver;
		curr_disp += len*len;
	}
	curr_disp = curr_disp/9;

	if (curr_disp<disp) {
		disp = curr_disp;
		aver = curr_aver;
	}
  
    output[i_mul_4_new]  =aver;
    output[i_mul_4_new+1]=aver;
    output[i_mul_4_new+2]=aver;
    
    output[i_mul_4_new+3]=input[i_mul_4+3];
  } else {

    output[i_mul_4_new]  = 0;
    output[i_mul_4_new+1]= 0;
    output[i_mul_4_new+2]= 0;
    output[i_mul_4_new+3]= 0;
}

}
