#define FILTER_SIZE 7
#define FILTER_SIZE_SQUARE (FILTER_SIZE*FILTER_SIZE)
__kernel void render(__global unsigned char * input,__global unsigned char * output, int width, int height) 
{

  unsigned int pos = get_global_id(0);

  unsigned int x,y;

  unsigned int i_mul_4 = pos*4;

  x = pos / width;
  y = pos % width;


  
  unsigned char i_00[FILTER_SIZE_SQUARE];
  unsigned int summ,aver,disp,len,curr_disp, curr_aver;
  unsigned int c;

  unsigned int i_mul_4_new = ((y*width+x)*4);

  if ((x<=(width-FILTER_SIZE-1))&&(y<=(height-FILTER_SIZE-1))&&(x>=FILTER_SIZE)&&(y>=FILTER_SIZE))
  {
    
	c = 0;
	for(int i=0;i<FILTER_SIZE;++i) {
		for(int j=0;j<FILTER_SIZE;++j){
			i_00[c] = input[(((y-i)*width+(x-j))*4)];
			c++;
		}

	}

	summ = 0;
	for(int i=0; i<FILTER_SIZE_SQUARE; ++i) {
		summ+=i_00[i];
	}
	aver = summ/FILTER_SIZE_SQUARE;

	disp = 0;
	for(int i=0; i<FILTER_SIZE_SQUARE; ++i) {
		len = i_00[i]-aver;
		disp += len*len;
	}
	disp = disp/FILTER_SIZE_SQUARE;

	c = 0;
	for(int i=0;i<FILTER_SIZE;++i) {
		for(int j=0;j<FILTER_SIZE;++j){
			i_00[c] = input[(((y-i)*width+(x+j))*4)];
			c++;
		}

	}

	summ = 0;
	for(int i=0; i<FILTER_SIZE_SQUARE; ++i) {
		summ+=i_00[i];
	}
	curr_aver = summ/FILTER_SIZE_SQUARE;

	curr_disp = 0;
	for(int i=0; i<FILTER_SIZE_SQUARE; ++i) {
		len = i_00[i]-curr_aver;
		curr_disp += len*len;
	}
	curr_disp = curr_disp/FILTER_SIZE_SQUARE;

	if (curr_disp<disp) {
		disp = curr_disp;
		aver = curr_aver;
	}

	c = 0;
	for(int i=0;i<FILTER_SIZE;++i) {
		for(int j=0;j<FILTER_SIZE;++j){
			i_00[c] = input[(((y+i)*width+(x-j))*4)];
			c++;
		}

	}

	summ = 0;
	for(int i=0; i<FILTER_SIZE_SQUARE; ++i) {
		summ+=i_00[i];
	}
	curr_aver = summ/FILTER_SIZE_SQUARE;

	curr_disp = 0;
	for(int i=0; i<FILTER_SIZE_SQUARE; ++i) {
		len = i_00[i]-curr_aver;
		curr_disp += len*len;
	}
	curr_disp = curr_disp/FILTER_SIZE_SQUARE;

	if (curr_disp<disp) {
		disp = curr_disp;
		aver = curr_aver;
	}

	c = 0;
	for(int i=0;i<FILTER_SIZE;++i) {
		for(int j=0;j<FILTER_SIZE;++j){
			i_00[c] = input[(((y+i)*width+(x+j))*4)];
			c++;
		}

	}

	summ = 0;
	for(int i=0; i<FILTER_SIZE_SQUARE; ++i) {
		summ+=i_00[i];
	}
	curr_aver = summ/FILTER_SIZE_SQUARE;

	curr_disp = 0;
	for(int i=0; i<FILTER_SIZE_SQUARE; ++i) {
		len = i_00[i]-curr_aver;
		curr_disp += len*len;
	}
	curr_disp = curr_disp/FILTER_SIZE_SQUARE;

	if (curr_disp<disp) {
		disp = curr_disp;
		aver = curr_aver;
	}
  
	if (aver>255) { 
    		output[i_mul_4_new]  =255;
    		output[i_mul_4_new+1]=255;
    		output[i_mul_4_new+2]=255;
	} else {
    		output[i_mul_4_new]  =aver;
    		output[i_mul_4_new+1]=aver;
    		output[i_mul_4_new+2]=aver;
	}
    
    output[i_mul_4_new+3]=input[i_mul_4+3];
  } else {

    output[i_mul_4_new]  = 0;
    output[i_mul_4_new+1]= 0;
    output[i_mul_4_new+2]= 0;
    output[i_mul_4_new+3]= 0;
}

}