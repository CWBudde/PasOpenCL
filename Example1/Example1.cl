__kernel void somekernel(__global int *src,__global int *dst) 
{
	int id = get_global_id(0);
	dst[id] = (int)pown((float)src[id],4);
}
